#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

//Author: Unit G17

	// --------------------------------------------
class OccultSealManager : Tracker {
	protected Metagame@ m_metagame;
	protected float m_updateInterval = 1.8f; //update cycles happen roughly at 0.5 second intervals, so this 1.8 is actually about 2 seconds
	protected float m_updateDamage = 2.01f; //setting vehicle health has rounding errors, thus the added 0.01
	protected float m_timer;
	protected int m_markerOffset = 9000;
	protected float m_pi = acos(-1.0f);

	// --------------------------------------------
	OccultSealManager(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_timer = m_updateInterval;
	}
	
	// --------------------------------------------
	int zombieCountPerStage() {
		int zombieCount;
		int playerCount = getPlayerCount(m_metagame);
		if (playerCount < 2) {
			zombieCount = 3;
		} else if (playerCount < 4) {
			zombieCount = 4;
		} else if (playerCount < 8) {
			zombieCount = 5;
		} else {
			zombieCount = 6;
		}
		return zombieCount;
	}
	
	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return true;
	}
	
	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			for (uint f = 1; f < 3; ++f) {
				array<const XmlElement@>@ occultSeals = getVehicles(m_metagame, f, "occult_seal.vehicle");
				for (uint i = 0; i < occultSeals.length(); ++i) {
					Vector3 sealPos = stringToVector3(occultSeals[i].getStringAttribute("position"));
					array<const XmlElement@> characters = getCharactersNearPosition(m_metagame, sealPos, 0, 7.0f);
					if (characters.size() > 0) {
						int sealId = occultSeals[i].getIntAttribute("id");
						const XmlElement@ sealInfo = getVehicleInfo(m_metagame, sealId);
						if (sealInfo !is null) {
							float sealHealth = sealInfo.getFloatAttribute("health");
							if (sealHealth > 0.0) {
								sealHealth -= m_updateDamage;
								m_metagame.getComms().send("<command class='update_vehicle' id='" + sealId + "' health='" + sealHealth + "' />");
								updateSeal(sealId, sealPos, sealHealth);
							}
						} else {
							updateSeal(sealId, sealPos, 0.0);
						}
					}
				}
			}
			m_timer = m_updateInterval;
		}
	}
	
	// ----------------------------------------------------
	void updateSeal(int sealId, Vector3 sealPos, float sealHealth, bool loadGame = false) {
		array<int> stage = {0, 0};
		
		uint i = 0;		
		do {
			if (sealHealth <= 0.0) {
				removeMarker(sealId * 7 + m_markerOffset);
				stage[i] = 6;
			} else if (sealHealth <= 4.0) {
				stage[i] = 5;
			} else if (sealHealth <= 8.0) {
				stage[i] = 4;
			} else if (sealHealth <= 12.0) {
				stage[i] = 3;
			} else if (sealHealth <= 16.0) {
				stage[i] = 2;
			} else if (sealHealth <= 20.0) {
				stage[i] = 1;
			} else {
				if (i == 0) {
					return;
				}
			}
			sealHealth += m_updateDamage;
			++i;
		} while (!loadGame && i < 2);
		
		if ((stage[0] != stage[1]) && !loadGame) {
			if (stage[0] == 6) {
				spawnInstance(sealPos.toString(), "grenade", "ww2_undead_occult_seal_activation.projectile");
			} else {
				stageSpawner(sealPos, "vehicle", "ww2_undead_occult_seal_spawner.vehicle", zombieCountPerStage(), 15.0f);
			}
		}
		
		while ((stage[0] != stage[1]) || (loadGame && stage[0] > 0)) {
			string typeKey = "occult_seal_stage" + formatInt(stage[0]);		
			addMarker(sealId * 7 + stage[0] + m_markerOffset, sealPos, typeKey, false, true);
			--stage[0];
		}
	}
	
	// ----------------------------------------------------
	void addMarker(int id, Vector3 pos, string typeKey, bool mapView, bool gameView, int atlasIndex = -1) {
		XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", id);
			command.setIntAttribute("faction_id", 0);		
			command.setIntAttribute("atlas_index", atlasIndex);
			command.setFloatAttribute("size", 1.0);
			command.setFloatAttribute("range", 12.0);
			command.setIntAttribute("enabled", 1);
			command.setStringAttribute("position", pos.toString());
			command.setStringAttribute("text", "");
			command.setStringAttribute("type_key", typeKey);
			command.setStringAttribute("color", "#ff0000");
			command.setBoolAttribute("show_in_map_view", mapView);
			command.setBoolAttribute("show_in_game_view", gameView);
			command.setBoolAttribute("show_at_screen_edge", false);
		m_metagame.getComms().send(command);
	}
	
	// ----------------------------------------------------
	void removeMarker(int id) {
		XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", id);
			command.setIntAttribute("enabled", 0);
			command.setIntAttribute("faction_id", 0);
		m_metagame.getComms().send(command);
	}
	
	// ----------------------------------------------------
	void stageSpawner(Vector3 pos, string instanceClass, string instanceKey, uint amount = 1, float radius = 0.0f) {
		float initAngle = rand(0.0f, 2 * m_pi);
		float angle;
		for (uint i = 0; i < amount; ++i) {
			angle = initAngle + i * 2 * m_pi / amount;
			Vector3 offset = Vector3(sin(angle) * radius, 1, cos(angle) * radius);			
			spawnInstance((pos.add(offset)).toString(), instanceClass, instanceKey);
		}
	}

	// ----------------------------------------------------
	void spawnInstance(string pos, string instanceClass, string instanceKey, int factionId = 2) { 
		XmlElement command("command");
			command.setStringAttribute("class", "create_instance");
			command.setIntAttribute("faction_id", factionId);
			command.setStringAttribute("instance_class", instanceClass);
			command.setStringAttribute("instance_key", instanceKey);
			command.setStringAttribute("position", pos);
		m_metagame.getComms().send(command);
	}
	
	// ----------------------------------------------------
	void onAdd() {
		for (uint f = 1; f < 3; ++f) {
			array<const XmlElement@>@ occultSeals = getVehicles(m_metagame, f, "occult_seal.vehicle");
			for (uint i = 0; i < occultSeals.length(); ++i) {
				Vector3 sealPos = stringToVector3(occultSeals[i].getStringAttribute("position"));
				int sealId = occultSeals[i].getIntAttribute("id");
				const XmlElement@ sealInfo = getVehicleInfo(m_metagame, sealId);
				if (sealInfo !is null) {
					float sealHealth = sealInfo.getFloatAttribute("health");
					if (sealHealth > 0.0) {
						addMarker(sealId * 7 + m_markerOffset, sealPos, "default", true, false, 28);
					}
					updateSeal(sealId, sealPos, sealHealth, true);
				} else {
					updateSeal(sealId, sealPos, 0.0, true);
				}
			}
		}
	}
}