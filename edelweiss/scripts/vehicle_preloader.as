#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "log.as"

// Per-map minimum vehicle cover for mod-local .mesh files (2026-09-25).
// Sources: both map factions' resources, their call vehicle targets, and fixed
// objects.svg spawns. Each vehicle contributes its visual meshes AND turret
// weapon models. Keep one representative per distinct required mesh union;
// for example E8 also warms the late 76 mm cannon, while either E2 variant
// warms the same E2 chassis/running gear/turret. Re-audit when any source or
// vehicle/weapon model changes; a handler by itself is not availability.
class HighDetailVehiclePreloader : Tracker {
	protected Metagame@ m_metagame;
	protected array<string> m_vehicleKeys;
	protected array<int> m_factionIds;
	protected string m_mapId = "unknown";
	protected float m_originX = 512.0f;
	protected float m_originZ = 512.0f;
	protected uint m_nextIndex = 0;
	protected string m_waitingKey = "";
	protected Vector3 m_expectedPosition;
	protected float m_delay = 0.25f;
	protected float m_spawnTimeout = 0.0f;
	protected float m_elapsed = 0.0f;
	protected float m_vehicleStartElapsed = 0.0f;
	protected bool m_completed = false;

	HighDetailVehiclePreloader(Metagame@ metagame, string explicitMapId = "") {
		@m_metagame = @metagame;
		m_mapId = getEdelweissMapId(metagame, explicitMapId);
		configureMap(m_mapId);
	}

	bool hasStarted() const { return true; }
	bool hasEnded() const { return m_completed; }

	protected void addVehicle(string key, int factionId) {
		m_vehicleKeys.insertLast(key);
		m_factionIds.insertLast(factionId);
	}

	protected void configureMap(string mapId) {
		if (mapId != "edelweiss1" && mapId != "edelweiss2" && mapId != "edelweiss3" &&
			mapId != "edelweiss4" && mapId != "edelweiss5" && mapId != "edelweiss6" &&
			mapId != "edelweiss7" && mapId != "edelweiss8" && mapId != "edelweiss9" &&
			mapId != "edelweiss11") return;

		addVehicle("m5a1_stuart.vehicle", 0);
		addVehicle("sdkfz251_pak40.vehicle", 1);
		addVehicle("deco_coupe_beige.vehicle", 0);
		addVehicle("deco_pickup_blue.vehicle", 0);
		// The high-detail 71 chassis/turret/running gear is used by M4(75)
		// variants and is distinct from the 70, E2, E8 and Sherman V assets.
		addVehicle("m4_75.vehicle", 0);
		if (mapId == "edelweiss1" || mapId == "edelweiss3" || mapId == "edelweiss4" ||
			mapId == "edelweiss5" || mapId == "edelweiss8" || mapId == "edelweiss9" ||
			mapId == "edelweiss11") addVehicle("m4_V.vehicle", 0);
		if (mapId == "edelweiss1" || mapId == "edelweiss3" || mapId == "edelweiss4" ||
			mapId == "edelweiss5" || mapId == "edelweiss8" || mapId == "edelweiss9")
			addVehicle("m4_firefly.vehicle", 0);
		if (mapId != "edelweiss1") addVehicle("panther.vehicle", 1);
		if (mapId == "edelweiss1" || mapId == "edelweiss2" || mapId == "edelweiss6" ||
			mapId == "edelweiss7" || mapId == "edelweiss11") {
			addVehicle("at_gun_m1_57mm.vehicle", 0);
		} else {
			addVehicle("at_gun_qf6.vehicle", 0);
		}
		if (mapId == "edelweiss2" || mapId == "edelweiss6" || mapId == "edelweiss7") {
			addVehicle("m4_76.vehicle", 0);
			addVehicle("m4a3e2_75.vehicle", 0);
		}
		if (mapId == "edelweiss6" || mapId == "edelweiss7") addVehicle("m4a3e8.vehicle", 0);
		if (mapId == "edelweiss7" || mapId == "edelweiss8" || mapId == "edelweiss9" ||
			mapId == "edelweiss11") addVehicle("deco_sedan_black.vehicle", 0);
	}

	void onAdd() {
		array<const XmlElement@> bases = getBases(m_metagame);
		if (bases.length() > 0 && bases[0].hasAttribute("position")) {
			Vector3 basePosition = stringToVector3(bases[0].getStringAttribute("position"));
			m_originX = basePosition.m_values[0];
			m_originZ = basePosition.m_values[2];
		}

		_log("HighDetailVehiclePreloader[" + m_mapId + "]: warming " +
			m_vehicleKeys.length() + " representative vehicles", 1);
		if (m_vehicleKeys.length() == 0) {
			m_completed = true;
			_log("HighDetailVehiclePreloader[" + m_mapId + "]: no high-detail assets require warm-up", 1);
		}
	}

	protected void spawnNext() {
		if (m_nextIndex >= m_vehicleKeys.length()) {
			m_completed = true;
			_log("HighDetailVehiclePreloader[" + m_mapId + "]: complete, approximate preload window " +
				m_elapsed + " s", 1);
			return;
		}

		m_waitingKey = m_vehicleKeys[m_nextIndex];
		m_expectedPosition = Vector3(m_originX + float(m_nextIndex) * 4.0f, -100.0f, m_originZ);
		m_spawnTimeout = 5.0f;
		m_vehicleStartElapsed = m_elapsed;

		XmlElement command("command");
		command.setStringAttribute("class", "create_instance");
		command.setStringAttribute("instance_class", "vehicle");
		command.setStringAttribute("instance_key", m_waitingKey);
		command.setStringAttribute("position", m_expectedPosition.toString());
		command.setIntAttribute("instances", 1);
		command.setIntAttribute("faction_id", m_factionIds[m_nextIndex]);
		m_metagame.getComms().send(command);
		_log("HighDetailVehiclePreloader[" + m_mapId + "]: requested " + m_waitingKey, 1);
	}

	void update(float time) {
		if (m_completed) return;
		m_elapsed += time;

		if (m_waitingKey != "") {
			m_spawnTimeout -= time;
			if (m_spawnTimeout <= 0.0f) {
				_log("HighDetailVehiclePreloader[" + m_mapId + "]: timed out waiting for " + m_waitingKey, -1);
				m_waitingKey = "";
				m_nextIndex++;
				m_delay = 0.05f;
			}
			return;
		}

		m_delay -= time;
		if (m_delay <= 0.0f) spawnNext();
	}

	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		if (m_waitingKey == "" || event.getStringAttribute("vehicle_key") != m_waitingKey) return;

		int vehicleId = event.getIntAttribute("vehicle_id");
		const XmlElement@ info = getVehicleInfo(m_metagame, vehicleId);
		bool isPreloadVehicle = info is null;
		if (info !is null && info.hasAttribute("position")) {
			Vector3 position = stringToVector3(info.getStringAttribute("position"));
			isPreloadVehicle = abs(position.m_values[0] - m_expectedPosition.m_values[0]) < 1.0f &&
				abs(position.m_values[2] - m_expectedPosition.m_values[2]) < 1.0f;
		}

		// Never remove a same-type map vehicle unless it is our private instance.
		if (!isPreloadVehicle) return;

		removeVehicle(m_metagame, vehicleId);
		_log("HighDetailVehiclePreloader[" + m_mapId + "]: warmed and removed " + m_waitingKey +
			", approximate load wait " + (m_elapsed - m_vehicleStartElapsed) + " s", 1);
		m_waitingKey = "";
		m_nextIndex++;
		m_delay = 0.05f;
	}
}

string extractEdelweissMapId(string source) {
	// Long names must be checked first because "edelweiss1" is a prefix of 10/11.
	if (source.findFirst("edelweiss11") >= 0) return "edelweiss11";
	if (source.findFirst("edelweiss10") >= 0) return "edelweiss10";
	if (source.findFirst("edelweiss9") >= 0) return "edelweiss9";
	if (source.findFirst("edelweiss8") >= 0) return "edelweiss8";
	if (source.findFirst("edelweiss7") >= 0) return "edelweiss7";
	if (source.findFirst("edelweiss6") >= 0) return "edelweiss6";
	if (source.findFirst("edelweiss5") >= 0) return "edelweiss5";
	if (source.findFirst("edelweiss4") >= 0) return "edelweiss4";
	if (source.findFirst("edelweiss3") >= 0) return "edelweiss3";
	if (source.findFirst("edelweiss2") >= 0) return "edelweiss2";
	if (source.findFirst("edelweiss1") >= 0) return "edelweiss1";
	return "";
}

string getEdelweissMapId(const Metagame@ metagame, string explicitMapId = "") {
	string mapId = extractEdelweissMapId(explicitMapId);
	if (mapId != "") return mapId;

	const XmlElement@ general = getGeneralInfo(metagame);
	if (general !is null && general.hasAttribute("map")) {
		mapId = extractEdelweissMapId(general.getStringAttribute("map"));
	}
	return mapId == "" ? "unknown" : mapId;
}
