#include "tracker.as"
#include "helpers.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

/*
Credits:
original idea and script - DoomMetal
polishing, timer - Unit G17
adapted for Edelweiss
*/

//when an strafing gun run is requested the caller's character and faction id, the call's position and id and the strike's direction are stored
class StrafeRequest {
	int m_characterId;
	Vector3 m_targetPos;
	int m_direction;
	int m_callId;
	int m_factionId;
	string m_callKey;
	float m_shadowTimer = 2.0;
	bool m_shadowRun = false;
	bool m_started = false;
	bool m_flybySoundPending = false;
	float m_flybyTimer = 0.0;
	
	StrafeRequest(int characterId, Vector3 targetPos, int direction, int callId, int factionId, string callKey){
		m_characterId = characterId;
		m_targetPos = targetPos;
		m_direction = direction;
		m_callId = callId;
		m_factionId = factionId;
		m_callKey = callKey;
	}
}

class StrafingRun : Tracker {
  protected Metagame@ m_metagame;
  protected bool m_running = false;
  protected array<StrafeRequest@> StrafeQueue;
  protected float m_pi = acos(-1.0f);

  StrafingRun(Metagame@ metagame) {
    @m_metagame = @metagame;
  }
	
protected void handleCallEvent(const XmlElement@ event) {


    // Hey we got a call!

    // Check call key
	string callKey = event.getStringAttribute("call_key");
    if (callKey == "airstrike2.call" || callKey == "airstrike3.call" || callKey == "airstrike4.call" || callKey == "airstrike5.call" || callKey == "airstrike6.call" || callKey == "airstrike7.call" || callKey == "airstrike8.call" || callKey == "airstrike9.call" || callKey == "airstrike10.call" || callKey == "airstrike11.call") {
		string phase = event.getStringAttribute("phase");
		
		int callId = event.getIntAttribute("id");
		
		//during the request all necessary information gets stored about the call, except for the marker the vehicle, it's done later
		if (phase == "queue") {
			int characterId = event.getIntAttribute("character_id");
			int factionId = event.getIntAttribute("faction_id");
			
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				Vector3 senderPos = stringToVector3(character.getStringAttribute("position"));
			Vector3 targetPos = stringToVector3(event.getStringAttribute("target_position"));
			
			//determining on which direction out of the 12 the current call fits the most
			int direction = gunRunDirection(senderPos, targetPos);

			StrafeRequest@ thisCall = StrafeRequest(characterId, targetPos, direction, callId, factionId, callKey);
			
			//placing ground marker and flag
			addMarker(thisCall);
			//the queue is necessary to handle multiple simultaneous strafing run requests
			StrafeQueue.insertLast(thisCall);
			}
		}

		//launch phase detection may have a minor detection inconsistency, projectile and marker handling moved to end phase
		if (phase == "launch") {
			for (uint i = 0; i < StrafeQueue.length() ; ++i){
				if (StrafeQueue[i].m_callId == callId){
					//announcing the aircraft's arrival and direction
					dictionary a = {
						{"%direction", formatInt(StrafeQueue[i].m_direction)}
					};
					sendFactionMessageKey(m_metagame, event.getIntAttribute("faction_id"), "aircraft coming", a);

					break;
				}
			}
		}
		
		//launching the projectiles and removing the marker
		if (phase == "end") {
			for (uint i = 0; i < StrafeQueue.length() ; ++i){
				if (StrafeQueue[i].m_callId == callId){
					//starting timer for the shadow
					m_running = true;
					StrafeQueue[i].m_started = true;
					
					//launching projectiles and removing the marker
					if (StrafeQueue[i].m_callKey == "airstrike3.call") {
						// Spawn one complete trajectory. The small height step makes all
						// 126 impacts sweep across the route in roughly half a second.
						// 0.1977 compensates for the height gradient and reduces the
						// actual spacing between adjacent impacts by 10%.
						gunRunLaunchProjectiles(StrafeQueue[i], 126, "strafing_run_50cal.projectile", 4.0, 0.1977, 0.12);
						StrafeQueue[i].m_flybySoundPending = true;
						// The calibrated base flight is about 0.66 seconds. A 0.5 second
						// sweep puts the last impact at about 0.91 seconds; wait 2.8 more.
						StrafeQueue[i].m_flybyTimer = 3.71;
					} else if (StrafeQueue[i].m_callKey == "airstrike4.call") {
						// Original payload: 21 rounds x 8 bullets = 168 bullets.
						// 0.06185 compensates for the height gradient and reduces the
						// current actual spacing by another 20% (36% below the original).
						gunRunLaunchProjectiles(StrafeQueue[i], 168, "strafing_run_50cal.projectile", 4.0, 0.06185, 0.12);
						StrafeQueue[i].m_flybySoundPending = true;
						StrafeQueue[i].m_flybyTimer = 3.71;
					} else if (StrafeQueue[i].m_callKey == "airstrike5.call") {
						// Spawn the full mixed payload at once; height offsets create a 0.5-second sweep.
						gunRunLaunchHeightSweep(StrafeQueue[i], "airstrike5.call");
						StrafeQueue[i].m_flybySoundPending = true;
						StrafeQueue[i].m_flybyTimer = 3.71;
					} else if (StrafeQueue[i].m_callKey == "airstrike6.call" || StrafeQueue[i].m_callKey == "airstrike7.call") {
						gunRunLaunchHeightSweep(StrafeQueue[i], StrafeQueue[i].m_callKey);
						StrafeQueue[i].m_flybySoundPending = true;
						if (StrafeQueue[i].m_callKey == "airstrike7.call") {
							StrafeQueue[i].m_flybyTimer = 5.5;
						} else {
							StrafeQueue[i].m_flybyTimer = 3.5;
						}
					} else if (StrafeQueue[i].m_callKey == "airstrike8.call" || StrafeQueue[i].m_callKey == "airstrike9.call" || StrafeQueue[i].m_callKey == "airstrike10.call" || StrafeQueue[i].m_callKey == "airstrike11.call") {
						gunRunLaunchHeightSweep(StrafeQueue[i], StrafeQueue[i].m_callKey);
						StrafeQueue[i].m_flybySoundPending = true;
						if (StrafeQueue[i].m_callKey == "airstrike8.call") {
							StrafeQueue[i].m_flybyTimer = 3.0;
						} else if (StrafeQueue[i].m_callKey == "airstrike10.call" || StrafeQueue[i].m_callKey == "airstrike11.call") {
							StrafeQueue[i].m_flybyTimer = 4.0;
						} else {
							StrafeQueue[i].m_flybyTimer = 3.5;
						}
					} else {
						StrafeQueue[i].m_shadowRun = true;
						gunRunLaunchProjectiles(StrafeQueue[i], 40, "strafing_run.projectile", 4.0);
					}
					removeMarker(StrafeQueue[i]);
					break;
				}
			}
		}
    }
  }
  
	// --------------------------------------------
	void update(float time) {
		for (uint i = 0; i < StrafeQueue.length() ; ++i){
			if (StrafeQueue[i].m_shadowRun == true){
				StrafeQueue[i].m_shadowTimer -= time;
				
				//once the timer ran out, the shadow is spawned
				if (StrafeQueue[i].m_shadowTimer < 0.0) {
					//spawning the plane shadow
					gunRunShadow(StrafeQueue[i]);
					StrafeQueue[i].m_shadowRun = false;
				}
			}

			if (StrafeQueue[i].m_flybySoundPending == true) {
				StrafeQueue[i].m_flybyTimer -= time;
				if (StrafeQueue[i].m_flybyTimer < 0.0) {
					m_metagame.getComms().send("<command class='play_sound' filename='airstrike_flyby.wav' position='" + StrafeQueue[i].m_targetPos.toString() + "' />");
					StrafeQueue[i].m_flybySoundPending = false;
				}
			}

			if (StrafeQueue[i].m_started && !StrafeQueue[i].m_shadowRun && !StrafeQueue[i].m_flybySoundPending) {
				StrafeQueue.removeAt(i);
				--i;
			}
		}
		if (StrafeQueue.length() == 0) m_running = false;
	}
  
  	int gunRunDirection(Vector3 senderPos, Vector3 targetPos) {
		// First we get the line from the sender to the target
		Vector3 sightLine = senderPos.subtract(targetPos);
		
		//calculating which direction it fits on the most out of the 12 possible orientations
		int direction = int( (((atan2(-sightLine.get_opIndex(2), -sightLine.get_opIndex(0))) / m_pi) * 180 + 195) / 30 );
		
		if (direction == 0) { direction = 12; }
		
		return direction;
	}
	
	Vector3 gunRunVector(int direction) {
		//recalculating the 3d vector from the direction data
		float angle = (float(direction) / 6) * m_pi;
				
		Vector3 attackVector = Vector3(sin(angle), 0, -cos(angle));
				
		return attackVector;
	}
  
  void addMarker(StrafeRequest@ StrafeRequest) {
	//placing the flag  
	Vector3 targetPos = StrafeRequest.m_targetPos;
	Vector3 direction = gunRunVector(StrafeRequest.m_direction);		
	int flagId = StrafeRequest.m_callId + 8000;
		
	XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", flagId);
		command.setIntAttribute("faction_id", StrafeRequest.m_factionId);
		command.setIntAttribute("atlas_index", 3);
		command.setFloatAttribute("size", 0.5);
		command.setFloatAttribute("range", 40.0);
		command.setIntAttribute("enabled", 1);
		command.setStringAttribute("position", targetPos.toString());
		command.setStringAttribute("text", "");
		command.setStringAttribute("type_key", "call_marker_a10_" + StrafeRequest.m_direction);
		command.setBoolAttribute("show_in_map_view", true);
		command.setBoolAttribute("show_in_game_view", true);
		command.setBoolAttribute("show_at_screen_edge", false);
		
	m_metagame.getComms().send(command);
  }
  
  void removeMarker(StrafeRequest@ StrafeRequest) {
	int flagId = StrafeRequest.m_callId + 8000;
	
	//removing the flag
	XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", flagId);
		command.setIntAttribute("enabled", 0);
		// A marker is identified within the faction that created it.
		command.setIntAttribute("faction_id", StrafeRequest.m_factionId);
	m_metagame.getComms().send(command);
  }
  
  void gunRunShadow(StrafeRequest@ StrafeRequest) {
	//extracting data
	int characterId = StrafeRequest.m_characterId;
	Vector3 targetPos = StrafeRequest.m_targetPos;
	Vector3 direction = gunRunVector(StrafeRequest.m_direction);
	
	//calculating the shadow projectile's starting position and speed
	Vector3 shadowPos = targetPos.subtract(direction.scale(-40));
	shadowPos.m_values[1] += 50.0;
	Vector3 shadowSpeed = direction.scale(-1);
	
	string c = 
	  "<command class='create_instance'" +
	  " faction_id='0'" +
	  " instance_class='grenade'" +
	  " instance_key='p47_shadow.projectile'" +
	  " position='" + shadowPos.toString() + "'" +
	  " character_id='" + characterId + "'" +
	  " offset='" + shadowSpeed.toString() + "' />";
	m_metagame.getComms().send(c);
  }
  
  void gunRunLaunchProjectiles(StrafeRequest@ StrafeRequest, int number, string instanceKey, float spread, float distance = 0.25, float yDelay = 0.5) {
    // Now we find the line perpendicular to caller-target

	//extracting data
	int characterId = StrafeRequest.m_characterId;
	Vector3 targetPos = StrafeRequest.m_targetPos;
	Vector3 direction = gunRunVector(StrafeRequest.m_direction);
	int factionId = StrafeRequest.m_factionId;
	
	//projectile speed has been calibrated for 40 horizontal, 40 vertical spawn offset
	Vector3 projectileSpeed = Vector3(-direction.get_opIndex(0), -1, -direction.get_opIndex(2));

    // Loop and spawn instances
    for (int i = 0; i < number; i++) {

      // This is used to scale the positions around the center
      int j = i - (number-1)/2;
      Vector3 newPos = targetPos.subtract(direction.scale(j * distance * (1 - yDelay) - 40));

      // Insert the new height
      // Also randomize the positions a tiny bit
      float randx = rand(-spread, spread);
      float randz = rand(-spread, spread);
      newPos.set(newPos.get_opIndex(0) + randx, newPos.get_opIndex(1) + 40.0 + j * 2 * yDelay, newPos.get_opIndex(2) + randz);

      // And finally, spawn the thing in!
      string c = 
		"<command class='create_instance'" +
        " faction_id='" + factionId + "'" +
        " instance_class='grenade'" +
        " instance_key='" + instanceKey + "'" +
        " position='" + newPos.toString() + "'" +
        " character_id='" + characterId + "'" +
        " offset='" + projectileSpeed.toString() + "' />";
      m_metagame.getComms().send(c);
    }
  }

  void gunRunLaunchHeightSweep(StrafeRequest@ StrafeRequest, string callKey) {
	if (callKey == "airstrike5.call") {
		gunRunLaunchHeightSeries(StrafeRequest, 66, "strafing_run_50cal.projectile", 2.0);
		gunRunLaunchHeightBatchSeries(StrafeRequest, 11, 2, false, "strafing_run.projectile", 2.0, 0.0);
	} else if (callKey == "airstrike6.call") {
		gunRunLaunchHeightSeries(StrafeRequest, 42, "strafing_run_50cal.projectile", 4.0);
		gunRunLaunchHeightSeries(StrafeRequest, 22, "strafing_run.projectile", 5.0);
	} else if (callKey == "airstrike7.call") {
		gunRunLaunchHeightSeries(StrafeRequest, 42, "strafing_run.projectile", 5.0);
	} else if (callKey == "airstrike8.call") {
		gunRunLaunchHeightSeries(StrafeRequest, 84, "strafing_run_mg.projectile", 4.0);
	} else if (callKey == "airstrike9.call") {
		gunRunLaunchHeightSeries(StrafeRequest, 42, "strafing_run_mg.projectile", 5.0);
		gunRunLaunchHeightSeries(StrafeRequest, 16, "strafing_run.projectile", 5.0);
	} else if (callKey == "airstrike10.call" || callKey == "airstrike11.call") {
		gunRunLaunchHeightBatchSeries(StrafeRequest, 21, 1, true, "strafing_run_50cal.projectile", 5.0, 5.0);
		gunRunLaunchHeightBatchSeries(StrafeRequest, 11, 4, false, "strafing_run.projectile", 5.0, 5.0);
	}
  }

  void gunRunLaunchHeightSeries(StrafeRequest@ StrafeRequest, int number, string instanceKey, float spread) {
	int characterId = StrafeRequest.m_characterId;
	Vector3 targetPos = StrafeRequest.m_targetPos;
	Vector3 direction = gunRunVector(StrafeRequest.m_direction);
	int factionId = StrafeRequest.m_factionId;
	Vector3 projectileSpeed = Vector3(-direction.get_opIndex(0), -1, -direction.get_opIndex(2));
	float heightStep = 30.303 / float(number - 1);
	float impactSpacing = 28.52016 / float(number - 1);

	for (int shot = 0; shot < number; shot++) {
		float j = float(shot) - float(number - 1) / 2.0;
		float launchHeight = 40.0 + j * heightStep;
		Vector3 basePos = targetPos.subtract(direction.scale(j * impactSpacing - launchHeight));
		basePos.m_values[1] += launchHeight;
		gunRunLaunchProjectileAt(StrafeRequest, basePos, projectileSpeed, factionId, characterId, instanceKey, spread);
	}
  }

  void gunRunLaunchHeightBatchSeries(StrafeRequest@ StrafeRequest, int positions, int batchSize, bool alternateOneTwo, string instanceKey, float instanceSpread, float commonSpread) {
	int characterId = StrafeRequest.m_characterId;
	Vector3 targetPos = StrafeRequest.m_targetPos;
	Vector3 direction = gunRunVector(StrafeRequest.m_direction);
	int factionId = StrafeRequest.m_factionId;
	Vector3 projectileSpeed = Vector3(-direction.get_opIndex(0), -1, -direction.get_opIndex(2));
	float heightStep = 30.303 / float(positions - 1);
	float impactSpacing = 28.52016 / float(positions - 1);

	for (int position = 0; position < positions; position++) {
		float j = float(position) - float(positions - 1) / 2.0;
		float launchHeight = 40.0 + j * heightStep;
		Vector3 basePos = targetPos.subtract(direction.scale(j * impactSpacing - launchHeight));
		basePos.m_values[1] += launchHeight;
		int count = batchSize;
		if (alternateOneTwo) {
			count = 1;
			if (position % 2 == 0) count = 2;
		}
		gunRunLaunchBatch(StrafeRequest, basePos, projectileSpeed, factionId, characterId, count, instanceKey, instanceSpread, commonSpread);
	}
  }

  void gunRunLaunchBatch(StrafeRequest@ StrafeRequest, Vector3 basePos, Vector3 projectileSpeed, int factionId, int characterId, int count, string instanceKey, float instanceSpread, float commonSpread) {
	Vector3 batchPos = Vector3(
		basePos.get_opIndex(0) + rand(-commonSpread, commonSpread),
		basePos.get_opIndex(1),
		basePos.get_opIndex(2) + rand(-commonSpread, commonSpread));
	for (int shot = 0; shot < count; shot++) {
		gunRunLaunchProjectileAt(StrafeRequest, batchPos, projectileSpeed, factionId, characterId, instanceKey, instanceSpread);
	}
  }

  void gunRunLaunchProjectileAt(StrafeRequest@ StrafeRequest, Vector3 basePos, Vector3 projectileSpeed, int factionId, int characterId, string instanceKey, float spread) {
	Vector3 newPos = Vector3(
		basePos.get_opIndex(0) + rand(-spread, spread),
		basePos.get_opIndex(1),
		basePos.get_opIndex(2) + rand(-spread, spread));

	string c =
		"<command class='create_instance'" +
		" faction_id='" + factionId + "'" +
		" instance_class='grenade'" +
		" instance_key='" + instanceKey + "'" +
		" position='" + newPos.toString() + "'" +
		" character_id='" + characterId + "'" +
		" offset='" + projectileSpeed.toString() + "' />";
	m_metagame.getComms().send(c);
  }

	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		//timer on/off
		return m_running;
	}
}
