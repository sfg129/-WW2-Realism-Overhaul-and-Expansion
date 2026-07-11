#include "uncapturable_last_base_end_timer.as"

//Sicily version spawns in a Tiger Tank and Halftrack to help in the final attack

// --------------------------------------------
class UncapturableLastBaseEndTimerSicily : UncapturableLastBaseEndTimer {
	// --------------------------------------------
	UncapturableLastBaseEndTimerSicily(GameModeInvasion@ metagame, float time, float enemyCapacityOffset = 10) {     // was 20
		super(metagame, time, enemyCapacityOffset);
	}

	// ----------------------------------------------------
	protected void startWinTimer(int factionId) {
		bool wasTriggeredYet = m_triggered;
		UncapturableLastBaseEndTimer::startWinTimer(factionId);
		if (!wasTriggeredYet) {
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_tiger_hidden.call' position='169 4 358' faction_id='1' />");	
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='173 4 342' faction_id='1' />");	
			
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 15.0, 0, "sicily tiger spawn info 1"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "sicily tiger spawn info 2"));
		}
	}

	// ----------------------------------------------------
	protected void postStartWinTimer() {
		// no default comment
	}
	
	// --------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		if (m_triggered) {
			string key = event.getStringAttribute("vehicle_key");
			if (key == "tiger_sicily.vehicle") {
				m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "sicily tiger destroyed"));
			}
		}
	}
	
}
