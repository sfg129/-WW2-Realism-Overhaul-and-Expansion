#include "metagame.as"
#include "tracker.as"
#include "helpers.as"

// --------------------------------------------
class BossMusic : Tracker {
	protected Metagame@ m_metagame;
	protected string m_filename;
	protected float m_firstRange;
	protected float m_range;
	protected float m_fuzzyMargin;
	protected float m_volume;
	// status is int, per client
	// -1 -> reset, first range not reached
	// 0 -> stopped, first range has been reached
	// 1 -> playing, first range has been reached
	protected dictionary m_status;
	protected float m_timer;
	protected array<int> m_vehicleIds;
	protected string m_vehicleKey;
	
	// --------------------------------------------
	BossMusic(Metagame@ metagame, string soundtrackFilename, string vehicleKey, float firstRange = 30.0f, float range = 50.0f, float fuzzyMargin = 10.0f, float volume = 1.0) {
		@m_metagame = @metagame;
		m_filename = soundtrackFilename;
		m_vehicleKey = vehicleKey;
		m_firstRange = firstRange;
		m_range = range;
		m_fuzzyMargin = fuzzyMargin; 
		m_volume = volume;
		// e.g. range 50, fuzzy margin 10
		// if soundtrack isn't playing, it begins when distance is 50-10 = 40
		// if soundtrack is playing, it stops when distance is 50+10 = 60
	
		m_timer = 0.0f;
	}

	// --------------------------------------------
	bool hasStarted() const {
      return true; 
	}
	
	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// ----------------------------------------------------
	void onRemove() {
		m_vehicleIds.clear();
		m_status.clear();
	}

	// --------------------------------------------
	void playSoundtrack(int playerId) {
		//sendFactionMessage(m_metagame, 0, "play soundtrack", 1.0);

		XmlElement command("command");
		command.setStringAttribute("class", "set_soundtrack");
		command.setIntAttribute("enabled", 1);
		command.setIntAttribute("player_id", playerId);
		command.setStringAttribute("filename", m_filename);
		command.setFloatAttribute("volume", m_volume);
		m_metagame.getComms().send(command);
		m_status[formatInt(playerId)] = 1;
	}

	// --------------------------------------------
	void stopSoundtrack(int playerId) {
		//sendFactionMessage(m_metagame, 0, "stop soundtrack", 1.0);

		XmlElement command("command");
		command.setStringAttribute("class", "set_soundtrack");
		command.setIntAttribute("enabled", 0);
		command.setIntAttribute("player_id", playerId);
		command.setStringAttribute("filename", m_filename);
		m_metagame.getComms().send(command);
		m_status[formatInt(playerId)] = 0;
	}

	// --------------------------------------------
	protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
		// clear playing status on disconnect
		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
			int playerId = player.getIntAttribute("player_id");
			if (playerId >= 0) {
				m_status[formatInt(playerId)] = -1;
			} 
		}
	}

	// --------------------------------------------
	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (key == m_vehicleKey) {
			int id = event.getIntAttribute("vehicle_id");
			if (m_vehicleIds.find(id) < 0) {
				m_vehicleIds.insertLast(id);
			}
			_log("BossMusic: vehicle " + m_vehicleKey + " spawned, id=" + id, 1);
		}
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0f) {
			refresh();
			m_timer = 2.0f;
		}
	}

	// --------------------------------------------
	void refresh() {
		if (m_vehicleIds.size() == 0) {
			// suitable vehicle hasn't yet spawned
			return;
		}

	
		// - tracks distance between each client and the boss tank
		// - closer to certain distance sets the soundtrack
		// - farther than that distance + margin unsets it
				
		array<const XmlElement@>@ players = getPlayers(m_metagame);
		for (uint i = 0; i < players.size(); ++i) {
			const XmlElement@ player = players[i];
			if (player.hasAttribute("aim_target")) {
				Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
				int playerId = player.getIntAttribute("player_id"); 
				if (playerId >= 0) {
				
					// if status doesn't exist for this player yet, add it as reset value
					if (!m_status.exists(formatInt(playerId))) {
						m_status[formatInt(playerId)] = -1;
					}
					int status = int(m_status[formatInt(playerId)]);
				
					// default to stop playing
					bool play = false;
					
					for (uint j = 0; j < m_vehicleIds.size(); ++j) {
						int vehicleId = m_vehicleIds[j];
						const XmlElement@ vehicle = getVehicleInfo(m_metagame, vehicleId);
						if (vehicle !is null) {
							Vector3 bossPosition = stringToVector3(vehicle.getStringAttribute("position"));

							float bossHealth = vehicle.getFloatAttribute("health");
						
							_log("checking range, " + target.toString() + " -> " + bossPosition.toString(), 1);
						
							if (status == 1) {
								play = true;
								// playing already, watch for stopping it
								if (bossHealth <= 0.0f ||
									!checkRange(target, bossPosition, m_range + m_fuzzyMargin)) {
									_log("far enough to stop", 1);
									play = false;
								}
							} else if (status == 0) {
								play = false;
								// not playing, not first time, watch for starting it
								if (bossHealth > 0.0f &&
									checkRange(target, bossPosition, m_range - m_fuzzyMargin)) {
									_log("close enough to start", 1);
									play = true;
								}
							} else { // status == -1
								play = false;
								// not playing, first time, watch for starting it
								if (bossHealth > 0.0f &&
									checkRange(target, bossPosition, m_firstRange)) {
									_log("close enough to start, first time", 1);
									play = true;
								}
							}
						}
						// one vehicle ok for playing is enough to play
						if (play) {
							break;
						}
					}
					
					if (play && status <= 0) {
						// if needs to play and not playing
						playSoundtrack(playerId);
					} else if (!play && status > 0) {
						// if needs to stop and playing
						stopSoundtrack(playerId);
					} else {
						// ignore everything else
					}
					
				}
			}
		}
	}
}





	
