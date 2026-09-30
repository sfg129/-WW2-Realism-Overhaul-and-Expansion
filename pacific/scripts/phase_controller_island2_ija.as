#include "phase_controller.as"
#include "query_helpers.as"
#include "spawn_in_base_call_handler.as"
#include "helpers2.as"

// Script-only requests still use the ordinary support handler's safe friendly
// base and generic-node selection. They never borrow a player's character ID.
class ScriptVehicleCallHandler : SpawnInBaseCallHandler {
    protected int m_scriptFactionId;

    ScriptVehicleCallHandler(GameMode@ metagame, string listenKey, string spawnKey,
                             int factionId, const array<string>@ excludedBases) {
        super(metagame, listenKey, spawnKey, excludedBases, true, "vehicle");
        m_scriptFactionId = factionId;
    }

    protected void handleCallRequestEvent(const XmlElement@ event) {
        if (event.getStringAttribute("call_key") != m_listenCallKey) return;
        if (event.getIntAttribute("faction_id") != m_scriptFactionId) {
            _log("Script vehicle support: rejected wrong faction for " + m_listenCallKey);
            return;
        }
        Vector3 requested = stringToVector3(event.getStringAttribute("target_position"));
        float distance = -1.0f;
        Vector3 spawnPosition;
        const XmlElement@ base = getClosestSafeBaseAndPosition(requested, m_scriptFactionId,
                                                               distance, spawnPosition);
        if (base is null) {
            _log("Script vehicle support: rejected " + m_listenCallKey + "; no safe friendly land base");
            return;
        }
        XmlElement command("command");
        command.setStringAttribute("class", "create_call");
        command.setStringAttribute("key", m_targetCallKey);
        command.setStringAttribute("position", spawnPosition.toString());
        command.setIntAttribute("faction_id", m_scriptFactionId);
        // A native script request may have no character_id (or an engine
        // placeholder). Only the explicit mission faction owns this support.
        m_metagame.getComms().send(command);
        _log("Script vehicle support: accepted " + m_listenCallKey + " at " + base.getStringAttribute("key"));
    }
}

// 0: prepare 120 s; 1: landing 180 s; 2: armor assault 300 s;
// 3: slowing assault 180 s; 4: recover all eight land bases, no time limit.
// action_step is a per-phase, saved cursor: never replay one-shot reinforcements.
class PhaseControllerIsland2IJA : PhaseController {
    protected GameModeInvasion@ m_metagame;
    protected bool m_started = false;
    protected bool m_finished = false;
    protected int m_phase = 0;
    protected float m_elapsed = 0.0f;
    protected uint m_actionStep = 0;
    protected uint m_commentsSent = 0;
    protected float m_baseCheckTimer = 0.0f;
    protected float m_assaultCheckTimer = 0.0f;
    protected string m_attackTargetKey;
    protected string m_attackStartKey;
    protected string m_counterattackTargetKey;
    protected string m_counterattackStartKey;
    protected Faction@ m_japanesePopulation;
    protected Faction@ m_americanPopulation;

    PhaseControllerIsland2IJA(GameModeInvasion@ metagame) {
        @m_metagame = metagame;
    }

    bool hasStarted() const { return m_started; }
    bool hasEnded() const { return m_finished; }

    void start() {
        m_phase = 0;
        m_elapsed = 0.0f;
        m_finished = false;
        m_actionStep = 0;
        m_commentsSent = 0;
        m_baseCheckTimer = 0.0f;
        m_assaultCheckTimer = 0.0f;
        m_attackTargetKey = "";
        m_attackStartKey = "";
        m_counterattackTargetKey = "";
        m_counterattackStartKey = "";
        m_started = true;
        applyPhaseSettings();
        announceDueComments();
        runDueActions();
        _log("Russell IJA defense: phase 0, preparation");
    }

    void onRemove() {
        // Reset only this stage's captured handles. MapRotator may already have
        // selected the next map before calling onRemove; never change its data.
        if (m_japanesePopulation !is null) {
            m_japanesePopulation.m_capacityMultiplier = 0.75f;
            m_japanesePopulation.m_capacityOffset = 0;
        }
        if (m_americanPopulation !is null) {
            m_americanPopulation.m_capacityMultiplier = 1.2f;
            m_americanPopulation.m_capacityOffset = 20;
        }
        @m_japanesePopulation = null;
        @m_americanPopulation = null;
        m_started = false;
    }

    void gameContinuePreStart() {
        // load() already restored time and one-shot state. Never replay calls.
        m_started = true;
        m_baseCheckTimer = 0.0f;
        m_assaultCheckTimer = 0.0f;
        m_attackTargetKey = "";
        m_attackStartKey = "";
        m_counterattackTargetKey = "";
        m_counterattackStartKey = "";
        if (!m_finished) applyPhaseSettings();
    }

    void update(float time) {
        if (!m_started || m_finished || time <= 0.0f) return;
        float frameTime = time;
        // Split large ticks at each phase boundary, preserving elapsed time.
        while (time > 0.0f && !m_finished) {
            float duration = phaseDuration();
            float step = time;
            if (m_phase < 4 && step > duration - m_elapsed)
                step = duration - m_elapsed;
            // Also split at reinforcement deadlines: a coarse tick cannot move
            // the preparation barrage to the landing phase or reorder waves.
            float deadline = nextActionTime();
            if (deadline >= m_elapsed && step > deadline - m_elapsed)
                step = deadline - m_elapsed;
            m_elapsed += step;
            time -= step;
            announceDueComments();
            runDueActions();
            if (m_phase < 4 && m_elapsed >= duration) {
                ++m_phase;
                m_elapsed = 0.0f;
                m_actionStep = 0;
                m_commentsSent = 0;
                applyPhaseSettings();
                _log("Russell IJA defense: phase " + m_phase);
                announceDueComments();
                runDueActions();
            }
        }
        if (m_phase > 0 && m_phase < 4) {
            m_assaultCheckTimer -= frameTime;
            if (m_assaultCheckTimer <= 0.0f) {
                m_assaultCheckTimer = 8.0f;
                // One small base query, not a per-soldier AI override. Only send
                // an order if the objective changed, avoiding attack restarts.
                setAmericanCommander(americanBaseDefense(), 0.0f, true, true);
                setJapaneseCommander(true);
            }
        } else if (m_phase == 4) {
            m_baseCheckTimer -= frameTime;
            // Check victory at most once per update, never query bases per AI.
            if (m_baseCheckTimer <= 0.0f) {
                m_baseCheckTimer = 2.0f;
                checkVictory();
                if (!m_finished) setJapaneseCommander(true);
            }
        }
    }

    protected float phaseDuration() const {
        if (m_phase == 0) return 120.0f;
        if (m_phase == 1) return 180.0f;
        if (m_phase == 2) return 300.0f;
        return 180.0f;
    }

    protected float nextActionTime() const {
        if (m_phase == 0 && m_actionStep == 0) return 110.0f;
        if (m_phase == 1 && m_actionStep < 2) return float(m_actionStep) * 90.0f;
        if (m_phase == 2 && m_actionStep < 3) {
            if (m_actionStep == 0) return 0.0f;
            if (m_actionStep == 1) return 120.0f;
            return 240.0f;
        }
        if (m_phase == 3 && m_actionStep == 0) return 0.0f;
        return -1.0f;
    }

    protected void runDueActions() {
        float deadline = nextActionTime();
        while (deadline >= 0.0f && m_elapsed >= deadline) {
            uint action = m_actionStep++;
            if (m_phase == 0) {
                createCall("artillery.call", basePosition("Beachhead", Vector3(754.7505f, 0, 770.6525f)));
            } else if (m_phase == 1) {
                if (action == 0) {
                    // Phase-zero end smoke and the landing share this boundary.
                    fireAtAttackTarget("artillery_smoke.call");
                    createCall("script_vehicle_higgins.call", Vector3(839, 0, 798));
                    createCall("script_vehicle_higgins.call", Vector3(804, 0, 851));
                }
                spawnLandingWaves();
                if (action == 1) fireAtAttackTarget("artillery.call");
            } else if (m_phase == 2) {
                if (action == 0) {
                    spawnTemporaryReinforcements();
                    createInstance("vehicle", "stuart.vehicle", Vector3(782.680f, 3.013f, 805.590f));
                } else {
                    // Normal support: safe friendly land base, never Carrier.
                    createCall("script_vehicle_m3_stuart.call", basePosition("Carrier", Vector3(857.21475f, 0, 839.061f)));
                }
                spawnLandingWaves();
            } else if (m_phase == 3) {
                fireAtAttackTarget("artillery.call");
            }
            deadline = nextActionTime();
        }
    }

    protected void spawnLandingWaves() {
        spawnLandingWave(Vector3(761.121f, 3.159f, 830.660f));
        spawnLandingWave(Vector3(831.036f, 3.515f, 762.110f));
    }

    protected void spawnLandingWave(const Vector3 &in position) {
        spawnSoldiers("regular", 4, position);
        spawnSoldiers("mg", 1, position);
        spawnSoldiers("veteran", 1, position);
        spawnSoldiers("assault", 6, position);
    }

    protected void spawnSoldiers(string group, uint count, const Vector3 &in position) {
        for (uint i = 0; i < count; ++i) createInstance("soldier", group, position);
    }

    protected void createInstance(string type, string key, const Vector3 &in position) {
        XmlElement command("command");
        command.setStringAttribute("class", "create_instance");
        command.setStringAttribute("instance_class", type);
        command.setStringAttribute("instance_key", key);
        command.setStringAttribute("position", position.toString());
        command.setStringAttribute("offset", "0 0 0");
        command.setIntAttribute("faction_id", 1);
        m_metagame.getComms().send(command);
    }

    protected void spawnTemporaryReinforcements() {
        // Russell USMC's ordinary spawn_score weights. Zero-score player,
        // call-only, medic and prisoner groups are deliberately excluded.
        array<string> groups = {"regular", "regular2", "assault", "assault2", "mg",
            "veteran", "veteran2", "sentry", "flamethrower_operator",
            "flamethrower_operator_veteran", "sniper"};
        array<float> weights = {0.5f, 0.3f, 0.06f, 0.04f, 0.2f, 0.08f,
            0.03f, 0.0075f, 0.0135f, 0.005f, 0.01f};
        float total = 0.0f;
        for (uint i = 0; i < weights.size(); ++i) total += weights[i];
        for (uint i = 0; i < 60; ++i) {
            float draw = rand(0.0f, total);
            uint index = weights.size() - 1;
            for (uint j = 0; j < weights.size(); ++j) {
                draw -= weights[j];
                if (draw <= 0.0f) { index = j; break; }
            }
            Vector3 position = i < 30 ? Vector3(761.121f, 3.159f, 830.660f) :
                                       Vector3(831.036f, 3.515f, 762.110f);
            createInstance("soldier", groups[index], position);
        }
    }

    protected void fireAtAttackTarget(string callKey) {
        // Read ownership at the request time, not a stale target from last tick.
        string targetKey, startKey;
        if (!findAmericanAttackTarget(targetKey, startKey) || targetKey == "") {
            _log("Russell defense: support skipped; no confirmed remaining attack target");
            return;
        }
        createCall(callKey, basePosition(targetKey, Vector3(754.7505f, 0, 770.6525f)));
    }

    protected void applyPhaseSettings() {
        applyPhasePopulation();
        // Faction.m_defaultCommanderAiCommand is only a stored preset. Explicitly
        // restore Japanese defense at start, each phase change and save resume.
        setJapaneseCommander();
        setAmericanCharge(m_phase == 1 ? 1.0f : (m_phase == 2 ? 0.9f : (m_phase == 3 ? 0.6f : 0.0f)));
        // Defense ratios alone do not stop the engine planning an attack.
        // Suspend the commander throughout preparation, activate at landing.
        if (m_phase == 0) setAmericanCommander(1.0f, 0.0f, false);
        else if (m_phase < 4) setAmericanCommander(americanBaseDefense(), 0.0f);
        else setAmericanCommander(0.8f, 0.2f);
        setJapaneseArtillery(m_phase == 4);
        m_metagame.getComms().send("<command class='update_base' base_key='Carrier' capturable='0' />");
        // Native HUD timer only displays time; custom_ignore_end prevents
        // automatic victory when it expires. The phase controller advances it.
        if (m_phase < 4) setVisualTimer(m_metagame, phaseDuration() - m_elapsed);
        else clearVisualTimer(m_metagame);
    }

    protected float americanBaseDefense() const {
        return m_phase == 1 ? 0.0f : (m_phase == 2 ? 0.1f : 0.2f);
    }

    protected void applyPhasePopulation() {
        float japanese = m_phase < 2 ? 0.75f : (m_phase == 2 ? 0.8f : (m_phase == 3 ? 0.85f : 1.1f));
        float american = m_phase < 2 ? 1.2f : (m_phase == 2 ? 1.4f : (m_phase == 3 ? 1.1f : 1.0f));
        int japaneseOffset = m_phase < 2 ? 0 : 20;
        const array<Faction@>@ factions = m_metagame.getFactions();
        if (factions.size() < 2) {
            _log("Russell defense: population metadata unavailable");
            return;
        }
        // These are the same Faction handles held by Stage/MapRotator. Updating
        // them prevents later settings refreshes from restoring initial values.
        @m_japanesePopulation = factions[0];
        @m_americanPopulation = factions[1];
        factions[0].m_capacityMultiplier = japanese;
        factions[0].m_capacityOffset = japaneseOffset;
        factions[1].m_capacityMultiplier = american;
        factions[1].m_capacityOffset = 20;
        XmlElement command("command");
        command.setStringAttribute("class", "change_game_settings");
        command.setIntAttribute("max_soldiers", 140);
        command.setFloatAttribute("soldier_capacity_variance", 0.2f);
        for (uint i = 0; i < 2; ++i) {
            XmlElement faction("faction");
            // Keep normal campaign difficulty/completion multipliers intact.
            faction.setFloatAttribute("capacity_multiplier",
                m_metagame.determineFinalFactionCapacityMultiplier(factions[i], i));
            faction.setIntAttribute("capacity_offset", factions[i].m_capacityOffset);
            command.appendChild(faction);
        }
        m_metagame.getComms().send(command);
    }

    protected array<string> attackBaseOrder() const {
        array<string> order = {"Beachhead", "Barracks", "Outpost",
            "Refueling Station", "Port", "Ridge Defenses", "Radar Station", "Coastal Battery"};
        return order;
    }

    protected bool findAmericanAttackTarget(string &out targetKey, string &out startKey) {
        targetKey = "";
        startKey = "";
        array<string> order = attackBaseOrder();
        array<const XmlElement@>@ bases = getBases(m_metagame);
        // Partial queries must neither erase a valid order nor misplace support.
        for (uint i = 0; i < order.size(); ++i) {
            bool found = false;
            for (uint j = 0; j < bases.size(); ++j)
                if (bases[j].getStringAttribute("key") == order[i]) { found = true; break; }
            if (!found) return false;
        }
        startKey = "Carrier";
        for (uint i = 0; i < order.size(); ++i) {
            bool owned = false;
            for (uint j = 0; j < bases.size(); ++j) {
                if (bases[j].getStringAttribute("key") == order[i] &&
                    bases[j].getIntAttribute("owner_id") == 1) { owned = true; break; }
            }
            if (!owned) { targetKey = order[i]; break; }
            startKey = order[i];
        }
        if (targetKey == "") startKey = "";
        return true;
    }

    protected bool findJapaneseCounterattack(string &out startKey, string &out targetKey) {
        startKey = "";
        targetKey = "";
        array<string> order = attackBaseOrder();
        array<const XmlElement@>@ bases = getBases(m_metagame);
        array<int> owners(order.size(), -1);
        for (uint i = 0; i < order.size(); ++i) {
            for (uint j = 0; j < bases.size(); ++j) {
                if (bases[j].getStringAttribute("key") == order[i]) {
                    owners[i] = bases[j].getIntAttribute("owner_id");
                    break;
                }
            }
            if (owners[i] < 0) return false;
        }
        // The first Japanese base beyond the American-held prefix is the
        // current assault target; its predecessor is the counterattack target.
        for (uint i = 1; i < order.size(); ++i) {
            if (owners[i] == 0 && owners[i - 1] == 1) {
                startKey = order[i];
                targetKey = order[i - 1];
                return true;
            }
        }
        // If Beachhead was retaken out of sequence, do not fall back to the
        // uncapturable Carrier. Advance toward the first US-held land base.
        if (owners[0] == 0) {
            for (uint i = 1; i < order.size(); ++i) {
                if (owners[i] == 1) {
                    startKey = order[0];
                    targetKey = order[i];
                    return true;
                }
            }
        }
        return true;
    }

    protected void setAmericanCommander(float baseDefense, float borderDefense,
                                       bool active = true, bool onlyIfTargetChanged = false) {
        string targetKey = "";
        string startKey = "";
        bool assault = active && m_phase > 0 && m_phase < 4;
        if (assault && !findAmericanAttackTarget(targetKey, startKey)) {
            _log("Russell defense: incomplete base query; retaining assault order");
            return;
        }
        if (onlyIfTargetChanged && targetKey == m_attackTargetKey && startKey == m_attackStartKey) return;
        if (targetKey != m_attackTargetKey || startKey != m_attackStartKey)
            _log("Russell defense: US assault " + startKey + " -> " + targetKey);
        m_attackTargetKey = targetKey;
        m_attackStartKey = startKey;
        XmlElement command("command");
        command.setStringAttribute("class", "commander_ai");
        command.setIntAttribute("faction", 1);
        command.setFloatAttribute("base_defense", baseDefense);
        command.setFloatAttribute("border_defense", borderDefense);
        command.setBoolAttribute("active", active);
        command.setStringAttribute("attack_target_base_key", targetKey);
        command.setFloatAttribute("start_attack_break_time", 0.0f);
        command.setFloatAttribute("attack_break_time", 0.0f);
        command.setIntAttribute("attack_start_spread", assault ? 0 : 2);
        command.setIntAttribute("attack_target_spread", assault ? 0 : 2);
        command.setFloatAttribute("side_base_attack_probability", 0.0f);
        // Prevent the engine's last-base assault boost from altering the ratios.
        command.setBoolAttribute("reduce_defense_for_final_attack", false);
        command.setBoolAttribute("reduce_border_soldier_count_for_attack_boost", false);
        m_metagame.getComms().send(command);
        m_assaultCheckTimer = 8.0f;
    }

    protected void setAmericanCharge(float value) {
        XmlElement command("command");
        command.setStringAttribute("class", "soldier_ai");
        command.setIntAttribute("faction", 1);
        XmlElement parameter("parameter");
        parameter.setStringAttribute("class", "willingness_to_charge");
        parameter.setFloatAttribute("value", value);
        command.appendChild(parameter);
        m_metagame.getComms().send(command);
    }

    protected void setJapaneseCommander(bool onlyIfTargetChanged = false) {
        string startKey = "";
        string targetKey = "";
        if (m_phase > 0 && !findJapaneseCounterattack(startKey, targetKey)) {
            // A partial base query must not erase a valid counterattack order.
            startKey = m_counterattackStartKey;
            targetKey = m_counterattackTargetKey;
        }
        if (onlyIfTargetChanged && startKey == m_counterattackStartKey &&
            targetKey == m_counterattackTargetKey) return;
        if (startKey != m_counterattackStartKey || targetKey != m_counterattackTargetKey)
            _log("Russell defense: IJA counterattack " + startKey + " -> " + targetKey);
        m_counterattackStartKey = startKey;
        m_counterattackTargetKey = targetKey;
        XmlElement command("command");
        command.setStringAttribute("class", "commander_ai");
        command.setIntAttribute("faction", 0);
        command.setFloatAttribute("base_defense", m_phase == 4 ? 0.0f : 0.9f);
        command.setFloatAttribute("border_defense", 0.1f);
        command.setBoolAttribute("active", true);
        command.setStringAttribute("attack_target_base_key", targetKey);
        // Neither final-target nor border-defense boosts may free attackers
        // from the 90/10 defense allocation. Keep native defensive AI active.
        command.setBoolAttribute("reduce_defense_for_final_attack", false);
        command.setBoolAttribute("reduce_border_soldier_count_for_attack_boost", false);
        m_metagame.getComms().send(command);
    }

    protected void setJapaneseArtillery(bool enabled) {
        XmlElement command("command");
        command.setStringAttribute("class", "faction_resources");
        command.setIntAttribute("faction_id", 0);
        array<string> keys = {"artillery.call", "artillery1.call"};
        for (uint i = 0; i < keys.size(); ++i) {
            XmlElement call("call");
            call.setStringAttribute("key", keys[i]);
            call.setBoolAttribute("enabled", enabled);
            command.appendChild(call);
        }
        m_metagame.getComms().send(command);
    }

    protected void announceDueComments() {
        uint count = m_phase == 0 ? 4 : (m_phase == 4 ? 3 : 2);
        while (m_commentsSent < count && m_elapsed >= float(m_commentsSent) * 5.0f) {
            ++m_commentsSent;
            string group = m_phase == 0 ? "prepare" : (m_phase == 1 ? "landing" :
                (m_phase == 2 ? "armor" : (m_phase == 3 ? "naval approaching" : "naval support")));
            sendFactionMessageKey(m_metagame, 0,
                "russell ija defense, " + group + " " + m_commentsSent, dictionary = {}, 1.0f);
        }
    }

    protected Vector3 basePosition(string key, const Vector3 &in fallback) {
        array<const XmlElement@>@ bases = getBases(m_metagame);
        for (uint i = 0; i < bases.size(); ++i) {
            string current = bases[i].getStringAttribute("key");
            if (current == key || (key == "Carrier" && current == "Attack Ship")) {
                array<string> parts = bases[i].getStringAttribute("position").split(" ");
                if (parts.size() == 3)
                    return Vector3(parseFloat(parts[0]), parseFloat(parts[1]), parseFloat(parts[2]));
                break;
            }
        }
        _log("Russell defense: base missing, using SVG center for " + key);
        return fallback;
    }

    protected void createCall(string key, const Vector3 &in position) {
        XmlElement command("command");
        command.setStringAttribute("class", "create_call");
        command.setStringAttribute("key", key);
        command.setStringAttribute("position", position.toString());
        command.setIntAttribute("faction_id", 1);
        m_metagame.getComms().send(command);
        _log("Russell defense: US scripted call " + key + " at " + position.toString());
    }

    protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
        if (!m_started || m_finished) return;
        if (m_phase == 4) {
            checkVictory();
            if (!m_finished) setJapaneseCommander(true);
        } else if (m_phase > 0) {
            setAmericanCommander(americanBaseDefense(), 0.0f);
            setJapaneseCommander(true);
        }
    }

    protected void checkVictory() {
        // Explicit expected keys avoid winning on an empty/partial query.
        array<string> landBases = {"Beachhead", "Barracks", "Outpost",
            "Refueling Station", "Port", "Ridge Defenses", "Radar Station", "Coastal Battery"};
        array<const XmlElement@>@ bases = getBases(m_metagame);
        for (uint i = 0; i < landBases.size(); ++i) {
            bool owned = false;
            for (uint j = 0; j < bases.size(); ++j) {
                if (bases[j].getStringAttribute("key") == landBases[i] &&
                    bases[j].getIntAttribute("owner_id") == 0) { owned = true; break; }
            }
            if (!owned) return;
        }
        m_finished = true;
        m_metagame.getComms().send("<command class='set_match_status' faction_id='1' lose='1' />");
        m_metagame.getComms().send("<command class='set_match_status' faction_id='0' win='1' />");
    }

    protected void handleFactionLoseEvent(const XmlElement@ event) {
        const XmlElement@ condition = event.getFirstElementByTagName("lose_condition");
        if (condition !is null && condition.getIntAttribute("faction_id") == 0) {
            m_metagame.removeTracker(this);
            m_started = false;
        }
    }

    void save(XmlElement@ root) {
        XmlElement state("map_phase_controller_island2_ija");
        state.setIntAttribute("version", 3);
        state.setIntAttribute("phase", m_phase);
        state.setFloatAttribute("elapsed", m_elapsed);
        state.setIntAttribute("action_step", m_actionStep);
        state.setIntAttribute("comments_sent", m_commentsSent);
        state.setBoolAttribute("finished", m_finished);
        root.appendChild(state);
    }

    void load(const XmlElement@ root) {
        const XmlElement@ state = root.getFirstElementByTagName("map_phase_controller_island2_ija");
        if (state is null) return; // Old saves begin the new preparation phase.
        m_phase = state.getIntAttribute("phase");
        int version = state.hasAttribute("version") ? state.getIntAttribute("version") : 0;
        bool legacy = version < 2;
        // The old four-phase mission's phase 3 was already the counterattack.
        if (legacy && m_phase == 3) m_phase = 4;
        if (m_phase < 0 || m_phase > 4) m_phase = 0;
        m_elapsed = state.getFloatAttribute("elapsed");
        if (m_elapsed < 0.0f) m_elapsed = 0.0f;
        if (m_phase < 4 && m_elapsed > phaseDuration()) m_elapsed = phaseDuration();
        if (legacy) {
            // Skip newly added events whose deadlines already passed; never
            // replay fleet, armor, or the new 60-man boost on an old save.
            m_actionStep = 0;
            while (nextActionTime() >= 0.0f && nextActionTime() <= m_elapsed) ++m_actionStep;
        } else {
            int action = state.getIntAttribute("action_step");
            // Version 2 had an extra phase-2 smoke event at +180 seconds.
            // Remove its cursor slot, retaining the pending +240 second tank
            // call and never replaying the initial 60-man reinforcement.
            if (version == 2 && m_phase == 2 && action >= 3) --action;
            array<int> actionCounts = {1, 2, 3, 1, 0};
            if (action < 0) action = 0;
            if (action > actionCounts[m_phase]) action = actionCounts[m_phase];
            m_actionStep = uint(action);
        }
        int comments = state.getIntAttribute("comments_sent");
        if (comments < 0) comments = 0;
        if (comments > 4) comments = 4;
        m_commentsSent = uint(comments);
        m_finished = state.getBoolAttribute("finished");
    }
}
