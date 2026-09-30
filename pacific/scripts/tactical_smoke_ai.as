#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "ballistics.as"
#include "mod_safe_queries.as"

// Tactical smoke uses actual carried grenades. A check has no timer cooldown;
// spotted enemy vehicles are handled immediately; broader checks run every 8 seconds.
class TacticalSmokeAI : Tracker {
    protected Metagame@ m_metagame;
    protected array<int> m_attackBase;
    protected array<int> m_scanOffset;
    protected array<int> m_rosterOffset;
    protected uint m_rosterFaction;
    protected array<int> m_detailIds;
    protected array<const XmlElement@> m_detailActors;
    protected array<int> m_factionIds;
    protected dictionary m_woundedActors;
    protected array<int> m_hitFactions;
    protected array<Vector3> m_hitPositions;
    protected array<Vector3> m_hitEnemyPositions;
    protected array<int> m_hitHasEnemy;
    protected bool m_woundBaselineReady;
    protected int m_detailQueries;
    protected float m_checkIn;
    protected dictionary m_vehicleKeyCache;
    protected array<int> m_vehicleTriedActors;
    protected string m_vehicleTags10;
    protected string m_vehicleTags8;
    protected string m_vehicleTags6;
    protected string m_vehicleTags4;
    protected string m_vehicleTags2;

    TacticalSmokeAI(Metagame@ metagame) {
        @m_metagame = @metagame;
        m_checkIn = 8.0f;
        m_vehicleTags10 = "|cargo_tank.vehicle|king_tiger.vehicle|king_tiger_boss.vehicle|king_tiger_player.vehicle|maus_boss.vehicle|panther.vehicle|repair_tank.vehicle|repair_tank_base.vehicle|tiger.vehicle|tiger_sicily.vehicle|tog2_boss.vehicle|";
        m_vehicleTags8 = "|chi_ha.vehicle|chi_ha_early.vehicle|churchill_crocodile.vehicle|churchill_mkvii.vehicle|m10.vehicle|m36.vehicle|m4_75.vehicle|m4_75_late.vehicle|m4_75_late_cb_h1.vehicle|m4_76.vehicle|m4_76_late.vehicle|m4_V.vehicle|m4_V_base.vehicle|m4_V_fastrespawn.vehicle|m4_75_e4.vehicle|m4_firefly.vehicle|m4_firefly_base.vehicle|m4_firefly_fastrespawn.vehicle|m4a3e2_75.vehicle|m4a3e2_76.vehicle|m4a3e2_76_late.vehicle|m4a3e8.vehicle|panzer_iv.vehicle|panzer_iv_base.vehicle|panzer_iv_base_flak88.vehicle|panzer_iv_damaged.vehicle|panzer_iv_fastrespawn.vehicle|";
        m_vehicleTags6 = "|hago.vehicle|hago_base.vehicle|hago_damaged.vehicle|luchs.vehicle|m5a1_stuart.vehicle|stuart.vehicle|stuart_base.vehicle|stuart_damaged.vehicle|";
        m_vehicleTags4 = "|austin_k5.vehicle|austin_k5_armoury.vehicle|dukw.vehicle|hoha.vehicle|jeep.vehicle|jeep1.vehicle|katsu.vehicle|kubelwagen.vehicle|lvt4.vehicle|m3_halftrack.vehicle|m3_halftrack_base.vehicle|m3_halftrack_fastrespawn.vehicle|m3_halftrack_mortar.vehicle|opel_blitz_1.vehicle|opel_blitz_2.vehicle|opel_blitz_armoury.vehicle|sdkfz251.vehicle|sdkfz251_base.vehicle|sdkfz251_fastrespawn.vehicle|sdkfz251_flak.vehicle|sdkfz251_mortar.vehicle|sdkfz251_pak40.vehicle|sidecar_german.vehicle|staff_car.vehicle|suki.vehicle|universal_carrier.vehicle|universal_carrier_base.vehicle|universal_carrier_boys.vehicle|universal_carrier_fastrespawn.vehicle|universal_carrier_vickers_k.vehicle|wasp.vehicle|willys_mb.vehicle|willys_mb_recoilless_rifle.vehicle|";
        m_vehicleTags2 = "|5inch_gun.vehicle|aa_gun.vehicle|aa_gun2.vehicle|at_gun_m3_37mm.vehicle|at_gun_m5.vehicle|at_gun_pak40.vehicle|at_gun_pak40_2.vehicle|at_gun_pak40_base.vehicle|b29_turret.vehicle|b29_turret_rear.vehicle|fortified_turret_chi_ha.vehicle|fortified_turret_sherman.vehicle|heavy_mortar.vehicle|lefh18.vehicle|m1917_hmg.vehicle|m1917_hmg_t.vehicle|m1919_hmg.vehicle|m1919_hmg_t.vehicle|m2hb_hmg.vehicle|m2hb_hmg_t.vehicle|mg34_hmg.vehicle|mg34_hmg_t.vehicle|mg42_hmg.vehicle|mg42_hmg_t.vehicle|mg42_hmg_universal.vehicle|normandy_turret.vehicle|oerlikon.vehicle|pillbox.vehicle|pillbox1.vehicle|type92_hmg.vehicle|type92_hmg_t.vehicle|type97_at.vehicle|type98.vehicle|vickers_hmg.vehicle|vickers_hmg_t.vehicle|";
        m_woundBaselineReady = false;
        m_detailQueries = 0;
        m_rosterFaction = 0;
        for (int i = 0; i < 8; ++i) {
            m_attackBase.insertLast(-1);
            m_scanOffset.insertLast(0);
            m_rosterOffset.insertLast(0);
        }
        m_metagame.getComms().send(
            "<command class='set_metagame_event' name='character_kill' enabled='1' />");
    }

    protected bool smokeKey(string key) const {
        return key == "no77_smoke_grenade.projectile" ||
            key == "an_m8_smoke_grenade.projectile" ||
            key == "no79.projectile" ||
            key == "nebelhandgranate_39.projectile" ||
            key == "nebeleihandgranate_42.projectile" ||
            key == "type_94_smoke_candle.projectile";
    }

    protected void handleMatchEndEvent(const XmlElement@ event) {
        for (uint i = 0; i < m_attackBase.length(); ++i) {
            m_attackBase[i] = -1;
            m_scanOffset[i] = 0;
            m_rosterOffset[i] = 0;
        }
        m_factionIds.resize(0);
        m_rosterFaction = 0;
        resetDetails();
        m_woundedActors.deleteAll();
        m_vehicleKeyCache.deleteAll();
        m_vehicleTriedActors.resize(0);
        clearHits();
        m_woundBaselineReady = false;
        m_checkIn = 8.0f;
    }

    protected void handleAttackChangeEvent(const XmlElement@ event) {
        int factionId = modIntAttribute(event, "faction_id");
        if (factionId < 0 || factionId >= int(m_attackBase.length()) ||
            event is null || !event.hasAttribute("base_id")) return;
        int baseId = event.getIntAttribute("base_id");
        m_attackBase[factionId] = baseId < 0 ? -2 : baseId;
    }

    // A freshly spotted enemy vehicle can be answered on the next event
    // callback, without waiting for the eight-second broad scan.
    protected void handleVehicleSpotEvent(const XmlElement@ event) {
        int factionId = modIntAttribute(event, "faction_id");
        int ownerId = modIntAttribute(event, "owner_id");
        int vehicleId = modIntAttribute(event, "vehicle_id");
        if (factionId < 0 || factionId >= int(m_attackBase.length()) ||
            ownerId < 0 || ownerId == factionId || vehicleId < 0) return;
        string key = event.getStringAttribute("vehicle_key");
        if (key != "" && vehiclePriority(key) == 0) return;
        const XmlElement@ vehicle = getVehicleInfo(m_metagame, vehicleId);
        Vector3 position;
        if (modIntAttribute(vehicle, "id") != vehicleId ||
            !modTryVectorAttribute(vehicle, "position", position)) return;
        if (key == "") key = vehicle.getStringAttribute("key");
        if (vehiclePriority(key) == 0) return;
        m_vehicleKeyCache.set("" + vehicleId, key);
        if (modIntAttribute(vehicle, "owner_id", ownerId) == factionId) return;
        if (vehicle.hasAttribute("health") &&
            vehicle.getFloatAttribute("health") <= 0.0f) return;
        array<const XmlElement@>@ allies =
            getCharactersNearPosition(m_metagame, position, factionId, 36.0f);
        if (allies is null) return;
        m_vehicleTriedActors.resize(0);
        resetDetails();
        // Nearby lists contain IDs, not faction/position/equipment records.
        tryVehicleTarget(allies, factionId, position, "vehicle_spotted", 8);
    }

    protected void clearHits() {
        m_hitFactions.resize(0);
        m_hitPositions.resize(0);
        m_hitEnemyPositions.resize(0);
        m_hitHasEnemy.resize(0);
    }

    protected void recordHit(int factionId, const Vector3 &in position,
                             const Vector3 &in enemyPosition, bool hasEnemy) {
        if (factionId < 0 || factionId >= int(m_attackBase.length())) return;
        // Bound the event queue during a very large firefight.
        if (m_hitFactions.length() >= 16) {
            m_hitFactions.removeAt(0);
            m_hitPositions.removeAt(0);
            m_hitEnemyPositions.removeAt(0);
            m_hitHasEnemy.removeAt(0);
        }
        m_hitFactions.insertLast(factionId);
        m_hitPositions.insertLast(position);
        m_hitEnemyPositions.insertLast(enemyPosition);
        m_hitHasEnemy.insertLast(hasEnemy ? 1 : 0);
    }

    protected void handleCharacterKillEvent(const XmlElement@ event) {
        if (event is null) return;
        const XmlElement@ victim = event.getFirstElementByTagName("target");
        int factionId = modIntAttribute(victim, "faction_id");
        Vector3 position;
        if (factionId < 0 ||
            !modTryVectorAttribute(victim, "position", position)) return;
        const XmlElement@ killer = event.getFirstElementByTagName("killer");
        int enemyFaction = modIntAttribute(killer, "faction_id");
        Vector3 enemyPosition = position;
        bool hasEnemy = enemyFaction >= 0 && enemyFaction != factionId &&
            modTryVectorAttribute(killer, "position", enemyPosition);
        recordHit(factionId, position, enemyPosition, hasEnemy);
    }

    protected bool loadFactions() {
        if (m_factionIds.length() > 0) return true;
        array<const XmlElement@>@ factions = getFactions(m_metagame);
        if (factions is null) return false;
        for (uint i = 0; i < factions.length(); ++i) {
            if (factions[i] is null) continue;
            int id = modIntAttribute(factions[i], "id");
            if (id >= 0 && id < int(m_attackBase.length()))
                if (m_factionIds.find(id) < 0) m_factionIds.insertLast(id);
        }
        return m_factionIds.length() > 0;
    }

    // Mirrors M1 Bazooka target_factors. Keys are generated from the mod's
    // vehicle definitions, falling back to the vanilla vehicle definitions.
    // This whitelist excludes smoke blockers, crates and other helper vehicles.
    protected int vehiclePriority(string key) const {
        if (key == "") return 0;
        string needle = "|" + key + "|";
        if (m_vehicleTags10.findFirst(needle) >= 0) return 10;
        if (m_vehicleTags8.findFirst(needle) >= 0) return 8;
        if (m_vehicleTags6.findFirst(needle) >= 0) return 6;
        if (m_vehicleTags4.findFirst(needle) >= 0) return 4;
        if (m_vehicleTags2.findFirst(needle) >= 0) return 2;
        return 0;
    }

    protected bool alive(const XmlElement@ character) const {
        Vector3 position;
        int factionId = modIntAttribute(character, "faction_id");
        return modIntAttribute(character, "id") >= 0 &&
            factionId >= 0 && factionId < int(m_attackBase.length()) &&
            modTryVectorAttribute(character, "position", position) &&
            (!character.hasAttribute("dead") ||
             character.getIntAttribute("dead") == 0);
    }

    protected bool canThrow(const XmlElement@ character) const {
        return alive(character) && character.hasAttribute("player_id") &&
            character.getIntAttribute("player_id") < 0 &&
            (!character.hasAttribute("wounded") ||
             character.getIntAttribute("wounded") == 0);
    }

    protected void resetDetails() {
        m_detailQueries = 0;
        m_detailIds.resize(0);
        m_detailActors.resize(0);
    }

    // One detail query supplies identity, position AND equipment. Cache even
    // failed lookups so a removed actor is not queried repeatedly this pass.
    protected const XmlElement@ resolveActor(const XmlElement@ candidate,
                                             int queryLimit = 12) {
        int id = modIntAttribute(candidate, "id");
        if (id < 0) return null;
        int cached = m_detailIds.find(id);
        if (cached >= 0) return m_detailActors[cached];
        if (m_detailQueries >= queryLimit) return null;
        ++m_detailQueries;
        const XmlElement@ actor = getCharacterInfo2(m_metagame, id);
        if (modIntAttribute(actor, "id") != id || !alive(actor)) @actor = null;
        m_detailIds.insertLast(id);
        m_detailActors.insertLast(actor);
        return actor;
    }

    // Do not turn ID-only global rosters into hundreds of synchronous detail
    // queries. Rotate a balanced, bounded sample across the live factions.
    protected void sampleCharacters(array<const XmlElement@> &out characters) {
        array<const XmlElement@> roster;
        array<int> starts;
        array<int> counts;
        array<int> examined(m_factionIds.length(), 0);
        dictionary liveIds;
        for (uint f = 0; f < m_factionIds.length(); ++f) {
            starts.insertLast(int(roster.length()));
            array<const XmlElement@>@ list =
                getCharacters(m_metagame, m_factionIds[f]);
            if (list !is null) {
                for (uint i = 0; i < list.length(); ++i) {
                    int id = modIntAttribute(list[i], "id");
                    if (id < 0) continue;
                    roster.insertLast(list[i]);
                    liveIds.set("" + id, 1);
                }
            }
            counts.insertLast(int(roster.length()) - starts[f]);
        }
        // Keep wound state for unsampled actors, but prune actors which left.
        array<string> previous = m_woundedActors.getKeys();
        for (uint i = 0; i < previous.length(); ++i)
            if (!liveIds.exists(previous[i])) m_woundedActors.delete(previous[i]);

        uint factionCount = m_factionIds.length();
        if (factionCount == 0) return;
        uint first = m_rosterFaction % factionCount;
        bool progressed = true;
        while (m_detailQueries < 12 && progressed) {
            progressed = false;
            for (uint n = 0; n < factionCount && m_detailQueries < 12; ++n) {
                uint f = (first + n) % factionCount;
                if (counts[f] <= 0 || examined[f] >= counts[f]) continue;
                int factionId = m_factionIds[f];
                int index = m_rosterOffset[factionId] % counts[f];
                m_rosterOffset[factionId] = (index + 1) % counts[f];
                ++examined[f];
                progressed = true;
                const XmlElement@ actor = resolveActor(roster[starts[f] + index]);
                if (actor !is null) characters.insertLast(actor);
            }
        }
        m_rosterFaction = (first + 1) % factionCount;
    }

    protected const XmlElement@ nearestEnemy(
            const array<const XmlElement@>@ characters, int factionId,
            const Vector3 &in position, float maxDistance) const {
        if (characters is null) return null;
        const XmlElement@ nearest = null;
        float best = maxDistance;
        for (uint i = 0; i < characters.length(); ++i) {
            const XmlElement@ enemy = characters[i];
            if (!alive(enemy) ||
                enemy.getIntAttribute("faction_id") == factionId) continue;
            if (enemy.hasAttribute("wounded") &&
                enemy.getIntAttribute("wounded") != 0) continue;
            Vector3 enemyPos;
            if (!modTryVectorAttribute(enemy, "position", enemyPos)) continue;
            float distance = getPositionDistance(position, enemyPos);
            if (distance <= best) {
                best = distance;
                @nearest = enemy;
            }
        }
        return nearest;
    }

    protected const XmlElement@ findBase(
            const array<const XmlElement@>@ bases, int id) const {
        if (bases is null || id < 0) return null;
        for (uint i = 0; i < bases.length(); ++i) {
            if (modIntAttribute(bases[i], "id") == id) return bases[i];
        }
        return null;
    }

    // An attack order may have been issued before this tracker was added.
    protected int fallbackAttackBase(
            const array<const XmlElement@>@ bases, int factionId) const {
        if (bases is null) return -1;
        float bestDistance = 1000000.0f;
        int bestId = -1;
        for (uint i = 0; i < bases.length(); ++i) {
            if (modIntAttribute(bases[i], "owner_id") != factionId) continue;
            Vector3 ownPos;
            if (!modTryVectorAttribute(bases[i], "position", ownPos)) continue;
            for (uint j = 0; j < bases.length(); ++j) {
                int owner = modIntAttribute(bases[j], "owner_id");
                int id = modIntAttribute(bases[j], "id");
                if (owner < 0 || owner == factionId || id < 0) continue;
                Vector3 targetPos;
                if (!modTryVectorAttribute(bases[j], "position", targetPos)) continue;
                float distance = getPositionDistance(ownPos, targetPos);
                if (distance < bestDistance) {
                    bestDistance = distance;
                    bestId = id;
                }
            }
        }
        return bestId;
    }

    protected bool throwSmoke(const XmlElement@ candidate, int factionId,
                              const Vector3 &in destination, string reason) {
        const XmlElement@ actor = resolveActor(candidate);
        if (!canThrow(actor) || actor.getIntAttribute("faction_id") != factionId)
            return false;
        int actorId = actor.getIntAttribute("id");
        array<const XmlElement@>@ equipment = actor.getElementsByTagName("item");
        if (equipment is null || equipment.length() <= 2 ||
            equipment[2] is null || !equipment[2].hasAttribute("amount")) return false;
        string key = equipment[2].getStringAttribute("key");
        if (!smokeKey(key) || equipment[2].getIntAttribute("amount") <= 0)
            return false;

        Vector3 actorPos;
        if (!modTryVectorAttribute(actor, "position", actorPos)) return false;
        Vector3 origin = actorPos.add(Vector3(0, 0.8f, 0));
        BallisticsParameters throwPath =
            BallisticsParameters(5.0f, 12.0f, 17.0f, 17.0f,
                                16.5f, 0.0f, 1.0f, 10.0f);
        Vector3 velocity = throwPath.getLaunchVector(origin, destination);

        XmlElement command("command");
        command.setStringAttribute("class", "create_instance");
        command.setStringAttribute("instance_class", "grenade");
        command.setStringAttribute("instance_key", key);
        command.setStringAttribute("position", origin.toString());
        command.setStringAttribute("offset", velocity.toString());
        command.setIntAttribute("faction_id", factionId);
        command.setIntAttribute("character_id", actorId);
        m_metagame.getComms().send(command);

        XmlElement inventory("command");
        inventory.setStringAttribute("class", "update_inventory");
        inventory.setIntAttribute("character_id", actorId);
        inventory.setIntAttribute("container_type_id", 4);
        inventory.setIntAttribute("add", 0);
        XmlElement item("item");
        item.setStringAttribute("class", "projectile");
        item.setStringAttribute("key", key);
        inventory.appendChild(item);
        m_metagame.getComms().send(inventory);
        _log("tactical smoke: " + key + " actor=" + actorId +
             " reason=" + reason, 1);
        return true;
    }

    protected bool tryVehicleTarget(
            const array<const XmlElement@>@ characters, int factionId,
            const Vector3 &in vehiclePosition, string reason, int queryLimit) {
        if (characters is null) return false;
        // Finish processing cached actors even after the query budget is used.
        // Every attempt marks a new ID, so the loop cannot stall at the limit.
        while (true) {
            const XmlElement@ candidate = null;
            float best = 36.0f;
            for (uint i = 0; i < characters.length(); ++i) {
                int actorId = modIntAttribute(characters[i], "id");
                if (actorId < 0 || m_vehicleTriedActors.find(actorId) >= 0) continue;
                const XmlElement@ ally = resolveActor(characters[i], queryLimit);
                if (!canThrow(ally) ||
                    ally.getIntAttribute("faction_id") != factionId) continue;
                Vector3 actorPosition;
                if (!modTryVectorAttribute(ally, "position", actorPosition)) continue;
                float distance = getPositionDistance(actorPosition, vehiclePosition);
                if (distance <= best) {
                    best = distance;
                    @candidate = ally;
                }
            }
            if (candidate is null) break;
            m_vehicleTriedActors.insertLast(candidate.getIntAttribute("id"));
            if (throwSmoke(candidate, factionId, vehiclePosition, reason)) return true;
        }
        return false;
    }

    protected bool smokeAtVehicles(
            const array<const XmlElement@>@ characters) {
        if (characters is null) return false;
        array<Vector3> positions;
        array<int> owners;
        array<int> priorities;
        int unknownKeyLookups = 0;
        for (uint f = 0; f < m_factionIds.length(); ++f) {
            int ownerId = m_factionIds[f];
            array<const XmlElement@>@ vehicles =
                getAllVehicles(m_metagame, ownerId);
            if (vehicles is null) continue;
            for (uint v = 0; v < vehicles.length(); ++v) {
                const XmlElement@ vehicle = vehicles[v];
                Vector3 position;
                if (modIntAttribute(vehicle, "id") < 0 ||
                    !modTryVectorAttribute(vehicle, "position", position)) continue;
                if (vehicle.hasAttribute("health") &&
                    vehicle.getFloatAttribute("health") <= 0.0f) continue;
                int vehicleId = vehicle.getIntAttribute("id");
                string key = vehicle.getStringAttribute("key");
                if (key == "")
                    m_vehicleKeyCache.get("" + vehicleId, key);
                if (key != "" && vehiclePriority(key) == 0) continue;
                bool hasNearbyEnemy = false;
                for (uint c = 0; c < characters.length(); ++c) {
                    const XmlElement@ actor = characters[c];
                    if (!canThrow(actor) ||
                        actor.getIntAttribute("faction_id") == ownerId) continue;
                    Vector3 actorPosition;
                    if (!modTryVectorAttribute(actor, "position", actorPosition)) continue;
                    if (getPositionDistance(actorPosition, position) <= 36.0f) {
                        hasNearbyEnemy = true;
                        break;
                    }
                }
                if (!hasNearbyEnemy) continue;
                if (key == "" && unknownKeyLookups < 8) {
                    ++unknownKeyLookups;
                    const XmlElement@ info =
                        getVehicleInfo(m_metagame, vehicleId);
                    if (modIntAttribute(info, "id") == vehicleId)
                        key = info.getStringAttribute("key");
                    if (key != "")
                        m_vehicleKeyCache.set("" + vehicleId, key);
                }
                int priority = vehiclePriority(key);
                if (priority <= 0) continue;
                positions.insertLast(position);
                owners.insertLast(ownerId);
                priorities.insertLast(priority);
            }
        }

        m_vehicleTriedActors.resize(0);
        // Process higher target_factors tags first, then use the closest
        // eligible smoke carrier within 36 world units of that vehicle.
        for (int priority = 10; priority >= 2; priority -= 2) {
            for (uint v = 0; v < positions.length(); ++v) {
                if (priorities[v] != priority) continue;
                for (uint f = 0; f < m_factionIds.length(); ++f) {
                    int factionId = m_factionIds[f];
                    if (factionId == owners[v]) continue;
                    if (tryVehicleTarget(characters, factionId,
                            positions[v], "vehicle_nearby", 8))
                        return true;
                }
            }
        }
        return false;
    }

    protected void detectNewWounds(
            const array<const XmlElement@>@ characters) {
        if (characters is null) return;
        for (uint i = 0; i < characters.length(); ++i) {
            const XmlElement@ character = characters[i];
            if (!alive(character) || !character.hasAttribute("wounded")) continue;
            string id = "" + character.getIntAttribute("id");
            int wounded = character.getIntAttribute("wounded") != 0 ? 1 : 0;
            int previous = 0;
            m_woundedActors.get(id, previous);
            if (wounded != 0 && previous == 0 && m_woundBaselineReady) {
                Vector3 position;
                if (modTryVectorAttribute(character, "position", position))
                    recordHit(character.getIntAttribute("faction_id"),
                              position, position, false);
            }
            // A rotating sample must not clear wounds of unsampled actors.
            m_woundedActors.set(id, wounded);
        }
        m_woundBaselineReady = true;
    }

    protected bool reactToHits(
            const array<const XmlElement@>@ characters) {
        if (characters is null) return false;
        for (uint h = 0; h < m_hitFactions.length(); ++h) {
            int factionId = m_hitFactions[h];
            array<int> tried;
            for (int attempt = 0; attempt < 6; ++attempt) {
                const XmlElement@ candidate = null;
                float best = 12.0f;
                for (uint i = 0; i < characters.length(); ++i) {
                    const XmlElement@ ally = characters[i];
                    if (!canThrow(ally) ||
                        ally.getIntAttribute("faction_id") != factionId) continue;
                    int actorId = ally.getIntAttribute("id");
                    bool alreadyTried = false;
                    for (uint j = 0; j < tried.length(); ++j) {
                        if (tried[j] == actorId) alreadyTried = true;
                    }
                    if (alreadyTried) continue;
                    Vector3 actorPos;
                    if (!modTryVectorAttribute(ally, "position", actorPos)) continue;
                    float distance =
                        getPositionDistance(actorPos, m_hitPositions[h]);
                    if (distance <= best) {
                        best = distance;
                        @candidate = ally;
                    }
                }
                if (candidate is null) break;
                tried.insertLast(candidate.getIntAttribute("id"));
                Vector3 actorPos;
                if (!modTryVectorAttribute(candidate, "position", actorPos)) continue;
                Vector3 enemyPos = m_hitEnemyPositions[h];
                if (m_hitHasEnemy[h] == 0) {
                    const XmlElement@ enemy =
                        nearestEnemy(characters, factionId, actorPos, 1000000.0f);
                    if (enemy is null) break;
                    if (!modTryVectorAttribute(enemy, "position", enemyPos)) continue;
                }
                Vector3 destination = actorPos.add(
                    enemyPos.subtract(actorPos).scale(0.75f));
                if (throwSmoke(candidate, factionId, destination, "casualty"))
                    return true;
            }
        }
        return false;
    }

    protected bool attackEnemyBase(
            const array<const XmlElement@>@ characters,
            const array<const XmlElement@>@ bases) {
        if (characters is null || bases is null) return false;
        for (uint f = 0; f < m_factionIds.length(); ++f) {
            int factionId = m_factionIds[f];
            int baseId = m_attackBase[factionId];
            const XmlElement@ base = findBase(bases, baseId);
            if (base is null && baseId == -1)
                @base = findBase(bases, fallbackAttackBase(bases, factionId));
            int ownerId = modIntAttribute(base, "owner_id");
            Vector3 basePos;
            if (ownerId < 0 || ownerId == factionId ||
                !modTryVectorAttribute(base, "position", basePos)) continue;
            array<const XmlElement@> allies;
            for (uint i = 0; i < characters.length(); ++i) {
                const XmlElement@ ally = characters[i];
                if (!canThrow(ally) ||
                    ally.getIntAttribute("faction_id") != factionId) continue;
                Vector3 position;
                if (!modTryVectorAttribute(ally, "position", position)) continue;
                if (getPositionDistance(position, basePos) <= 64.0f)
                    allies.insertLast(ally);
            }
            if (allies.length() == 0) continue;
            uint searchCount = allies.length();
            if (searchCount > 10) searchCount = 10;
            uint start = uint(m_scanOffset[factionId]) % allies.length();
            m_scanOffset[factionId] =
                int((start + searchCount) % allies.length());
            for (uint k = 0; k < searchCount; ++k) {
                const XmlElement@ ally = allies[(start + k) % allies.length()];
                Vector3 actorPos;
                if (!modTryVectorAttribute(ally, "position", actorPos)) continue;
                const XmlElement@ enemy =
                    nearestEnemy(characters, factionId, actorPos, 64.0f);
                if (enemy is null) continue;
                Vector3 destination;
                if (!modTryVectorAttribute(enemy, "position", destination)) continue;
                if (throwSmoke(ally, factionId, destination, "attack"))
                    return true;
            }
        }
        return false;
    }

    bool hasStarted() const { return true; }
    bool hasEnded() const { return false; }

    void onAdd() {
        _log("TacticalSmokeAI: safe ID queries; 8s checks, 12-query rotating budget", 1);
    }

    void update(float time) {
        m_checkIn -= time;
        if (m_checkIn > 0.0f) return;
        m_checkIn = 8.0f;
        if (!loadFactions()) return;

        resetDetails();
        array<const XmlElement@> characters;
        sampleCharacters(characters);
        detectNewWounds(@characters);

        // A targetable enemy vehicle outranks the ordinary casualty and
        // assault triggers; the remaining query budget is shared with them.
        if (smokeAtVehicles(@characters)) {
            clearHits();
            return;
        }
        // One throw at most per broad check, without a cross-check cooldown.
        bool threw = reactToHits(@characters);
        clearHits();
        if (threw) return;
        array<const XmlElement@>@ bases = getBases(m_metagame);
        if (bases !is null)
            attackEnemyBase(@characters, bases);
    }
}
