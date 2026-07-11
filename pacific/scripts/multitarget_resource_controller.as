// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "resource.as"
#include "resource_helpers.as"


// --------------------------------------------
class MultitargetResourceController : Tracker {
	protected GameMode@ m_metagame;
	protected array<string> m_vehicleKeys;
	protected array<Resource@> m_resources;
	protected bool m_trackBaseOwnership;

	protected array<bool> m_cachedLastState;

	protected array<string> m_sorting;

	// --------------------------------------------
	MultitargetResourceController(GameMode@ metagame, const array<string>@ vehicleKeys, const array<Resource@>@ resources, const array<string>@ sorting, bool trackBaseOwnership = true) {
		@m_metagame = @metagame;
		m_vehicleKeys = vehicleKeys;
		m_resources = resources;
		m_trackBaseOwnership = trackBaseOwnership;
		m_sorting = sorting;

		// assume enabled for all factions at start
		m_cachedLastState = array<bool>(metagame.getFactionCount(), true);
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
	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (m_vehicleKeys.find(key) >= 0) {
			int factionId = event.getIntAttribute("owner_id");
			_log("MultiTargetResourceController, vehicle being spawned, key " + key + ", faction " + factionId, 1); 
			// disable given resources from enemies
			for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
				if (i == uint(factionId)) continue;
				setResources(i, false);
			}
		}
	}
	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		if (!m_trackBaseOwnership) return;

		_log("MultiTargetResourceController, base ownership changed", 1); 
		refreshResources();
	}

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (m_vehicleKeys.find(key) >= 0) {
			_log("MultiTargetResourceController, vehicle being destroyed, key " + key, 1); 
			refreshResources();
		}
	}

	// ----------------------------------------------------
	protected void refreshResources() {
		// prepare to enable resources for all factions
		array<bool> doEnableResources(m_metagame.getFactionCount(), true);

		// query from game about vehicles still healthy
		for (uint factionId = 0; factionId < m_metagame.getFactionCount(); ++factionId) {
			bool handled = false;
			for (uint vehicleKeyIndex = 0; vehicleKeyIndex < m_vehicleKeys.size() && !handled; ++vehicleKeyIndex) {
				array<const XmlElement@> list = getVehicles(m_metagame, factionId, m_vehicleKeys[vehicleKeyIndex]);
				for (uint i = 0; i < list.size() && !handled; i++) {
					const XmlElement@ info = list[i];
					int id = info.getIntAttribute("id");
					if (id >= 0) {
						const XmlElement@ vehicle = getVehicleInfo(m_metagame, id);
						if (vehicle !is null) {
							float health = vehicle.getFloatAttribute("health");
							//_log("faction " + factionId + " = " + f.m_config.m_name + ", health=" + health, 2);
							if (health > 0.0) {
								// still healthy, mark enemies to not enable resources
								for (uint k = 0; k < m_metagame.getFactionCount(); ++k) {
									if (k == factionId) continue;
									doEnableResources[k] = false;
								}
								// one healthy vehicle is enough to disable resources from all enemies
								handled = true;
							}
						}
					}
				}
			}
		}

		for (uint i = 0; i < doEnableResources.size(); ++i) {
			if (doEnableResources[i]) {
				setResources(i, true);
			} else {
				setResources(i, false);
			}
		}
	}

	// ----------------------------------------------------
	protected void setResources(uint factionId, bool enabled) {
		if (m_cachedLastState[factionId] == enabled) {
			_log("MultiTargetResourceController, setResources, factionId=" + factionId + " already set as " + enabled, 1); 
			return;
		}

		_log("MultiTargetResourceController, setResources, factionId=" + factionId + " enabled=" + enabled, 1); 

		resetFactionCallResources(m_metagame, factionId, m_resources, enabled, m_sorting);

		{
			string messageKey = enabled ? "resources added" : "resources removed";
			sendFactionMessageKey(m_metagame, factionId, messageKey, dictionary = {}, 1.0); // 1.0 = high priority
		}

		m_cachedLastState[factionId] = enabled;
	}
}
