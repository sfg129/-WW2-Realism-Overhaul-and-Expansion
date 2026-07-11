#include "tracker.as"
#include "phase_controller.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "resource_helpers.as"
#include "helpers2.as"
#include "phase_helpers.as"

class AlliesOverlordPhase_Land : DefPhaseBase {
	// --------------------------------------------
	AlliesOverlordPhase_Land(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	private string m_vehicleKey = "quest_overlord.vehicle";

	// --------------------------------------------
	void start() {
		DefPhaseBase::start();
		_log("AlliesOverlordPhase Landing starting");

		if (_logger.m_logLevel >= 1) {
			announce("TEST: AlliesOverlordPhase 1 starting");
		}
      
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}		
	}

	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (key == m_vehicleKey) {
			//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 2.0, 0, "Overlord Allies, vehicle destoryed"));
			//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 1.0, 0, "Overlord Allies, call unlocked"));
		}
	}
	
	protected void refresh() {
        // query about bases
		array<const XmlElement@> baseList = getBases(m_metagame);

		int winner = -1;
		bool pause = false;
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getBoolAttribute("capturable")) {
				// assuming one capturable here
				winner = base.getIntAttribute("owner_id");
				if (winner!=0){
					pause = true;
					break;
				}
			}
		}

		// pause if someone else holds the capturable base than faction 0
		m_metagame.getComms().send("<command class='set_game_timer' pause='" + (pause?1:0) + "' />");
	}

    protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		refresh();
    }

};

// --------------------------------------------
class PhaseControllerOverlord_Allies : PhaseControllerBase {
	// --------------------------------------------
	PhaseControllerOverlord_Allies(GameModeInvasion@ metagame, float enemySpawnCompensationFactor) {
		super(metagame, "Overlord", enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void reset() {
		PhaseControllerBase::reset();
		m_phases.insertLast(AlliesOverlordPhase_Land(m_metagame, this, m_enemySpawnCompensationFactor));			
	}
}
