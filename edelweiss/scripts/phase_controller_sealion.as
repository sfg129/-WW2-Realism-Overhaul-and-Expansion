#include "tracker.as"
#include "phase_controller.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "resource_helpers.as"
#include "helpers2.as"
#include "phase_helpers.as"

// --------------------------------------------
class SealionPhase0 : DefPhaseBase {
	// --------------------------------------------
	SealionPhase0(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhaseBase::start();
		_log("SealionPhase0 starting");

		if (_logger.m_logLevel >= 1) {
			announce("TEST: SealionPhase0 starting");
		}
      
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}
		
		// make citadel uncapturable so that it'll be that last base
		m_metagame.getComms().send("<command class='update_base' base_key='citadel' capturable='0' />");
	}

	// --------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		// in phase0, watch for base owner change events, use getBases and check that those specific bases are owned by the friendlies
		
		// actually, when enemy owns citadel only (it's their last base), end phase 0

		if (getBasesForFaction(m_metagame, 1) == 1) {
			end();
		}
	}
};

// --------------------------------------------
class SealionPhaseBoss : DefPhaseBase {
	protected string m_bossVehicle;
	protected float m_timer = 0.0;

	// --------------------------------------------
	SealionPhaseBoss(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
		m_bossVehicle = "tog2_boss.vehicle";
	}

	// --------------------------------------------
	void start() {
		DefPhaseBase::start();
		_log("SealionPhaseBoss starting");
        
		{
			// make all friendly faction soldier groups not drive
			int factionId = 0;
			array<const XmlElement@>@ groups = getSoldierGroups(m_metagame, factionId);
			for (uint i = 0; i < groups.size(); ++i) {
				const XmlElement@ group = groups[i];
				string name = group.getStringAttribute("name");

				XmlElement command("command");
				command.setStringAttribute("class", "soldier_ai");
				command.setIntAttribute("faction_id", factionId);
				command.setStringAttribute("soldier_group_name", name);

				XmlElement parameter("parameter");
				parameter.setStringAttribute("class", "uses_vehicles");
				parameter.setIntAttribute("value", 0);
				command.appendChild(parameter);

				m_metagame.getComms().send(command);
			}
		}
			
		{
			// make all enemy faction soldier groups not drive, except one
			int factionId = 1;
			string skipThisGroup = "commando";
			array<const XmlElement@>@ groups = getSoldierGroups(m_metagame, factionId);
			for (uint i = 0; i < groups.size(); ++i) {
				const XmlElement@ group = groups[i];
				string name = group.getStringAttribute("name");
				
				if (name == skipThisGroup) continue;

				XmlElement command("command");
				command.setStringAttribute("class", "soldier_ai");
				command.setIntAttribute("faction_id", factionId);
				command.setStringAttribute("soldier_group_name", name);

				XmlElement parameter("parameter");
				parameter.setStringAttribute("class", "uses_vehicles");
				parameter.setIntAttribute("value", 0);
				command.appendChild(parameter);

				m_metagame.getComms().send(command);
			}
		}

/*		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_1' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_2' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_3' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_4' destroyed='1' />"); 
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_5' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_6' destroyed='1' />");                             
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_7' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_8' destroyed='1' />"); 
        m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_9' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_10' destroyed='1' />");                             
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_11' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_12' destroyed='1' />"); 
        m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_13' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_14' destroyed='1' />");    
        m_metagame.getComms().send("<command class='update_static_object' key='wall_citadel_15' destroyed='1' />");                          
*/
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "sealion, boss, part 1"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "sealion, boss, part 2"));
		
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}
	
		if (_logger.m_logLevel >= 1) {
			announce("TEST: SealionPhaseBoss starting");
		}

		// timer not needed for seaion
		//m_timer = 1.0 * 60.0;
	
		// make bases uncapturable
		array<const XmlElement@> bases = getBases(m_metagame);
		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base.getBoolAttribute("capturable")) {
				XmlElement command("command");
				command.setStringAttribute("class", "update_base");
				command.setIntAttribute("base_id", base.getIntAttribute("id"));
				command.setIntAttribute("capturable", 0);
				m_metagame.getComms().send(command);
			}
		}
		
		// force capture enemy bases except the intended last one, allows proper testing by skipping phases 
		string lastBaseKey = "citadel";
		{
			array<const XmlElement@> baseList = getBases(m_metagame);
			for (uint i = 0; i < baseList.size(); ++i) {
				const XmlElement@ base = baseList[i];
				string baseKey = base.getStringAttribute("key");
				if (base.getIntAttribute("owner_id") == 1 && baseKey != lastBaseKey) {
					XmlElement command("command");
					command.setStringAttribute("class", "update_base");
					command.setIntAttribute("owner_id", 0);
					command.setStringAttribute("base_key", baseKey);
					m_metagame.getComms().send(command);
				}
			}
		}
		
		// special troops (not the default soldiers) need to spawn and fight alongside it until it is destroyed 
		// (ideally spawning at a paced value with a limit to their capacity.)
		{
			// make other soldier groups' spawn scores 0 except the specific troop group and use the usual spawnpoints in the final base
			array<const XmlElement@>@ groups = getSoldierGroups(m_metagame, 1);
			for (uint i = 0; i < groups.size(); ++i) {
				const XmlElement@ group = groups[i];
				float spawnScore = 0.0;
				string name = group.getStringAttribute("name");
				if (name == "commando") {
					spawnScore = 1.0;
				}
				if (name == "commando_sentry") {
					spawnScore = 0.075;	//was 0.15
				}
				XmlElement command("command");
				command.setStringAttribute("class", "faction");
				command.setIntAttribute("faction_id", 1);
				command.setStringAttribute("soldier_group_name", name);
				command.setFloatAttribute("spawn_score", spawnScore);
				m_metagame.getComms().send(command);
			}
			
			// TODO:
			// set spawn_interval and capacity accordingly in enemy faction settings
			{
				XmlElement command("command");
				command.setStringAttribute("class", "change_game_settings");
				// hmm, if it's a problem that the last base area can have its spawnpoints disabled by overwhelming the center with friendlies
				// it's possible to change the base capture system to none here
				
				XmlElement f1("faction");
                f1.setFloatAttribute("capacity_multiplier", 0.35);
				f1.setIntAttribute("disable_enemy_spawnpoints_soldier_count_offset", -100);
				command.appendChild(f1);

				// TODO: set enemy capacity parameters here
				// capacity_offset, capacity_multiplier, spawn_interval
				XmlElement f2("faction");
				f2.setFloatAttribute("capacity_multiplier", 0.00001);
                f2.setFloatAttribute("capacity_offset", 20);                // was 14
				command.appendChild(f2);

				m_metagame.getComms().send(command);
			}
			
		}
		
		// TODO:
		// consider having the last base owned by fake enemy faction which is neutral with color that looks like enemy
		// and thus won't spawn anyone in the castle too early and enemy doesn't need to care about defending it
		
		//friendly AI attack the final base even though it cannot be captured:
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.6' border_defense='0.0' attack_start_spread='0' attack_target_spread='0' attack_target_base_key='" + lastBaseKey + "' />");
        m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='1.0' border_defense='0.0'");
		
		// when player has reached final objective, we need to spawn in and crew a special Boss Tank that must be killed to win the match.
		{
			Vector3 position(163, 8, 861);
			Vector3 jammer(135, 8, 883);
			string orientation("0 0 0 1");
			
			array<const XmlElement@>@ nodes = getGenericNodes(m_metagame, "", "boss_tank");
			if (nodes.size() > 0) {
				position = stringToVector3(nodes[0].getStringAttribute("position"));
				orientation = nodes[0].getStringAttribute("orientation");
			}				
			
			XmlElement command("command");
			command.setStringAttribute("class", "create_instance");
			command.setIntAttribute("faction_id", 1);
			command.setStringAttribute("position", position.toString());
			command.setStringAttribute("orientation", orientation);
			command.setStringAttribute("instance_class", "vehicle");
			command.setStringAttribute("instance_key", m_bossVehicle);
			m_metagame.getComms().send(command);
			
			// spawn crew too
			position = position.add(Vector3(5.0,0.0,0.0));	//handles crew position
			m_metagame.addTracker(Spawner(m_metagame, 1, position, 30, "commando")); 
			// jammer protectors 
			m_metagame.addTracker(Spawner(m_metagame, 1, jammer, 10, "commando")); 
			//m_metagame.addTracker(Spawner(m_metagame, 1, position, 10, "default"));     //i don't think this is necessary       
		}
		{
			// insta-kill friendlies in Citadel
			array<const XmlElement@> nodes = getGenericNodes(m_metagame, "", "unsafezone");
			array<string> unsafeBlocks = array<string>(0);
			for (uint i = 0; i < nodes.length(); ++i) {
				const XmlElement@ node = nodes[i];
				string coordinate = node.getStringAttribute("block");
				_log("marking block " + coordinate + " unsafe", 1);
				unsafeBlocks.insertLast(coordinate);
			}

			if (unsafeBlocks.size() > 0) {
				// faction id 0
				array<const XmlElement@> characters = getCharactersInBlocks(m_metagame, 0, unsafeBlocks);
				if (characters !is null) {
					for (uint j = 0; j < characters.length(); ++j) {
						const XmlElement@ character = characters[j];
						int id = character.getIntAttribute("id");
						string command = "<command class='update_character' id='" + id + "' dead='1' preserve_items='1' />";
						m_metagame.getComms().send(command);
					}
				}
			}
		}		
	}

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		// The boss tank must be killed to win the match,
		// watch for boss tank destroy event to end final boss phase or call match end, probably similar to map12 stuff
		string key = event.getStringAttribute("vehicle_key");
		if (key == m_bossVehicle) {
			_log("DefPhaseBoss, vehicle being destroyed, key " + key); 
			end();
		}
	}

	// -------------------------------------------- commented out because it's not required for sealion
/*	void update(float time) {
		if (m_timer > 0.0) {
			m_timer -= time;
			if (m_timer <= 0.0) {
				// check if either radio_jammer.vehicle or radio_jammer_2.vehicle is alive
				bool alive = false;
				array<string> keys = {"radio_jammer.vehicle", "radio_jammer_2.vehicle"};
				for (uint i = 0; i < keys.size() && !alive; ++i) {
					array<const XmlElement@>@ vehicles = getVehicles(m_metagame, 1, keys[i]);
					for (uint j = 0; j < vehicles.size() && !alive; ++j) {
						const XmlElement@ vehicle = getVehicleInfo(m_metagame, vehicles[j].getIntAttribute("id"));
						if (vehicle !is null) {
							float health = vehicle.getFloatAttribute("health");
							if (health > 0.0) {
								alive = true;
							}
						}
					}
				}
				if (alive) {
//					sendFactionMessageKey(m_metagame, 0, "varsity radio tower hint 1", dictionary = {}, 1.0);
//                    sendFactionMessageKey(m_metagame, 0, "varsity radio tower hint 2", dictionary = {}, 1.0);
            m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "varsity radio tower hint 1"));
            m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "varsity radio tower hint 2"));
				}
			}
		}
	}*/

	// --------------------------------------------
	void save(XmlElement@ root) {
		DefPhaseBase::save(root);
		
		root.setFloatAttribute("timer", m_timer);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		DefPhaseBase::load(root);

		m_timer = root.getFloatAttribute("timer");
	}
};


// --------------------------------------------
class PhaseControllerSealion : PhaseControllerBase {
	// --------------------------------------------
	PhaseControllerSealion(GameModeInvasion@ metagame, float enemySpawnCompensationFactor) {
		super(metagame, "sealion", enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void reset() {
		PhaseControllerBase::reset();
		
		m_phases.insertLast(SealionPhase0(m_metagame, this, m_enemySpawnCompensationFactor));	
		m_phases.insertLast(SealionPhaseBoss(m_metagame, this, m_enemySpawnCompensationFactor));
	}
}
