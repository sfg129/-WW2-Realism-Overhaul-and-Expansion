#include "tracker.as"
#include "phase_controller.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "resource_helpers.as"
#include "helpers2.as"
#include "phase_helpers.as"

// Heavily modified Edelweiss Varsity phase controller by Unit G17

// --------------------------------------------
class VarsityPhase0 : DefPhaseBase {
	protected float m_timer = 0;
	protected float m_changeInterval = 60.0f;
	protected float m_reminderInterval = 120.0f;
	protected float m_timer2 = m_reminderInterval;
	array<array<string>> factionBases = {{}, {}, {}};
	
	// --------------------------------------------
	VarsityPhase0(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhaseBase::start();
		_log("VarsityPhase0 starting");

		if (_logger.m_logLevel >= 1) {
			announce("TEST: VarsityPhase0 starting");
		}
		
		array<const XmlElement@> baseList = getBases(m_metagame);
		for (uint i = 0; i < baseList.size(); ++i) {
			if (baseList[i].getStringAttribute("key") == "castle") {
				continue;
			}
			if (baseList[i].getIntAttribute("owner_id") == 1) {
				factionBases[1].insertLast(baseList[i].getStringAttribute("key"));
			} else {
				factionBases[2].insertLast(baseList[i].getStringAttribute("key"));
			}
		}
      
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}
	}

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		int totalSeals = 0;
		int remainingSeals = 0;
		if (event.getStringAttribute("vehicle_key") == "occult_seal.vehicle") {
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 2.0, 0, "undead varsity progress report pt 1"));
			for (uint f = 1; f < 3; ++f) {
				array<const XmlElement@>@ occultSeals = getVehicles(m_metagame, f, "occult_seal.vehicle");
				for (uint i = 0; i < occultSeals.length(); ++i) {
					int sealId = occultSeals[i].getIntAttribute("id");
					const XmlElement@ sealInfo = getVehicleInfo(m_metagame, sealId);
					if (sealInfo !is null) {
						float sealHealth = sealInfo.getFloatAttribute("health");
						if (sealHealth > 0.0) {
							//return;
							++remainingSeals;
						}
						++totalSeals;
					}
				}
			}
			if (remainingSeals == 0) {
				end();
			} else if (remainingSeals <= 3) {
				dictionary a = {
					{"%remaining_seals", formatInt(remainingSeals)}
				};
				int b = rand(0, 1);
				if (b == 0) {
					m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity progress report pt 2", a));
				} else {
					m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity progress report pt 2 alt", a));
				}
			} else {
				dictionary a = {
					{"%completed_seals", formatInt(totalSeals - remainingSeals)},
					{"%total_seals", formatInt(totalSeals)}
				};
				int b = rand(0, 1);
				if (b == 0) {
					m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity progress report pt 3", a));
				} else {
					m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity progress report pt 3 alt", a));
				}
			}
		}
	}
	
	// ----------------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer <= 0.0f) {
			for (uint i = 1; i < 3; ++i) {
				//since all bases are uncapturable the commander would never issue attack order normally, thus we manually set them
				//this forces the armies to move around
				string baseKey = factionBases[3-i][rand(0, factionBases[3-i].size() - 1)];
				m_metagame.getComms().send("<command class='commander_ai' faction='" + formatInt(i) + "' attack_target_base_key='" + baseKey + "' />");			
				_log("Faction " + formatInt(i) + " attack target base key: " + baseKey);
			}	
			m_timer = m_changeInterval;
		}
		m_timer2 -= time;
		if (m_timer2 <= 0.0f) {
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity reminder"));
			m_timer2 = m_reminderInterval;
		}
	}
};

// --------------------------------------------
class VarsityPhaseBoss : DefPhaseBase {
	protected string m_bossRemnant = "nachtjaeger_final_boss_1";
	protected string m_bossUndead = "zombie_final_boss_1";
	protected string m_bossCharacter;
	protected int m_bossFaction;
	protected int m_bossId = -1;
	protected float m_timer = 0;
	protected float m_reminderInterval = 120.0f;
	protected float m_timer2 = m_reminderInterval;
	protected Vector3 m_position;

	// --------------------------------------------
	VarsityPhaseBoss(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhaseBase::start();
		_log("VarsityPhaseBoss starting");
        
		m_metagame.getComms().send("<command class='update_static_object' key='wall_door' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_door1' destroyed='1' />");
		m_metagame.getComms().send("<command class='update_static_object' key='wall_door2' destroyed='1' />"); 
		m_metagame.getComms().send("<command class='update_static_object' key='wall_door3' destroyed='1' />");                       
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity gate open pt 1"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity gate open pt 2"));
		
		getBossInfo();
		
		// makes enemy factions passive
		m_metagame.getComms().send("<command class='commander_ai' faction='1' attack_target_base_key='' />");
		m_metagame.getComms().send("<command class='commander_ai' faction='2' attack_target_base_key='' />");		
		m_metagame.getComms().send("<command class='commander_ai' faction='1' active='0' />");
		m_metagame.getComms().send("<command class='commander_ai' faction='2' active='0' />");
		
		m_position = Vector3(799.0, 2.0, 202.0);			
		/*array<const XmlElement@>@ nodes = getGenericNodes(m_metagame, "", "boss_tank");
		if (nodes.size() > 0) {
			m_position = stringToVector3(nodes[0].getStringAttribute("position"));
		}*/

		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			findBoss();
			return;
		}
	
		if (_logger.m_logLevel >= 1) {
			announce("TEST: VarsityPhaseBoss starting");
		}

		{
			XmlElement command("command");
			command.setStringAttribute("class", "create_instance");
			command.setIntAttribute("faction_id", m_bossFaction);
			command.setStringAttribute("position", m_position.toString());
			command.setStringAttribute("instance_class", "soldier");
			command.setStringAttribute("instance_key", m_bossCharacter);
			m_metagame.getComms().send(command);
			
			//now let's find the boss, so we can track them
			findBoss();
			
			// spawn squad too
			/*if (m_bossFaction == 1) {
				m_metagame.addTracker(Spawner(m_metagame, 1, m_position, 5, "nachtjaeger_fsj"));
			} else {
				m_metagame.addTracker(Spawner(m_metagame, 2, m_position, 10, "shambler_default"));
			}*/
		}
	}

	// --------------------------------------------
	void update(float time) {
		//note: update happens only after the start function has finished
		//here this means that the script already obtained the character id of the boss
		const XmlElement@ info = getCharacterInfo(m_metagame, m_bossId);

		// checking character type in case the boss dies and the character id is used by a new, different soldier, tho most likely this would never happen
		if (info is null) {
			endBossMarker();
			end();
			return;
		} else if (info.getIntAttribute("dead") == 1 || info.getStringAttribute("soldier_group_name") != m_bossCharacter) {
			endBossMarker();
			end();
			return;
		} else {
			setBossMarker(info.getStringAttribute("position"));
		}
			
		m_timer -= time;
		if (m_timer < 0) {
			//this ensures that the boss won't leave the boss arena
			setBossObjective();
			reinforceBoss(stringToVector3(info.getStringAttribute("position")));
			m_timer = 60.0f;
		}
		m_timer2 -= time;
		if (m_timer2 <= 0.0f) {
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity gate open pt 3 reminder"));
			m_timer2 = m_reminderInterval;
		}
	}
	
	// --------------------------------------------
	void getBossInfo() {		
		array<const XmlElement@> baseList = getBases(m_metagame);
		for (uint i = 0; i < baseList.size(); ++i) {
			if (baseList[i].getStringAttribute("key") == "castle") {
				if (baseList[i].getIntAttribute("owner_id") == 1) {
					m_bossFaction = 1;
					m_bossCharacter = m_bossRemnant;
				} else {
					m_bossFaction = 2;
					m_bossCharacter = m_bossUndead;
				}
				break;
			}
		}
	}
	
	// --------------------------------------------
	void findBoss() {
		array<const XmlElement@> characters = getCharacters(m_metagame, m_bossFaction);
		int characterId;
		for (uint i = 0; i < characters.length(); ++i) {
			characterId = characters[i].getIntAttribute("id");
			const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
			if (info !is null) {
				if (info.getStringAttribute("soldier_group_name") == m_bossCharacter) {
					m_bossId = characterId;
					int b = rand(0, 1);
					if (b == 0) {
						m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity boss dialogue 1"));
					} else {
						m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "undead varsity boss dialogue 2"));
					}
				}
			}
		}
		if (m_bossId == -1) {
			_log("Failed to find boss");
			endBossMarker();
			end();
		}
	}

	// --------------------------------------------	
	void setBossMarker(string position) {
		XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", 20000);
			command.setIntAttribute("faction_id", 0);				
			command.setIntAttribute("atlas_index", 2);
			command.setFloatAttribute("size", 0.5);
			command.setFloatAttribute("range", 0.0);
			command.setIntAttribute("enabled", 1);
			command.setStringAttribute("position", position);
			command.setStringAttribute("text", "Boss " + getBossHealth() + "%");
			command.setStringAttribute("type_key", "default");
			command.setStringAttribute("color", "#ffffff");
			command.setBoolAttribute("show_in_map_view", true);
			command.setBoolAttribute("show_in_game_view", false);
			command.setBoolAttribute("show_at_screen_edge", true);
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------	
	void endBossMarker() {
		XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", 20000);
			command.setIntAttribute("enabled", 0);
			command.setIntAttribute("faction_id", 0);
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------	
	void setBossObjective() {
		XmlElement command("command");
			command.setStringAttribute("class", "soldier_objective");
			command.setIntAttribute("character_id", m_bossId);
			command.setStringAttribute("objective", "defend");
			command.setStringAttribute("target", m_position.toString());
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------	
	string getBossHealth() {
		//modified getCharacterInfo, includes equipment
		const XmlElement@ characterInfo = getCharacterInfo2(m_metagame, m_bossId);
		if (characterInfo is null) return "0";
		
		array<const XmlElement@>@ equipment = characterInfo.getElementsByTagName("item");
		string vestKey = equipment[4].getStringAttribute("key");
		if (m_bossFaction == 1) {
			string s = vestKey.substr(24);	//ww2_undead_axr_overlord_#
			if (s == "carry_item") {
				return "100";
			} else {
				int layer = parseInt(s);
				return formatInt(int(100 * (51 - layer) / 50));
			}
		} else {
			string s = vestKey.substr(27);	//ww2_undead_zombie_overlord_#
			if (s == "carry_item") {
				return "100";
			} else {
				int layer = parseInt(s);
				return formatInt(int(100 * (61 - layer) / 60));
			}
		}
	}

	// --------------------------------------------	
	void reinforceBoss(Vector3 position) {
		array<const XmlElement@> enemies = getCharactersNearPosition(m_metagame, position, m_bossFaction, 60.0f);
		int enemyCount = enemies.size();
		position.m_values[0] += 2.0;
		if (m_bossFaction == 1 && enemyCount <= 3) {
			spawnInstance(position, "vehicle", "ww2_undead_fsj_flare_despawner.vehicle", 1);
		} else if (m_bossFaction == 2 && enemyCount <= 6) {
			spawnInstance(position, "vehicle", "ww2_undead_zombie_overlord_spawner.vehicle", 2);
		}
	}
	
	// ----------------------------------------------------
	protected void spawnInstance(Vector3 pos, string type, string key, int factionId) {
		string c = "<command class='create_instance' instance_class='" + type + "' instance_key='" + key + "' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
		m_metagame.getComms().send(c);
	}
	
	// --------------------------------------------
	void save(XmlElement@ root) {
		DefPhaseBase::save(root);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		DefPhaseBase::load(root);
	}
};


// --------------------------------------------
class PhaseControllerVarsity : PhaseControllerBase {

	// --------------------------------------------
	PhaseControllerVarsity(GameModeInvasion@ metagame, float enemySpawnCompensationFactor) {
		super(metagame, "varsity", enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void reset() {
		PhaseControllerBase::reset();
		
		m_phases.insertLast(VarsityPhase0(m_metagame, this, m_enemySpawnCompensationFactor));	
		m_phases.insertLast(VarsityPhaseBoss(m_metagame, this, m_enemySpawnCompensationFactor));
	}

	// --------------------------------------------	
	void start() {
		const array<Faction@>@ factions = m_metagame.getFactions();
		for(uint i = 0; i < factions.length(); ++i) {
			const XmlElement@ command = factions[i].m_defaultCommanderAiCommand;
			m_metagame.getComms().send(command);
		}
	
		PhaseControllerBase::start();
	}
	
	// --------------------------------------------	
	void completeMatch() {
		m_metagame.getComms().send("<command class='set_match_status' faction_id='2' lose='1' />");
	
		PhaseControllerBase::completeMatch();
		
		array<const XmlElement@> characters = getCharacters(m_metagame, 2);
		for (uint i = 0; i < characters.length(); ++i) {
			string command =
				"<command class='update_character'" +
				"	id='" + formatInt(characters[i].getIntAttribute("id")) + "'" +
				"	dead='1'>" + 
				"</command>";
			m_metagame.getComms().send(command);
		}
	}
	
	// ----------------------------------------------------
    protected void handleChatEvent(const XmlElement@ event) {
		Tracker::handleChatEvent(event);

		// player_id
		// player_name
		// message
		// global

		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

		if (checkCommand(message, "end_phase")) {
			Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.end();
		} else if (checkCommand(message, "boss_1")) {
			m_metagame.getComms().send("<command class='update_base' owner_id='1' base_key='castle' />");
		} else if (checkCommand(message, "boss_2")) {
			m_metagame.getComms().send("<command class='update_base' owner_id='2' base_key='castle' />");
		}
	}
}