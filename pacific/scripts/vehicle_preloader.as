#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "log.as"

// Per-map minimum vehicle cover for mod-local .mesh files (2026-09-25).
// Sources: both map factions' resources, their call vehicle targets, and fixed
// objects.svg spawns. Each vehicle contributes its visual meshes AND turret
// weapon models. Re-audit when any source or vehicle/weapon model changes;
// a spawn handler by itself is not availability.
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
	protected bool m_batchStarted = false;
	protected array<bool> m_batchPending;
	protected uint m_batchRemaining = 0;
	protected float m_batchPollDelay = 0.25f;
	protected bool m_batchDelayWarned = false;

	HighDetailVehiclePreloader(Metagame@ metagame, string explicitMapId = "") {
		@m_metagame = @metagame;
		m_mapId = getPacificMapId(metagame, explicitMapId);
		configureMap(m_mapId);
	}

	bool hasStarted() const { return true; }
	bool hasEnded() const { return m_completed; }

	protected void addVehicle(string key, int factionId) {
		m_vehicleKeys.insertLast(key);
		m_factionIds.insertLast(factionId);
	}

	protected void configureMap(string mapId) {
		if (mapId != "island1" && mapId != "island2" && mapId != "island3" &&
			mapId != "island4" && mapId != "island5" && mapId != "island6" &&
			mapId != "island7" && mapId != "island8" && mapId != "island9" &&
			mapId != "island10") return;

		addVehicle("at_gun_m1_57mm.vehicle", 0);
		addVehicle("at_gun_m3_37mm.vehicle", 0);
		addVehicle("chi_ha_early.vehicle", 1);
		addVehicle("deco_coupe_beige.vehicle", 0);
		addVehicle("deco_pickup_blue.vehicle", 0);
		if (mapId == "island3" || mapId == "island4" || mapId == "island5" ||
			mapId == "island6" || mapId == "island7" || mapId == "island8" ||
			mapId == "island10") addVehicle("m4_75.vehicle", 0);
		if (mapId == "island3" || mapId == "island4" || mapId == "island5" ||
			mapId == "island6" || mapId == "island7" || mapId == "island8" ||
			mapId == "island10") addVehicle("m5a1_stuart.vehicle", 0);
		if (mapId == "island5") addVehicle("m4_75_late.vehicle", 0);
		if (mapId == "island6" || mapId == "island7") addVehicle("m4_76.vehicle", 0);
		if (mapId == "island7") addVehicle("m4a3e8.vehicle", 0);
		if (mapId == "island9") addVehicle("deco_sedan_black.vehicle", 0);
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
			_log("HighDetailVehiclePreloader[" + m_mapId + "]: no mod-local meshes require warm-up", 1);
		}
	}

	// Warm all representatives in one update, while retaining the map-specific pool.
	protected bool useBatchWarmup() const {
		return m_vehicleKeys.length() > 0;
	}

	protected Vector3 getBatchPosition(uint index) const {
		return Vector3(m_originX + 40.0f + float(index % 4) * 8.0f,
			-100.0f, m_originZ + 40.0f + float(index / 4) * 8.0f);
	}

	protected void startBatch() {
		m_batchStarted = true;
		m_batchPending = array<bool>(m_vehicleKeys.length(), true);
		m_batchRemaining = m_vehicleKeys.length();
		for (uint i = 0; i < m_vehicleKeys.length(); ++i) {
			XmlElement command("command");
			command.setStringAttribute("class", "create_instance");
			command.setStringAttribute("instance_class", "vehicle");
			command.setStringAttribute("instance_key", m_vehicleKeys[i]);
			command.setStringAttribute("position", getBatchPosition(i).toString());
			command.setIntAttribute("instances", 1);
			command.setIntAttribute("faction_id", m_factionIds[i]);
			m_metagame.getComms().send(command);
		}
		_log("HighDetailVehiclePreloader[" + m_mapId + "]: requested all " +
			m_batchRemaining + " representative vehicles in one update", 1);
	}

	protected bool removeBatchVehicle(uint index, int vehicleId) {
		if (!m_batchPending[index]) return false;
		const XmlElement@ info = getVehicleInfo(m_metagame, vehicleId);
		if (info is null || !info.hasAttribute("position")) return false;
		Vector3 position = stringToVector3(info.getStringAttribute("position"));
		Vector3 expected = getBatchPosition(index);
		if (abs(position.m_values[0] - expected.m_values[0]) >= 1.0f ||
			abs(position.m_values[2] - expected.m_values[2]) >= 1.0f) return false;
		removeVehicle(m_metagame, vehicleId);
		m_batchPending[index] = false;
		m_batchRemaining--;
		_log("HighDetailVehiclePreloader[" + m_mapId + "]: warmed and removed " +
			m_vehicleKeys[index] + ", remaining " + m_batchRemaining, 1);
		if (m_batchRemaining == 0) {
			m_completed = true;
			_log("HighDetailVehiclePreloader[" + m_mapId + "]: batch complete, approximate preload window " +
				m_elapsed + " s", 1);
		}
		return true;
	}

	protected void pollBatch() {
		for (uint i = 0; i < m_vehicleKeys.length(); ++i) {
			if (!m_batchPending[i]) continue;
			array<const XmlElement@>@ vehicles = getVehicles(m_metagame, m_factionIds[i], m_vehicleKeys[i]);
			for (uint j = 0; j < vehicles.length(); ++j) {
				if (removeBatchVehicle(i, vehicles[j].getIntAttribute("id"))) break;
			}
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
		if (useBatchWarmup()) {
			if (!m_batchStarted) {
				startBatch();
				return;
			}
			if (!m_batchDelayWarned && m_elapsed >= 30.0f && m_batchRemaining > 0) {
				m_batchDelayWarned = true;
				_log("HighDetailVehiclePreloader[" + m_mapId + "]: still waiting for " +
					m_batchRemaining + " test vehicles; continuing cleanup checks", -1);
			}
			m_batchPollDelay -= time;
			if (m_batchPollDelay <= 0.0f) {
				m_batchPollDelay = m_elapsed < 30.0f ? 0.25f : 5.0f;
				pollBatch();
			}
			return;
		}

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
		if (useBatchWarmup()) {
			if (!m_batchStarted) return;
			string key = event.getStringAttribute("vehicle_key");
			for (uint i = 0; i < m_vehicleKeys.length(); ++i) {
				if (m_batchPending[i] && m_vehicleKeys[i] == key &&
					removeBatchVehicle(i, event.getIntAttribute("vehicle_id"))) break;
			}
			return;
		}
		if (m_waitingKey == "" || event.getStringAttribute("vehicle_key") != m_waitingKey) return;

		int vehicleId = event.getIntAttribute("vehicle_id");
		const XmlElement@ info = getVehicleInfo(m_metagame, vehicleId);
		bool isPreloadVehicle = info is null;
		if (info !is null && info.hasAttribute("position")) {
			Vector3 position = stringToVector3(info.getStringAttribute("position"));
			isPreloadVehicle = abs(position.m_values[0] - m_expectedPosition.m_values[0]) < 1.0f &&
				abs(position.m_values[2] - m_expectedPosition.m_values[2]) < 1.0f;
		}

		if (!isPreloadVehicle) return;

		removeVehicle(m_metagame, vehicleId);
		_log("HighDetailVehiclePreloader[" + m_mapId + "]: warmed and removed " + m_waitingKey +
			", approximate load wait " + (m_elapsed - m_vehicleStartElapsed) + " s", 1);
		m_waitingKey = "";
		m_nextIndex++;
		m_delay = 0.05f;
	}
}

string extractPacificMapId(string source) {
	if (source.findFirst("island10") >= 0) return "island10";
	if (source.findFirst("island9") >= 0) return "island9";
	if (source.findFirst("island8") >= 0) return "island8";
	if (source.findFirst("island7") >= 0) return "island7";
	if (source.findFirst("island6") >= 0) return "island6";
	if (source.findFirst("island5") >= 0) return "island5";
	if (source.findFirst("island4") >= 0) return "island4";
	if (source.findFirst("island3") >= 0) return "island3";
	if (source.findFirst("island2") >= 0) return "island2";
	if (source.findFirst("island1") >= 0) return "island1";
	return "";
}

string getPacificMapId(const Metagame@ metagame, string explicitMapId = "") {
	string mapId = extractPacificMapId(explicitMapId);
	if (mapId != "") return mapId;

	const XmlElement@ general = getGeneralInfo(metagame);
	if (general !is null && general.hasAttribute("map")) {
		mapId = extractPacificMapId(general.getStringAttribute("map"));
	}
	return mapId == "" ? "unknown" : mapId;
}
