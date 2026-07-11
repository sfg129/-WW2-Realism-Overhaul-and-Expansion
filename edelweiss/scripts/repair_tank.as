#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

	// --------------------------------------------
class RepairTank : Tracker {
	protected Metagame@ m_metagame;
	protected array<string> m_excludedVehicles;
	protected array<int> m_repairTanks;
	protected float m_interval = 2.0f;
	protected float m_timer = m_interval;

	// --------------------------------------------
	RepairTank(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_excludedVehicles = array<string> = {"cover1.vehicle"};
	}

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		//repair effect radius (at 5.0 or higher the crane repairs itself)
		float range;
		//the amount of health points added each repair cycle
		float repairValue = 0.0;
		//overrepair percentage
		float overHealth;	
		
		//vertical offset for repair position
		float y_offset;
		
		//xp reward for the repairer each repair cycle
		float xpReward = 0.0004;
		//rp reward for the repairer each repair cycle
		uint rpReward = 5;
		
		//checking if the event was triggered by a repair projectile
		string sourceKey = event.getStringAttribute("key");		
		
		if  (sourceKey == "repair_tank") {
			range = 3.5;
			repairValue = 0.5;
			overHealth = 1.0;
			y_offset = -5.0;
		} else if (sourceKey == "repair_tank_auto") {
            range = 4.0;
            repairValue = 0.5;
            overHealth = 1.0;
            y_offset = -3.5;
        } else if (sourceKey == "repair_torch") {
            range = 3.0;
            repairValue = 0.1;
            overHealth = 1.1;
            y_offset = 0.0;
            rpReward = 0;
            xpReward = 0.0;
        }
		
		bool hasRepaired = false;
		
		if (repairValue > 0.0) {
			//extracting the repairer's id
			int repairerId = event.getIntAttribute("character_id");
			int factionId = -1;
			
			if (sourceKey == "repair_tank_auto") {
				const XmlElement@ characterInfo = getCharacterInfo(m_metagame, repairerId);
				if (characterInfo !is null) {
					factionId = characterInfo.getIntAttribute("faction_id");
				}
			}
			
			//extracting the repair position
			Vector3 repairPos = stringToVector3(event.getStringAttribute("position"));
			repairPos = Vector3(repairPos.get_opIndex(0), repairPos.get_opIndex(1) + y_offset, repairPos.get_opIndex(2));

			//checking for all factions, including neutral
			for (uint f = 0; f < 4; ++f){
				//custom query, collects all vehicles of a faction
				array<const XmlElement@>@ vehicles = getAllVehicles(m_metagame, f);
				
				for (uint i = 0; i < vehicles.length(); ++i) {
					//collecting vehicle positions
					Vector3 vehiclePos = stringToVector3(vehicles[i].getStringAttribute("position"));
					
					//checking for vehicles within the repair radius and extracting their keys
                    if (checkRange(repairPos, vehiclePos, range)) {
                        int vehicleId = vehicles[i].getIntAttribute("id");
                        const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, vehicleId);
                        if (vehicleInfo !is null) {
                            string targetKey = vehicleInfo.getStringAttribute("key");
							
                            //checking that targetKey is not in m_excludedVehicles
                            if (m_excludedVehicles.find(targetKey) < 0) {
								
								//checking if the target vehicle has any enemies inside to prevent automatic repair applying to it
								if (sourceKey == "repair_tank_auto") {
									array<const XmlElement@> characterList = vehicleInfo.getElementsByTagName("character");
									int holderId = vehicleInfo.getIntAttribute("holder_id");
									
									//if it is a vehicle held by the enemy and somebody is inside, presumably an enemy, then don't repair
									if (holderId != factionId && characterList.length() > 0) {
										continue;
									}
								}
								
                                //repair tank can't fix repair tanks to prevent self repair
                                if (not((sourceKey == "repair_tank" || sourceKey == "repair_tank_auto") && (targetKey == "repair_tank.vehicle" || targetKey == "cargo_tank.vehicle"))) {
                                    float vehicleHealth = vehicleInfo.getFloatAttribute("health");

                                    //not running for destroyed vehicles
                                    if (vehicleHealth > 0.0) {
                                        float vehicleMaxHealth = vehicleInfo.getFloatAttribute("max_health");
                                        float vehicleMaxOverHealth = vehicleMaxHealth * overHealth;

                                        //only running the update command when necessary
                                        if (vehicleHealth < vehicleMaxOverHealth) {
                                            //rounding error fix
                                            vehicleMaxOverHealth += 0.01;

                                            string command = "";

                                            //calculating and applying repairs
                                            float vehicleHealthDifference = vehicleMaxOverHealth - vehicleHealth;
                                            if (vehicleHealthDifference > repairValue){
                                                vehicleHealth += repairValue;
                                                vehicleHealthDifference = repairValue;
                                                command = "<command class='update_vehicle' id='" + vehicleId + "' health='" + vehicleHealth + "' />";
                                            } else {
                                                command = "<command class='update_vehicle' id='" + vehicleId + "' health='" + vehicleMaxOverHealth + "' />";
                                            }
                                            m_metagame.getComms().send(command);

                                            //rewarding the repairer
                                            float xpRewardFinal = xpReward * vehicleHealthDifference;
                                            float rpRewardFinal = rpReward * vehicleHealthDifference;
                                            if (xpRewardFinal > 0.0) {
                                                command = "<command class='xp_reward' character_id='" + repairerId + "' reward='" + xpRewardFinal + "' />";
                                                m_metagame.getComms().send(command);
                                            }
                                            if (rpRewardFinal > 0.0) {
                                                command = "<command class='rp_reward' character_id='" + repairerId + "' reward='" + rpRewardFinal + "' />";
                                                m_metagame.getComms().send(command);
                                            }
											
											hasRepaired = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
			//playing sound if the automatic crane on the repair tank has repaired something
			if (sourceKey == "repair_tank_auto" && hasRepaired) {
				m_metagame.getComms().send("<command class='play_sound' filename='wrench_shot.wav' position='" + repairPos.toString() + "' />");
			}
        }
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
	protected void handleVehicleSpawnEvent(const XmlElement@ event)  {
		string vehicleKey = event.getStringAttribute("vehicle_key");
		if (vehicleKey == "repair_tank.vehicle" || vehicleKey == "cargo_tank.vehicle") {
			m_repairTanks.insertLast(event.getIntAttribute("vehicle_id"));
		}
	}
	
	// --------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event)  {
		string vehicleKey = event.getStringAttribute("vehicle_key");
		if (vehicleKey == "repair_tank.vehicle" || vehicleKey == "cargo_tank.vehicle") {
			int i = m_repairTanks.find(event.getIntAttribute("vehicle_id"));
			if (i >= 0) {
				m_repairTanks.removeAt(i);
			}
		}
	}
	
	// --------------------------------------------
	protected void refresh() {
		for (uint i = 0; i < m_repairTanks.length(); ++i) {
			const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, m_repairTanks[i]);
			
			int characterId;
			int factionId;
			array<const XmlElement@> characterList = vehicleInfo.getElementsByTagName("character");
			if (characterList.length() > 0) {
				if (characterList[0].getIntAttribute("slot_id") == 0) {
					characterId = characterList[0].getIntAttribute("id");
					const XmlElement@ characterInfo = getCharacterInfo(m_metagame, characterId);
					factionId = characterInfo.getIntAttribute("faction_id");
				} else {
					continue;
				}
			} else {
				continue;
			}
			
			Vector3 position = stringToVector3(vehicleInfo.getStringAttribute("position"));
			Vector3 forward = stringToVector3(vehicleInfo.getStringAttribute("forward"));
			Vector3 right = stringToVector3(vehicleInfo.getStringAttribute("right"));
			Vector3 up = Vector3(
				forward.get_opIndex(1) * right.get_opIndex(2) - forward.get_opIndex(2) * right.get_opIndex(1),
				forward.get_opIndex(2) * right.get_opIndex(0) - forward.get_opIndex(0) * right.get_opIndex(2),
				forward.get_opIndex(0) * right.get_opIndex(1) - forward.get_opIndex(1) * right.get_opIndex(0)
			);
			Vector3 spawnPos = position.add(forward.scale(-0.1)).add(up.scale(3.5)).add(right.scale(-3.75));
			
			string c = 
				"<command class='create_instance'" +
				" faction_id='" + factionId + "'" +
				" character_id='" + characterId + "'" +
				" instance_class='grenade'" +
				" instance_key='repair_tank_auto.projectile'" +
				" position='" + spawnPos.toString() + "' />";
			m_metagame.getComms().send(c);
		}
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			refresh();
			m_timer = m_interval;
		}
	}
}