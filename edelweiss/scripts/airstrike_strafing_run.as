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
	float m_shadowTimer = 2.0;
	bool m_shadowRun = false;
	
	StrafeRequest(int characterId, Vector3 targetPos, int direction, int callId, int factionId){
		m_characterId = characterId;
		m_targetPos = targetPos;
		m_direction = direction;
		m_callId = callId;
		m_factionId = factionId;
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
    if (event.getStringAttribute("call_key") == "airstrike2.call") {
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

			StrafeRequest@ thisCall = StrafeRequest(characterId, targetPos, direction, callId, factionId);
			
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
					StrafeQueue[i].m_shadowRun = true;
					
					//launching projectiles and removing the marker
					gunRunLaunchProjectiles(StrafeQueue[i], 40, "strafing_run.projectile", 4.0);
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
					
					//removing completed request
					StrafeQueue.removeAt(i);
					--i;
				}
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
		command.setIntAttribute("faction_id", 0);
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
