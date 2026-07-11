// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "resource.as"

// NOTE, this only works ok for 2-faction matches

// requires defense_win_time_mode="custom" to be set in the match,
// also set a positive defense_win_time in match, any number is fine

// --------------------------------------------
class UncapturableLastBaseEndTimer : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected float m_time;
	protected int m_winningFactionId;
	protected float m_enemyCapacityOffset;
	protected bool m_triggered;

	// --------------------------------------------
	UncapturableLastBaseEndTimer(GameModeInvasion@ metagame, float time, float enemyCapacityOffset = 10) {
		@m_metagame = @metagame;
		m_time = time;
		m_winningFactionId = -1;
		m_enemyCapacityOffset = enemyCapacityOffset;
		m_triggered = false;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// ----------------------------------------------------
	void gameContinuePreStart() {
		const XmlElement@ info = getGeneralInfo(m_metagame);
		if (info !is null) {
			// restore last winning faction id from game general info if already running
			// ParatrooperMode uses the same timer and sets match_winner when faction 0 has no bases,
			// using that fact here to workaround potential issues
			if (getBasesForFaction(m_metagame, 0) > 0) {
				int winner = info.getIntAttribute("match_winner");
				// if winner has been set, we know we've already triggered the timer once
				if (winner >= 0) {
					m_triggered = true;
				}
				// however, if the timer is on pause, consider winning faction -1
				// to stay in sync with start/cancel timer commands properly
				bool paused = info.getBoolAttribute("match_win_timer_paused");
				m_winningFactionId = !paused ? winner : -1;
			}
		}
	}

	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		_log("UncapturableLastBaseEndTimer, base ownership changed", 1);

		// check if a faction owns only one base and that it is uncapturable
		// if so, run timer for their defeat
		for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
			int factionId = i;
			int bases = 0;
			int uncapturableBases = 0;
			array<const XmlElement@> baseList = getBases(m_metagame);
			for (uint j = 0; j < baseList.size(); ++j) {
				const XmlElement@ base = baseList[j];
				if (base.getIntAttribute("owner_id") == factionId) {
					bases++;
					if (!base.getBoolAttribute("capturable")) {
						uncapturableBases++;
					}
				}
			}
			if (bases >= 1 && bases == uncapturableBases) {
				// this faction can lose now
				// NOTE, this only works ok for 2-faction cases
				int winning = factionId == 0 ? 1 : 0;
				if (winning != m_winningFactionId) {
					startWinTimer(winning);
				}
			} else if (bases > 1) {
				// if the faction has more than one base, and the win timer is
				// running (and it's not running for this faction), cancel it
				if (m_winningFactionId >= 0 && m_winningFactionId != factionId) {
					cancelWinTimer();
				}
			}
		}
	}

	// ----------------------------------------------------
	protected void destroyVehicles(uint factionId, string key) {
		array<const XmlElement@>@ vehicles = getVehicles(m_metagame, factionId, key);
		for (uint i = 0; i < vehicles.size(); ++i) {
			const XmlElement@ vehicle = vehicles[i];
			destroyVehicle(m_metagame, vehicle.getIntAttribute("id"));
		}
	}

	// ----------------------------------------------------
	protected void startWinTimer(int factionId) {
		_log("UncapturableLastBaseEndTimer, startWinTimer for " + factionId, 1); 

		{
			XmlElement command("command");
			command.setStringAttribute("class", "set_game_timer");
			command.setIntAttribute("faction_id", factionId);
			command.setIntAttribute("pause", 0);
			if (!m_triggered) {
				command.setFloatAttribute("time", m_time);
			} else {
				// already triggered, keep old time
				
				// it is actually possible for the enemy to push all the way back capturing all bases
				// and with paratrooper mode triggering the win timer for enemy to begin,
				// and if we were to recapture all capturable bases again after that
				// we'd be here with friendly win timer having been triggered but it can't
				// be just continued as old time has been changed by the enemy win timer
				
				const XmlElement@ general = getGeneralInfo(m_metagame);
				int timerWinner = general.getIntAttribute("match_winner");
				if (timerWinner != 0) {
					// if friendly is still winning in timer in game, continue, otherwise restart
					command.setFloatAttribute("time", m_time);
				}
				
				
			}
			m_metagame.getComms().send(command);
		}

		m_triggered = true;

		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.8' border_defense='0.2' />"); 
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0' border_defense='0' />");
		m_metagame.getComms().send("<command class='set_comms' faction_id='1' enabled='1' />"); 

		//for (uint i = 1; i < m_metagame.getFactionCount(); ++i) {
		//	destroyVehicles(i, "coastal_gun.vehicle");
		//	destroyVehicles(i, "coastal_gun2.vehicle");
		//	destroyVehicles(i, "coastal_gun3.vehicle");
		//	destroyVehicles(i, "radio_jammer.vehicle");
		//	destroyVehicles(i, "aa_gun.vehicle");
		//	destroyVehicles(i, "aa_gun2.vehicle");
		//}

		// NOTE, this only affects default group (player-only group in Pacific) if soldier_group_name is left unspecified
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1'>" + " <parameter class='willingness_to_charge' value='0.6' />" +    "</command>");        
		// consider something like this instead, and mind that the value needs to reverted if timer is canceled
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1' soldier_group_name='regular'><parameter class='willingness_to_charge' value='0.7' /></command>");
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1' soldier_group_name='veteran'><parameter class='willingness_to_charge' value='0.7' /></command>");
		// etc.. not sure if IJA and USMC names are same, would need to be if hardcoded here, 
		// or the script needs to be extended to set soldier group names externally
		// in order to control it from faction specific stage configurators

		// also this to avoid vehicles if wanted
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1' soldier_group_name='regular'><parameter class='uses_vehicles' value='0' /></command>");

		{
				XmlElement command("command");
				command.setStringAttribute("class", "change_game_settings");
				
				XmlElement f1("faction");	//don't change player faction
				command.appendChild(f1);

				XmlElement f2("faction");
				const array<Faction@>@ factions = m_metagame.getFactions();
				float totalCapacityOffset = factions[1].m_capacityOffset + m_enemyCapacityOffset;
				f2.setFloatAttribute("capacity_offset", totalCapacityOffset);
				command.appendChild(f2);

				m_metagame.getComms().send(command);
		}
		
		m_winningFactionId = factionId;
		
		postStartWinTimer();
	}

	// ----------------------------------------------------
	protected void postStartWinTimer() {
		sendFactionMessageKey(m_metagame, 0, "uncapturable_last_base_end_timer, start", dictionary = {}, 1.0);
	}

	// ----------------------------------------------------
	protected void cancelWinTimer() {
		_log("UncapturableLastBaseEndTimer, cancelWinTimer", 1); 

		{
		XmlElement command("command");
		command.setStringAttribute("class", "set_game_timer");
			// don't clear winner data, otherwise load to save which
			// has started the time at some point but then has been
			// canceled and winner data has been cleared will
			// cause m_triggered to be assumed false, and
			// timer will reset when timer situation is again reached
			//
			// outcome is that timer will show paused, but that's ok?
			//command.setIntAttribute("faction_id", -1);

			// don't reset timer
		//command.setFloatAttribute("time", -1.0f);
			
		command.setIntAttribute("pause", 1);
		m_metagame.getComms().send(command);
		}

		const array<Faction@>@ factions = m_metagame.getFactions();
		m_metagame.getComms().send(factions[0].m_defaultCommanderAiCommand);
		m_metagame.getComms().send(factions[1].m_defaultCommanderAiCommand);

		// cancel ai parameter manipulation
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1'>" + " <parameter class='willingness_to_charge' value='0.0' />" +    "</command>");     
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1' soldier_group_name='regular'><parameter class='willingness_to_charge' value='0.0' /></command>");
		//m_metagame.getComms().send("<command class='soldier_ai' faction='1' soldier_group_name='regular'><parameter class='uses_vehicles' value='1' /></command>");
		// NOTE, there's no existing way to query ai parameters on the script side so the values need to be hardcoded here basically, 
		// watch out for issues if the original value changes

		{
				XmlElement command("command");
				command.setStringAttribute("class", "change_game_settings");
				
				XmlElement f1("faction");	//don't change player faction
				command.appendChild(f1);

				XmlElement f2("faction");
				f2.setFloatAttribute("capacity_offset", factions[1].m_capacityOffset);
				command.appendChild(f2);

				m_metagame.getComms().send(command);
		}

		m_winningFactionId = -1;

		postCancelWinTimer();
	}

	// ----------------------------------------------------
	protected void postCancelWinTimer() {
		sendFactionMessageKey(m_metagame, 0, "uncapturable_last_base_end_timer, cancel", dictionary = {}, 1.0);
	}
		
	// ----------------------------------------------------
	protected void handleMatchEndEvent() {
		m_winningFactionId = -1;
	}
	
	
}
