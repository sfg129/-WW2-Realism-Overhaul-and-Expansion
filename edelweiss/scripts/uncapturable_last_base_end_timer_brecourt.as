#include "uncapturable_last_base_end_timer.as"

//Brecourt version spawns in two Panzers and some transports / halftracks to help in the final attack

// --------------------------------------------
class UncapturableLastBaseEndTimerBrecourt : UncapturableLastBaseEndTimer {
	// --------------------------------------------
	UncapturableLastBaseEndTimerBrecourt(GameModeInvasion@ metagame, float time, float enemyCapacityOffset = 20) {
		super(metagame, time, enemyCapacityOffset);
	}

	// ----------------------------------------------------
	protected void startWinTimer(int factionId) {
		bool wasTriggeredYet = m_triggered;
		UncapturableLastBaseEndTimer::startWinTimer(factionId);
		if (!wasTriggeredYet) {
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_panzer_hidden.call' position='725 4 782' faction_id='1' />");
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_panzer_hidden.call' position='725 4 782' faction_id='1' />");
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='716 4 758' faction_id='1' />");
		}
	}
}
