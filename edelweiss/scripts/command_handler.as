// internal
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

// --------------------------------------------
class CommandHandler : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	CommandHandler(Metagame@ metagame) {
		@m_metagame = @metagame;
	}
	
	// ----------------------------------------------------
	protected void handleChatEvent(const XmlElement@ event) {
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

		// admin only from here on
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

		// it's a silent server command, check which one
		if (checkCommand(message, "0_own")) {
			int factionId = 0;
			array<const XmlElement@> bases = getBases(m_metagame);
			for (uint i = 0; i < bases.size(); ++i) {
				const XmlElement@ base = bases[i];
				if (base.getIntAttribute("owner_id") != factionId &&
				    base.getBoolAttribute("capturable")) {
					XmlElement command("command");
					command.setStringAttribute("class", "update_base");
					command.setIntAttribute("base_id", base.getIntAttribute("id"));
					command.setIntAttribute("owner_id", factionId);
					m_metagame.getComms().send(command);

					killCharactersNearPosition(m_metagame, stringToVector3(base.getStringAttribute("position")), 1, 150.0f);
					//break;
				}
			}
		} else if(checkCommand(message, "katana")) {
			spawnInstanceNearPlayer(senderId, "katana.weapon", "weapon", 0);
		} else if (checkCommand(message, "kar43")) {
			spawnInstanceNearPlayer(senderId, "kar43.weapon", "weapon", 0);
		} else if (checkCommand(message, "c96")) {
			spawnInstanceNearPlayer(senderId, "c96.weapon", "weapon", 0);
		} else if (checkCommand(message, "ostvet")) {
			spawnInstanceNearPlayer(senderId, "kar43_s_explosive.weapon", "weapon", 0);
		} else if (checkCommand(message, "mg42_assault")) {
			spawnInstanceNearPlayer(senderId, "mg42_assault.weapon", "weapon", 0);
		} else if (checkCommand(message, "vickers_k")) {
			spawnInstanceNearPlayer(senderId, "vickers_k.weapon", "weapon", 0);
		} else if (checkCommand(message, "lanchester")) {
			spawnInstanceNearPlayer(senderId, "lanchester_smg.weapon", "weapon", 0);
		} else if (checkCommand(message, "panzerschreck")) {
			spawnInstanceNearPlayer(senderId, "panzerschreck.weapon", "weapon", 0);
		} else if (checkCommand(message, "rifles")) {
			spawnInstanceNearPlayer(senderId, "kar98k.weapon", "weapon", 0);
			spawnInstanceNearPlayer(senderId, "kar98k.weapon", "weapon", 0);
			spawnInstanceNearPlayer(senderId, "kar98k.weapon", "weapon", 0);
			spawnInstanceNearPlayer(senderId, "kar98k_b.weapon", "weapon", 0);
			spawnInstanceNearPlayer(senderId, "kar98k_b.weapon", "weapon", 0);
		} else if (checkCommand(message, "fieldmodified")) {
			spawnInstanceNearPlayer(senderId, "m1_garand_rifle_grenade_he.weapon", "weapon", 0);
		
		}
          else if (checkCommand(message, "kastu")) {
			spawnInstanceNearPlayer(senderId, "kastu.vehicle", "vehicle", 0);
		}
          else if (checkCommand(message, "m4")) {
			spawnInstanceNearPlayer(senderId, "m4_V.vehicle", "vehicle", 0);
		}
          else if (checkCommand(message, "tiger")) {
			spawnInstanceNearPlayer(senderId, "tiger.vehicle", "vehicle", 0);
		}
          else if (checkCommand(message, "king")) {
			spawnInstanceNearPlayer(senderId, "king_tiger.vehicle", "vehicle", 0);
		}
          else if (checkCommand(message, "maus")) {
			spawnInstanceNearPlayer(senderId, "maus_boss.vehicle", "vehicle", 0);
		}
          else if (checkCommand(message, "tog")) {
			spawnInstanceNearPlayer(senderId, "tog2_boss.vehicle", "vehicle", 0);
		}
          else if (checkCommand(message, "blitz2")) {
			spawnInstanceNearPlayer(senderId, "opel_blitz_2.vehicle", "vehicle", 0);
		}        
          else if (checkCommand(message, "ct")) {
			spawnInstanceNearPlayer(senderId, "cargo_tank.vehicle", "vehicle", 0);
		
		} else if(checkCommand(message, "kill_cg")) {
			destroyAllEnemyVehicles("coastal_gun.vehicle");
		} else if(checkCommand(message, "kill_rt")) {
			destroyAllEnemyVehicles("radar_tower.vehicle");
		} else if(checkCommand(message, "kill_ct")) {
			destroyAllVehicles("cargo_tank.vehicle");
		} else if(checkCommand(message, "bergetiger")) {
			spawnInstanceNearPlayer(senderId, "repair_tank.vehicle", "vehicle", 0);
		}                 
	}

	// ----------------------------------------------------
	protected void spawnInstanceNearPlayer(int senderId, string key, string type, int factionId = 0) {
		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
		if (playerInfo !is null) {
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
			if (characterInfo !is null) {
				Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));
				pos.m_values[0] += 5.0;
				string c = "<command class='create_instance' instance_class='" + type + "' instance_key='" + key + "' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
				m_metagame.getComms().send(c);
			}
		}
	}

	// ----------------------------------------------------
	protected void destroyAllEnemyVehicles(string key) {
		for (uint f = 1; f < 3; ++f) {
			array<const XmlElement@>@ vehicles = getVehicles(m_metagame, f, key);
			for (uint i = 0; i < vehicles.size(); ++i) {
				const XmlElement@ vehicle = vehicles[i];
				int id = vehicle.getIntAttribute("id");
				destroyVehicle(m_metagame, id);
			}
		}
	}
			
	// ----------------------------------------------------
	protected void destroyAllVehicles(string key) {
		for (uint f = 0; f < 3; ++f) {
			array<const XmlElement@>@ vehicles = getVehicles(m_metagame, f, key);
			for (uint i = 0; i < vehicles.size(); ++i) {
				const XmlElement@ vehicle = vehicles[i];
				int id = vehicle.getIntAttribute("id");
				destroyVehicle(m_metagame, id);
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
		// always on
		return true;
	}
}
