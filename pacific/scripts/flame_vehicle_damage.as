#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "log.as"

// Centralized percentage-damage rules. The current flamethrower contact cadence
// is 0.06 seconds; the global 2x damage pass makes each accepted contact apply
// DPS * 0.06 * 2.0 max health.
class FlameVehicleRule {
	string m_key;
	float m_damageFractionPerHit;
	float m_rightOffset;
	float m_forwardOffset;
	float m_halfWidth;
	float m_halfLength;

	FlameVehicleRule(string key, float damagePerSecond, float rightOffset, float forwardOffset, float width, float length) {
		m_key = key;
		m_damageFractionPerHit = damagePerSecond * 0.06f * 2.0f;
		m_rightOffset = rightOffset;
		m_forwardOffset = forwardOffset;
		m_halfWidth = width * 0.5f;
		m_halfLength = length * 0.5f;
	}
}

class FlameVehicleTarget {
	int m_id;
	FlameVehicleRule@ m_rule;
	Vector3 m_position;
	Vector3 m_forward;
	Vector3 m_right;
	bool m_valid;
	bool m_seen;
	bool m_hasOrientation;
	uint m_pendingHits;

	FlameVehicleTarget(int id, FlameVehicleRule@ rule) {
		m_id = id;
		@m_rule = @rule;
		m_position = Vector3(0, 0, 0);
		m_forward = Vector3(0, 0, 1);
		m_right = Vector3(1, 0, 0);
		m_valid = false;
		m_seen = false;
		m_hasOrientation = false;
		m_pendingHits = 0;
	}
}

class FlameShooterFaction {
	int m_characterId;
	int m_factionId;
	FlameShooterFaction(int characterId, int factionId) {
		m_characterId = characterId;
		m_factionId = factionId;
	}
}

class FlameBlastEmitter {
	int m_characterId;
	int m_factionId;
	string m_projectileKey;
	Vector3 m_pendingPosition;
	float m_cooldown;
	float m_idleTime;
	bool m_pending;

	FlameBlastEmitter(int characterId, int factionId, string projectileKey) {
		m_characterId = characterId;
		m_factionId = factionId;
		m_projectileKey = projectileKey;
		m_pendingPosition = Vector3(0, 0, 0);
		m_cooldown = 0.0f;
		m_idleTime = 0.0f;
		m_pending = false;
	}
}

class FlameVehicleDamage : Tracker {
	protected Metagame@ m_metagame;
	protected array<FlameVehicleRule@> m_rules;
	protected array<FlameVehicleTarget@> m_targets;
	protected array<int> m_ignoredVehicleIds;
	protected array<int> m_pendingClassificationIds;
	protected array<FlameShooterFaction@> m_shooterFactions;
	protected array<FlameBlastEmitter@> m_blastEmitters;
	protected float m_refreshTimer = 0.0f;
	protected float m_refreshInterval = 0.25f;
	protected int m_nextFactionId = 0;
	protected float m_classificationTimer = 0.0f;
	protected float m_classificationInterval = 0.10f;
	protected float m_damageTimer = 0.0f;
	protected float m_damageInterval = 0.25f;
	protected float m_helperBlastInterval = 0.12f;
	protected bool m_loggedFirstResult = false;
	protected bool m_loggedFirstDamage = false;

	FlameVehicleDamage(Metagame@ metagame) {
		@m_metagame = @metagame;
		initRules();
	}

	protected void addRule(string key, float damagePerSecond, float rightOffset, float forwardOffset, float width, float length) {
		m_rules.insertLast(FlameVehicleRule(key, damagePerSecond, rightOffset, forwardOffset, width, length));
	}

	protected void addRuleGroup(const array<string>@ keys, float damagePerSecond, float rightOffset, float forwardOffset, float width, float length) {
		for (uint i = 0; i < keys.length(); ++i) {
			addRule(keys[i], damagePerSecond, rightOffset, forwardOffset, width, length);
		}
	}

	protected void initRules() {
		// 1%/s: 1000-health cargo/repair tanks.
		addRuleGroup(array<string> = {"cargo_tank.vehicle", "repair_tank_base.vehicle"}, 0.01f, 0.0f, 0.0f, 5.0f, 7.8f);

		// 6.5%/s: 54-health repair tank, Maus, TOG, Churchills, Tigers and M4A3E2s.
		addRule("repair_tank.vehicle", 0.065f, 0.0f, 0.0f, 5.0f, 7.8f);
		addRule("maus_boss.vehicle", 0.065f, 0.0f, 0.0f, 5.1f, 12.5f);
		addRule("tog2_boss.vehicle", 0.065f, 0.0f, 0.0f, 4.0f, 12.6f);
		addRuleGroup(array<string> = {"churchill_mkvii.vehicle", "churchill_crocodile.vehicle"}, 0.065f, 0.0f, -0.35f, 4.2f, 8.3f);
		addRuleGroup(array<string> = {"tiger.vehicle", "tiger_sicily.vehicle"}, 0.065f, 0.0f, 0.0f, 5.0f, 7.6f);
		addRuleGroup(array<string> = {"king_tiger.vehicle", "king_tiger_player.vehicle", "king_tiger_boss.vehicle"}, 0.065f, 0.0f, -0.3f, 5.3f, 8.9f);
		addRuleGroup(array<string> = {"m4a3e2_75.vehicle", "m4a3e2_76.vehicle"}, 0.065f, 0.0f, -0.1916f, 3.9f, 6.8f);

		// 8.25%/s: non-E2 76 mm Shermans, Firefly, Panther and Panzer IVs.
		addRuleGroup(array<string> = {"m4_76.vehicle", "m4_76_late.vehicle", "m4a3e8.vehicle"}, 0.0825f, 0.0f, -0.1916f, 3.9f, 6.8f);
		addRuleGroup(array<string> = {"m4_firefly.vehicle", "m4_firefly_fastrespawn.vehicle"}, 0.0825f, 0.0f, -0.1916f, 3.9f, 6.8f);
		addRule("panther.vehicle", 0.0825f, 0.0f, -0.5f, 4.312f, 7.82f);
		addRuleGroup(array<string> = {"panzer_iv.vehicle", "panzer_iv_fastrespawn.vehicle", "panzer_iv_damaged.vehicle", "panzer_iv_base_flak88.vehicle"}, 0.0825f, 0.0f, 0.0f, 4.2f, 7.2f);

		// 9.25%/s: non-E2 75 mm Shermans and StuG III.
		addRuleGroup(array<string> = {"m4_75.vehicle", "m4_75_late.vehicle", "m4_V.vehicle", "m4_V_fastrespawn.vehicle", "m4_rhino.vehicle", "m4_E4.vehicle"}, 0.0925f, 0.0f, -0.1916f, 3.9f, 6.8f);
		addRuleGroup(array<string> = {"stug_iii.vehicle", "stug_iii_fastrespawn.vehicle"}, 0.0925f, 0.0f, 0.0f, 4.2f, 7.4f);

		// 7.5%/s: armed patrol boats.
		addRule("pt_boat.vehicle", 0.075f, 0.0f, -0.7f, 5.0f, 20.0f);
		addRule("soukoutei.vehicle", 0.075f, 0.0f, -0.5f, 4.7f, 19.0f);

		// 5%/s: submarines.
		addRuleGroup(array<string> = {"submarine.vehicle", "submarine2.vehicle"}, 0.05f, 0.0f, 0.0f, 3.6f, 35.0f);

		// 12%/s: M5A1 Stuart, M10 Wolverine and Luchs.
		addRule("m5a1_stuart.vehicle", 0.12f, 0.0f, -0.15f, 3.5f, 5.4f);
		addRule("m10.vehicle", 0.12f, 0.0f, 0.0f, 3.9f, 7.8f);
		addRule("luchs.vehicle", 0.12f, 0.0f, -0.1f, 3.6f, 6.0f);

		// 15%/s: M3 Stuart, Chi-Ha variants and Sherman fortified turret.
		addRuleGroup(array<string> = {"stuart.vehicle", "stuart_damaged.vehicle", "stuart_recce.vehicle"}, 0.15f, 0.0f, -0.15f, 3.5f, 5.4f);
		addRuleGroup(array<string> = {"chi_ha.vehicle", "chi_ha_early.vehicle"}, 0.15f, 0.0f, -0.1f, 3.35f, 7.0f);
		addRule("fortified_turret_sherman.vehicle", 0.15f, 0.0f, 0.0f, 3.6f, 3.2f);

		// 20%/s: pillboxes and Chi-Ha fortified turret.
		addRuleGroup(array<string> = {"pillbox.vehicle", "pillbox1.vehicle"}, 0.20f, 0.0f, 0.0f, 3.3f, 3.3f);
		addRule("fortified_turret_chi_ha.vehicle", 0.20f, 0.0f, 0.0f, 3.6f, 3.2f);

		// 25%/s: light armour, halftracks, carriers and amphibious tracked vehicles.
		addRuleGroup(array<string> = {"hago.vehicle", "hago_damaged.vehicle"}, 0.25f, 0.0f, 0.1f, 3.1f, 5.9f);
		addRuleGroup(array<string> = {"m3_halftrack.vehicle", "m3_halftrack_fastrespawn.vehicle", "m3_halftrack_mortar.vehicle"}, 0.25f, 0.0f, -0.1f, 3.3f, 7.75f);
		addRuleGroup(array<string> = {"universal_carrier.vehicle", "universal_carrier_fastrespawn.vehicle", "universal_carrier_boys.vehicle", "universal_carrier_vickers_k.vehicle", "wasp.vehicle"}, 0.25f, 0.0f, 0.0f, 2.75f, 4.2f);
		addRuleGroup(array<string> = {"sdkfz251.vehicle", "sdkfz251_fastrespawn.vehicle", "sdkfz251_mortar.vehicle", "sdkfz251_pak40.vehicle", "sdkfz251_flak.vehicle"}, 0.25f, 0.0f, -0.5f, 3.3f, 7.75f);
		addRule("hoha.vehicle", 0.25f, 0.0f, 0.0f, 3.0f, 8.0f);
		addRule("katsu.vehicle", 0.25f, 0.0f, -0.2f, 3.8f, 11.15f);
		addRule("lvt4.vehicle", 0.25f, 0.0f, 0.0f, 4.3f, 9.0f);

		// 25%/s: supply/armoury trucks and landing craft.
		addRule("austin_k5_armoury.vehicle", 0.25f, 0.0f, -0.1f, 3.3f, 7.7f);
		addRule("opel_blitz_armoury.vehicle", 0.25f, 0.0f, -0.48f, 3.5f, 8.6f);
		addRule("dukw.vehicle", 0.25f, 0.0f, 0.3f, 3.3f, 10.05f);
		addRule("suki.vehicle", 0.25f, 0.0f, -0.58f, 3.5f, 9.8f);
		addRule("armory_higgins.vehicle", 0.25f, 0.0f, 0.0f, 3.8f, 13.0f);
		addRule("armory_daihatsu.vehicle", 0.25f, 0.0f, 0.0f, 3.8f, 14.0f);

		// 25%/s: destructible support structures and field armoury.
		addRule("water_tower.vehicle", 0.25f, 0.0f, 0.0f, 3.5f, 3.5f);
		addRule("usf_armoury_para.vehicle", 0.25f, 0.0f, 0.0f, 1.62f, 3.06f);
		addRule("gas_tank.vehicle", 0.25f, 0.0f, 0.0f, 2.3f, 6.6f);
		addRule("dumpster.vehicle", 0.25f, 0.0f, 0.0f, 2.8f, 1.9f);
		addRule("cover1.vehicle", 0.25f, 0.0f, 0.0f, 3.0f, 1.2f);
		addRule("radar_tower.vehicle", 0.25f, 0.0f, 0.0f, 1.2f, 1.2f);

		// 40%/s: HMGs.
		addRuleGroup(array<string> = {
			"m1917_hmg.vehicle", "m1917_hmg_t.vehicle", "m1919_hmg.vehicle", "m1919_hmg_t.vehicle",
			"m2hb_hmg.vehicle", "m2hb_hmg_t.vehicle", "mg34_hmg.vehicle", "mg34_hmg_t.vehicle",
			"mg42_hmg.vehicle", "mg42_hmg_t.vehicle", "mg42_hmg_universal.vehicle",
			"type92_hmg.vehicle", "type92_hmg_t.vehicle", "vickers_hmg.vehicle", "vickers_hmg_t.vehicle"
		}, 0.40f, 0.0f, 0.0f, 1.2f, 1.5f);

		// 40%/s: AT guns, mortars, AA guns and other emplaced guns.
		addRuleGroup(array<string> = {
			"at_gun_m1_57mm.vehicle", "at_gun_qf6.vehicle", "at_gun_m3_37mm.vehicle", "at_gun_m5.vehicle",
			"at_gun_pak40.vehicle", "at_gun_pak40_2.vehicle", "light_mortar.vehicle", "light_mortar1.vehicle",
			"heavy_mortar.vehicle", "5inch_gun.vehicle", "aa_gun.vehicle", "aa_gun2.vehicle", "bofors.vehicle",
			"coastal_gun.vehicle", "coastal_gun2.vehicle", "coastal_gun3.vehicle", "flak_88.vehicle", "lefh18.vehicle",
			"normandy_turret.vehicle", "oerlikon.vehicle", "type98.vehicle", "b29_turret.vehicle", "b29_turret_rear.vehicle"
		}, 0.40f, 0.0f, 0.0f, 1.5f, 2.0f);

		// 50%/s: jeeps, small cars and troop trucks.
		addRule("jeep.vehicle", 0.50f, 0.0f, -0.2f, 2.0f, 4.4f);
		addRule("jeep1.vehicle", 0.50f, 0.0f, -0.2f, 2.2f, 4.8f);
		addRule("kubelwagen.vehicle", 0.50f, 0.0f, 0.0f, 2.2f, 4.8f);
		addRuleGroup(array<string> = {"willys_mb.vehicle", "willys_mb_recoilless_rifle.vehicle"}, 0.50f, 0.0f, -0.2f, 2.0f, 4.4f);
		addRule("staff_car.vehicle", 0.50f, 0.0f, 0.12f, 2.4f, 6.45f);
		addRule("sidecar_german.vehicle", 0.50f, 0.0f, -0.2f, 1.8f, 2.5f);
		addRule("tractor.vehicle", 0.50f, 0.0f, 0.0f, 2.56f, 5.2f);
		addRule("austin_k5.vehicle", 0.50f, 0.0f, -0.1f, 3.3f, 7.7f);
		addRule("opel_blitz_1.vehicle", 0.50f, 0.0f, -0.48f, 3.5f, 8.6f);
		addRule("opel_blitz_2.vehicle", 0.50f, 0.0f, -0.48f, 3.5f, 8.6f);
		addRule("deco_allied_truck.vehicle", 0.50f, 0.0f, 0.0f, 3.5f, 8.6f);

		// 50%/s: ordinary landing craft.
		addRuleGroup(array<string> = {"landing_craft.vehicle", "landing_craft_noai.vehicle"}, 0.50f, 0.0f, 0.0f, 3.8f, 13.0f);
		addRuleGroup(array<string> = {"landing_craft1.vehicle", "landing_craft1_noai.vehicle"}, 0.50f, 0.0f, 0.0f, 3.8f, 14.0f);
		addRule("rubber_boat.vehicle", 0.50f, 0.0f, -0.2f, 3.4f, 5.3f);

		// 50%/s: repair/ammunition crates and prison structures.
		addRule("crate_wrench.vehicle", 0.50f, 0.0f, 0.0f, 2.0f, 1.4f);
		addRule("mortar_ammunition_crates.vehicle", 0.50f, 0.0f, 0.0f, 3.0f, 3.0f);
		addRule("prison_building.vehicle", 0.50f, 0.0f, 0.0f, 5.0f, 8.0f);
		addRule("prison_door.vehicle", 0.50f, 0.0f, 0.0f, 2.0f, 2.0f);

		// 50%/s: all colour variants of the drivable decoration-car models.
		addRuleGroup(array<string> = {
			"deco_coupe_beige.vehicle", "deco_coupe_blue.vehicle", "deco_coupe_broken.vehicle", "deco_coupe_green.vehicle", "deco_coupe_grey.vehicle", "deco_coupe_red.vehicle",
			"deco_sedan_black.vehicle", "deco_sedan_blue.vehicle", "deco_sedan_broken.vehicle", "deco_sedan_green.vehicle", "deco_sedan_red.vehicle", "deco_sedan_white1.vehicle", "deco_sedan_white2.vehicle",
			"deco_pickup_blue.vehicle", "deco_pickup_broken.vehicle", "deco_pickup_brown.vehicle", "deco_pickup_green.vehicle", "deco_pickup_grey.vehicle", "deco_pickup_khaki.vehicle", "deco_pickup_red.vehicle", "deco_pickup_yellow.vehicle"
		}, 0.50f, 0.0f, 0.0f, 2.5f, 5.0f);
		addRuleGroup(array<string> = {
			"deco_car1_black.vehicle", "deco_car1_blue.vehicle", "deco_car1_broken.vehicle", "deco_car1_brown.vehicle", "deco_car1_green.vehicle", "deco_car1_pink.vehicle", "deco_car1_red.vehicle", "deco_car1_white.vehicle", "deco_car1_yellow.vehicle",
			"deco_car2_black.vehicle", "deco_car2_blue.vehicle", "deco_car2_broken.vehicle", "deco_car2_brown.vehicle", "deco_car2_green.vehicle", "deco_car2_grey.vehicle", "deco_car2_red.vehicle", "deco_car2_silver.vehicle", "deco_car2_white.vehicle", "deco_car2_yellow.vehicle",
			"deco_car3_black.vehicle", "deco_car3_blue.vehicle", "deco_car3_broken.vehicle", "deco_car3_green.vehicle", "deco_car3_red.vehicle", "deco_car3_sky.vehicle", "deco_car3_yellow.vehicle",
			"deco_van_blue.vehicle", "deco_van_broken.vehicle", "deco_van_brown.vehicle", "deco_van_green.vehicle", "deco_van_khaki.vehicle", "deco_van_red.vehicle", "deco_van_sky.vehicle", "deco_van_yellow.vehicle"
		}, 0.50f, 0.0f, 0.0f, 2.5f, 5.0f);
	}

	void onAdd() {
		refreshNextFactionTargets();
		m_refreshTimer = m_refreshInterval;
		_log("FlameVehicleDamage: active with " + m_rules.length() + " configured vehicle keys; staggered queries v5", 1);
	}

	protected FlameVehicleRule@ findRule(string key) const {
		for (uint i = 0; i < m_rules.length(); ++i) {
			if (m_rules[i].m_key == key) return m_rules[i];
		}
		return null;
	}

	protected int findTarget(int id) const {
		for (uint i = 0; i < m_targets.length(); ++i) {
			if (m_targets[i].m_id == id) return int(i);
		}
		return -1;
	}

	protected int findIgnoredVehicle(int id) const {
		return m_ignoredVehicleIds.find(id);
	}

	protected void forgetIgnoredVehicle(int id) {
		int index = findIgnoredVehicle(id);
		if (index >= 0) m_ignoredVehicleIds.removeAt(index);
	}

	protected int findPendingClassification(int id) const {
		return m_pendingClassificationIds.find(id);
	}

	protected void forgetPendingClassification(int id) {
		int index = findPendingClassification(id);
		if (index >= 0) m_pendingClassificationIds.removeAt(index);
	}

	protected void queueVehicleForClassification(int id) {
		if (id >= 0 && findTarget(id) < 0 && findIgnoredVehicle(id) < 0 && findPendingClassification(id) < 0) {
			m_pendingClassificationIds.insertLast(id);
		}
	}

	protected void addTarget(int id, FlameVehicleRule@ rule) {
		if (id >= 0 && rule !is null && findTarget(id) < 0) {
			m_targets.insertLast(FlameVehicleTarget(id, rule));
			if (rule.m_key == "stug_iii.vehicle" || rule.m_key == "stug_iii_fastrespawn.vehicle") {
				_log("FlameVehicleDamage: tracking StuG III id=" + id + " key=" + rule.m_key, 1);
			}
		}
	}

	protected array<const XmlElement@>@ getFactionVehicles(int factionId) {
		XmlElement@ query = XmlElement(
			makeQuery(m_metagame, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "vehicles"}, {"faction_id", factionId} }
			}));
		const XmlElement@ doc = m_metagame.getComms().query(query);
		if (doc !is null) return doc.getElementsByTagName("vehicle");
		array<const XmlElement@> empty;
		return @empty;
	}

	protected int getShooterFaction(int characterId) {
		if (characterId < 0) return -1;
		for (uint i = 0; i < m_shooterFactions.length(); ++i) {
			if (m_shooterFactions[i].m_characterId == characterId) return m_shooterFactions[i].m_factionId;
		}
		const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
		if (info is null) return -1;
		int factionId = info.getIntAttribute("faction_id");
		m_shooterFactions.insertLast(FlameShooterFaction(characterId, factionId));
		return factionId;
	}

	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		int id = event.getIntAttribute("vehicle_id");
		forgetIgnoredVehicle(id);
		forgetPendingClassification(id);
		FlameVehicleRule@ rule = findRule(event.getStringAttribute("vehicle_key"));
		if (rule !is null) {
			addTarget(id, rule);
		} else if (findIgnoredVehicle(id) < 0) {
			m_ignoredVehicleIds.insertLast(id);
		}
	}

	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		int id = event.getIntAttribute("vehicle_id");
		int index = findTarget(id);
		if (index >= 0) m_targets.removeAt(index);
		forgetIgnoredVehicle(id);
		forgetPendingClassification(id);
	}

	protected bool eventTouchesTarget(const Vector3@ hitPosition, const FlameVehicleTarget@ target, float blastRadius) const {
		FlameVehicleRule@ rule = target.m_rule;
		if (!target.m_hasOrientation) {
			float reach = rule.m_halfLength;
			if (rule.m_halfWidth > reach) reach = rule.m_halfWidth;
			reach += abs(rule.m_rightOffset) + abs(rule.m_forwardOffset) + blastRadius;
			float dx = hitPosition.get_opIndex(0) - target.m_position.get_opIndex(0);
			float dz = hitPosition.get_opIndex(2) - target.m_position.get_opIndex(2);
			return dx * dx + dz * dz <= reach * reach;
		}
		float centerX = target.m_position.get_opIndex(0) + target.m_right.get_opIndex(0) * rule.m_rightOffset + target.m_forward.get_opIndex(0) * rule.m_forwardOffset;
		float centerZ = target.m_position.get_opIndex(2) + target.m_right.get_opIndex(2) * rule.m_rightOffset + target.m_forward.get_opIndex(2) * rule.m_forwardOffset;
		float dx = hitPosition.get_opIndex(0) - centerX;
		float dz = hitPosition.get_opIndex(2) - centerZ;
		float localRight = dx * target.m_right.get_opIndex(0) + dz * target.m_right.get_opIndex(2);
		float localForward = dx * target.m_forward.get_opIndex(0) + dz * target.m_forward.get_opIndex(2);
		return abs(localRight) <= rule.m_halfWidth + blastRadius && abs(localForward) <= rule.m_halfLength + blastRadius;
	}

	protected float distanceSquaredToTarget(const Vector3@ hitPosition, const FlameVehicleTarget@ target) const {
		FlameVehicleRule@ rule = target.m_rule;
		if (!target.m_hasOrientation) {
			float dx = hitPosition.get_opIndex(0) - target.m_position.get_opIndex(0);
			float dz = hitPosition.get_opIndex(2) - target.m_position.get_opIndex(2);
			return dx * dx + dz * dz;
		}
		float centerX = target.m_position.get_opIndex(0) + target.m_right.get_opIndex(0) * rule.m_rightOffset + target.m_forward.get_opIndex(0) * rule.m_forwardOffset;
		float centerZ = target.m_position.get_opIndex(2) + target.m_right.get_opIndex(2) * rule.m_rightOffset + target.m_forward.get_opIndex(2) * rule.m_forwardOffset;
		float dx = hitPosition.get_opIndex(0) - centerX;
		float dz = hitPosition.get_opIndex(2) - centerZ;
		return dx * dx + dz * dz;
	}

	protected void spawnNativeFlameBlast(string projectileKey, const Vector3@ hitPosition, int sourceCharacterId, int sourceFactionId) {
		string command = "<command class='create_instance' instance_class='grenade' instance_key='" + projectileKey + "' position='" + hitPosition.toString() + "'";
		if (sourceFactionId >= 0) command += " faction_id='" + sourceFactionId + "'";
		if (sourceCharacterId >= 0) command += " character_id='" + sourceCharacterId + "'";
		command += " />";
		m_metagame.getComms().send(command);
	}

	protected int findBlastEmitter(int characterId, string projectileKey) const {
		for (uint i = 0; i < m_blastEmitters.length(); ++i) {
			if (m_blastEmitters[i].m_characterId == characterId && m_blastEmitters[i].m_projectileKey == projectileKey) return int(i);
		}
		return -1;
	}

	protected void queueNativeFlameBlast(string projectileKey, const Vector3@ hitPosition, int sourceCharacterId, int sourceFactionId) {
		int index = findBlastEmitter(sourceCharacterId, projectileKey);
		if (index < 0) {
			m_blastEmitters.insertLast(FlameBlastEmitter(sourceCharacterId, sourceFactionId, projectileKey));
			index = int(m_blastEmitters.length()) - 1;
		}
		FlameBlastEmitter@ emitter = m_blastEmitters[index];
		emitter.m_factionId = sourceFactionId;
		emitter.m_idleTime = 0.0f;
		if (emitter.m_cooldown <= 0.0f) {
			spawnNativeFlameBlast(projectileKey, hitPosition, sourceCharacterId, sourceFactionId);
			emitter.m_cooldown = m_helperBlastInterval;
			emitter.m_pending = false;
		} else {
			emitter.m_pendingPosition = hitPosition;
			emitter.m_pending = true;
		}
	}

	protected void updateBlastEmitters(float time) {
		for (int i = int(m_blastEmitters.length()) - 1; i >= 0; --i) {
			FlameBlastEmitter@ emitter = m_blastEmitters[i];
			emitter.m_cooldown -= time;
			emitter.m_idleTime += time;
			if (emitter.m_pending && emitter.m_cooldown <= 0.0f) {
				spawnNativeFlameBlast(emitter.m_projectileKey, emitter.m_pendingPosition, emitter.m_characterId, emitter.m_factionId);
				emitter.m_cooldown = m_helperBlastInterval;
				emitter.m_pending = false;
			}
			if (!emitter.m_pending && emitter.m_idleTime > 10.0f) m_blastEmitters.removeAt(i);
		}
	}

	protected void handleResultEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("key");
		float blastRadius = 0.0f;
		string helperProjectileKey;
		if (key == "flame_vehicle_contact") {
			blastRadius = 2.0f;
			helperProjectileKey = "flamethrower_flame_blast.projectile";
		} else if (key == "flame_vehicle_contact_tank") {
			blastRadius = 3.0f;
			helperProjectileKey = "flamethrower_flame_tank_blast.projectile";
		} else return;

		Vector3 hitPosition = stringToVector3(event.getStringAttribute("position"));
		int sourceCharacterId = event.getIntAttribute("character_id");
		queueNativeFlameBlast(helperProjectileKey, hitPosition, sourceCharacterId, getShooterFaction(sourceCharacterId));
		if (!m_loggedFirstResult) {
			_log("FlameVehicleDamage: first flame contact received: " + key, 1);
			m_loggedFirstResult = true;
		}

		int bestIndex = -1;
		float bestDistance = 0.0f;
		for (uint i = 0; i < m_targets.length(); ++i) {
			FlameVehicleTarget@ target = m_targets[i];
			if (target.m_valid && eventTouchesTarget(hitPosition, target, blastRadius)) {
				float distance = distanceSquaredToTarget(hitPosition, target);
				if (bestIndex < 0 || distance < bestDistance) {
					bestIndex = int(i);
					bestDistance = distance;
				}
			}
		}
		if (bestIndex >= 0) m_targets[bestIndex].m_pendingHits++;
	}

	protected void updateTargetFromInfo(FlameVehicleTarget@ target, const XmlElement@ info) {
		const XmlElement@ sourceInfo = info;
		if (info.getStringAttribute("position") == "" || info.getStringAttribute("forward") == "" || info.getStringAttribute("right") == "") {
			const XmlElement@ detailedInfo = getVehicleInfo(m_metagame, target.m_id);
			if (detailedInfo is null) {
				target.m_valid = false;
				return;
			}
			@sourceInfo = detailedInfo;
		}
		target.m_position = stringToVector3(sourceInfo.getStringAttribute("position"));
		target.m_forward = stringToVector3(sourceInfo.getStringAttribute("forward"));
		target.m_right = stringToVector3(sourceInfo.getStringAttribute("right"));
		target.m_valid = true;
		target.m_seen = true;
		target.m_hasOrientation = true;
		if (target.m_pendingHits == 0) return;

		float health = sourceInfo.getFloatAttribute("health");
		float maxHealth = sourceInfo.getFloatAttribute("max_health");
		uint hitCount = target.m_pendingHits;
		target.m_pendingHits = 0;
		if (health <= 0.0f || maxHealth <= 0.0f) {
			const XmlElement@ detailedInfo = getVehicleInfo(m_metagame, target.m_id);
			if (detailedInfo !is null) {
				health = detailedInfo.getFloatAttribute("health");
				maxHealth = detailedInfo.getFloatAttribute("max_health");
			}
		}
		if (health > 0.0f && maxHealth > 0.0f) {
			float newHealth = health - maxHealth * target.m_rule.m_damageFractionPerHit * float(hitCount);
			if (newHealth <= 0.0f) newHealth = -1.0f;
			m_metagame.getComms().send("<command class='update_vehicle' id='" + target.m_id + "' health='" + newHealth + "' />");
			if (!m_loggedFirstDamage) {
				_log("FlameVehicleDamage: first configured vehicle damage applied to " + target.m_rule.m_key, 1);
				m_loggedFirstDamage = true;
			}
		}
	}

	protected void refreshNextFactionTargets() {
		if (m_nextFactionId == 0) {
			for (uint i = 0; i < m_targets.length(); ++i) m_targets[i].m_seen = false;
		}
		array<const XmlElement@>@ vehicles = getFactionVehicles(m_nextFactionId);
		for (uint i = 0; i < vehicles.length(); ++i) {
			int id = vehicles[i].getIntAttribute("id");
			int index = findTarget(id);
			if (index < 0) queueVehicleForClassification(id);
			if (index >= 0) {
				m_targets[index].m_position = stringToVector3(vehicles[i].getStringAttribute("position"));
				m_targets[index].m_valid = true;
				m_targets[index].m_seen = true;
			}
		}
		m_nextFactionId++;
		if (m_nextFactionId >= 4) {
			m_nextFactionId = 0;
			for (int i = int(m_targets.length()) - 1; i >= 0; --i) {
				if (!m_targets[i].m_seen) m_targets.removeAt(i);
			}
		}
	}

	protected void classifyNextVehicle() {
		if (m_pendingClassificationIds.length() == 0) return;
		int id = m_pendingClassificationIds[0];
		m_pendingClassificationIds.removeAt(0);
		if (findTarget(id) >= 0 || findIgnoredVehicle(id) >= 0) return;
		const XmlElement@ info = getVehicleInfo(m_metagame, id);
		if (info is null || info.getIntAttribute("id") < 0) return;
		FlameVehicleRule@ rule = findRule(info.getStringAttribute("key"));
		if (rule is null) {
			m_ignoredVehicleIds.insertLast(id);
			return;
		}
		addTarget(id, rule);
		int index = findTarget(id);
		if (index >= 0) updateTargetFromInfo(m_targets[index], info);
	}

	protected void flushPendingDamage() {
		for (uint i = 0; i < m_targets.length(); ++i) {
			if (m_targets[i].m_pendingHits == 0) continue;
			const XmlElement@ info = getVehicleInfo(m_metagame, m_targets[i].m_id);
			if (info !is null && info.getIntAttribute("id") >= 0) updateTargetFromInfo(m_targets[i], info);
		}
	}

	bool hasEnded() const { return false; }
	bool hasStarted() const { return true; }

	void update(float time) {
		updateBlastEmitters(time);
		m_refreshTimer -= time;
		if (m_refreshTimer <= 0.0f) {
			refreshNextFactionTargets();
			m_refreshTimer = m_refreshInterval;
		}
		m_classificationTimer -= time;
		if (m_classificationTimer <= 0.0f) {
			classifyNextVehicle();
			m_classificationTimer = m_classificationInterval;
		}
		m_damageTimer -= time;
		if (m_damageTimer <= 0.0f) {
			flushPendingDamage();
			m_damageTimer = m_damageInterval;
		}
	}
}
