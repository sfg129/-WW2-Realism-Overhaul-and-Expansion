// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "call_marker_tracker.as"

// borrowing CallMarkerConfig for basis
// --------------------------------------------
class MarkerConfig : CallMarkerConfig {
	// --------------------------------------------
	MarkerConfig(string typeKey, int atlasIndex = 0, float size = 2.0, float range = 1.0, string text = "") {
		super("", typeKey, atlasIndex, size, range, text);
	}
}

// --------------------------------------------
class MarkerWithHealthConfig : MarkerConfig {
	protected array<int> m_healthAtlasIndices;
	
	// --------------------------------------------
	MarkerWithHealthConfig(string typeKey, int atlasIndex, array<int> healthAtlasIndices, float size = 2.0, float range = 1.0, string text = "") {
		super(typeKey, atlasIndex, size, range, text);
		m_healthAtlasIndices = healthAtlasIndices;
	}
	
	// --------------------------------------------
	int getHealthIndicesSize() const {
		return m_healthAtlasIndices.size();
	}

	// --------------------------------------------
	int getHealthIndex(float healthPercentage) const {
		// handle health based atlas index
		// even distribution
		int size = m_healthAtlasIndices.size();
		
		int index = int(ceil(healthPercentage * (size - 1)));
		_log("index before clamp=" + index, 1);
		
		index = max(0, index);
		index = min(index, size - 1);

		_log("index after clamp=" + index, 1);
		
		return index;
	}
	
	// --------------------------------------------
	int getHealthAtlasIndex(float healthPercentage) const {
		return m_healthAtlasIndices[getHealthIndex(healthPercentage)];
	}
}

// --------------------------------------------
class CaptureBaseWithVehicle : Tracker {
	protected Metagame@ m_metagame;
	protected string m_vehicleKey;
	protected int m_factionId;

	protected int m_trackedVehicleId;
	protected int m_targetBaseId;
	protected string m_targetHitbox;

	protected MarkerWithHealthConfig@ m_markerConfig;
	
	protected int m_markerId;
	protected float m_markerTimer;

	protected int m_lastHealthMarkerAtlasIndex;

	// ----------------------------------------------------
	CaptureBaseWithVehicle(Metagame@ metagame, string vehicleKey, int factionId, MarkerWithHealthConfig@ markerConfig) {
		@m_metagame = @metagame;
		m_vehicleKey = vehicleKey;
		m_factionId = factionId;
		
		@m_markerConfig = @markerConfig;
		
		m_markerId = 9000;
		
		reset();
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}
	
	// ----------------------------------------------------
	void onRemove() {
		reset();
	}

	// ----------------------------------------------------
	protected void reset() {
		m_trackedVehicleId = -1;
		m_targetBaseId = -1;
		m_targetHitbox = "";
		m_markerTimer = -1.0;
		m_lastHealthMarkerAtlasIndex = -1;
	}
	
	// ----------------------------------------------------
	void gameContinuePreStart() {
		// when loading a save, query current attack target, there won't be an attack change event
		const XmlElement@ info = getFactionInfo(m_metagame, m_factionId);
		if (info !is null) {
			setTargetBase(info.getIntAttribute("attack_target_base_id"));
		}
	}

	// ----------------------------------------------------
	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		int ownerId = event.getIntAttribute("owner_id");
		if (key == m_vehicleKey && ownerId == m_factionId) {
			clearHitboxes();
			m_trackedVehicleId = -1;
			
			m_trackedVehicleId = event.getIntAttribute("vehicle_id");
			
			attemptSetupHitboxes();

			setMarker();
		}
	}

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		if (event.getIntAttribute("vehicle_id") == m_trackedVehicleId) {
			// set final destroyed marker
			setMarker();
			//endMarker();
		
			clearHitboxes();
			m_trackedVehicleId = -1;
			
			XmlElement command("command");
			command.setStringAttribute("class", "set_match_status");
			command.setIntAttribute("lose", 1);
			command.setIntAttribute("faction_id", m_factionId);
			m_metagame.getComms().send(command);
		}
	}

	// ----------------------------------------------------
	protected void setTargetBase(int baseId) {
		if (baseId >= 0) {
			const XmlElement@ base = getBase(m_metagame, baseId);
			if (base !is null) {
				m_targetHitbox = "hitbox_" + base.getStringAttribute("key");
				m_targetBaseId = baseId;
			}
		}
	}	

	// ----------------------------------------------------
	protected void handleAttackChangeEvent(const XmlElement@ event) {
		if (event.getIntAttribute("faction_id") != m_factionId) return;
		
		clearHitboxes();

		m_targetHitbox = "";
		m_targetBaseId = -1;

		int baseId = event.getIntAttribute("base_id");
		if (baseId >= 0) {
			setTargetBase(baseId);
			attemptSetupHitboxes();
		}
	}

	// ----------------------------------------------------
	void attemptSetupHitboxes() {
		if (m_trackedVehicleId >= 0 && m_targetHitbox != "") {
			// setup hitbox tracking
			string instanceType = "vehicle";
			string command = "<command class='add_hitbox_check' id='" + m_targetHitbox + "' instance_type='" + instanceType + "' instance_id='" + m_trackedVehicleId + "' />";
			m_metagame.getComms().send(command);
		}
	}

	// ----------------------------------------------------
	void clearHitboxes() {
		if (m_trackedVehicleId >= 0 && m_targetHitbox != "") {
			string instanceType = "vehicle";
			string command = "<command class='remove_hitbox_check' id='" + m_targetHitbox + "' instance_type='" + instanceType + "' instance_id='" + m_trackedVehicleId + "' />";
			m_metagame.getComms().send(command);
		}
	}
	
	// ----------------------------------------------------
	protected void handleHitboxEvent(const XmlElement@ event) {
		if (event.getStringAttribute("instance_type") == "vehicle" &&
			event.getIntAttribute("instance_id") == m_trackedVehicleId &&
			m_targetHitbox != "" && 
			m_targetBaseId >= 0) {

			captureTargetBase();
			
			// done, clear hitbox tracking
			clearHitboxes();
			
			m_targetHitbox = "";
			m_targetBaseId = -1;
		}
	}

	// ----------------------------------------------------
	protected void captureTargetBase() {
		// capture the base
		XmlElement command("command");
		command.setStringAttribute("class", "update_base");
		command.setIntAttribute("base_id", m_targetBaseId);
		command.setIntAttribute("owner_id", m_factionId);
		// make it uncapturable now
		command.setBoolAttribute("capturable", false);
		
		m_metagame.getComms().send(command);
	}
	
	// --------------------------------------------
	protected void setMarker() {
		if (m_trackedVehicleId < 0) {
			return;
		}
		const XmlElement@ vehicle = getVehicleInfo(m_metagame, m_trackedVehicleId);
		if (vehicle is null) {
			return;
		}

		string position = vehicle.getStringAttribute("position");
		
		// add two markers, one for vehicle, one for health
		{
		XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", m_markerId);
		command.setIntAttribute("faction_id", m_factionId);
		command.setIntAttribute("atlas_index", m_markerConfig.m_atlasIndex);
			command.setIntAttribute("render_queue_offset", 0);
		command.setFloatAttribute("size", m_markerConfig.m_size);
		command.setFloatAttribute("range", m_markerConfig.m_range);
		command.setIntAttribute("enabled", 1);
		command.setStringAttribute("position", position);
		command.setStringAttribute("text", m_markerConfig.m_text);
		command.setStringAttribute("type_key", m_markerConfig.m_typeKey);
		// map view shows own vehicle icon anyway
		command.setBoolAttribute("show_in_map_view", false);
		command.setBoolAttribute("show_in_game_view", false);
		// only doing this for edge marker
		command.setBoolAttribute("show_at_screen_edge", true);
		m_metagame.getComms().send(command);
	}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", m_markerId+1);
			command.setIntAttribute("faction_id", m_factionId);
			command.setIntAttribute("render_queue_offset", 1);
			float health = vehicle.getFloatAttribute("health");
			health = max(0.0f, health);
			float maxHealth = vehicle.getFloatAttribute("max_health");
			_log("health=" + health + ", max_health=" + maxHealth, 1);
			float percentage = health / maxHealth;
			int atlasIndex = m_markerConfig.getHealthAtlasIndex(percentage);
			if (atlasIndex != m_lastHealthMarkerAtlasIndex) {
				int index = m_markerConfig.getHealthIndex(percentage);
				// index is from 0 to 10 if there are 10+1 icons
				int h = index * (100 / (m_markerConfig.getHealthIndicesSize() - 1));
				sendFactionMessageKey(m_metagame, m_factionId, "capture_base_with_vehicle mode, health=" + h);
				m_lastHealthMarkerAtlasIndex = atlasIndex;
			}
			command.setIntAttribute("atlas_index", atlasIndex);
			command.setFloatAttribute("size", m_markerConfig.m_size);
			command.setFloatAttribute("range", m_markerConfig.m_range);
			command.setIntAttribute("enabled", 1);
			command.setStringAttribute("position", position);
			command.setStringAttribute("text", "");
			command.setStringAttribute("type_key", m_markerConfig.m_typeKey);
			command.setBoolAttribute("show_in_map_view", true);
			command.setBoolAttribute("show_in_game_view", false);
			command.setBoolAttribute("show_at_screen_edge", true);
			m_metagame.getComms().send(command);
		}
	}
	
	// --------------------------------------------
	protected void endMarker() {
		{
		XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", m_markerId);
		command.setIntAttribute("faction_id", m_factionId);
		command.setIntAttribute("enabled", 0);
		m_metagame.getComms().send(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", m_markerId+1);
			command.setIntAttribute("faction_id", m_factionId);
			command.setIntAttribute("enabled", 0);
			m_metagame.getComms().send(command);
		}
		m_lastHealthMarkerAtlasIndex = -1;
	}

	// --------------------------------------------
	void update(float time) {
		if (m_trackedVehicleId >= 0) {
			m_markerTimer -= time;
			if (m_markerTimer < 0.0) {
				setMarker();
				m_markerTimer = 0.5;
			}
		}
	}
	
}
