// TODO:
// - test
// --- when player captures all bases, match should end in victory
// --- how does the beginning behave in online?
// - test load/save
// --- load in losing state
// --- load after losing state

// consider if needed
// - friendly bot spawning when baseless
// ----- capacity handling with offset doesn't reach high enough spawn amounts?
// - player spawn at start
// --- enable setting up position where to spawn as dead to not reveal any enemy positions

// internal
#include "metagame.as"
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class ParatrooperMode : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;
	protected float m_friendlyBaselessCapacityOffset;

	// --------------------------------------------
	ParatrooperMode(GameModeInvasion@ metagame, float friendlyBaselessCapacityOffset) {
		@m_metagame = @metagame;
		m_started = false;
		m_friendlyBaselessCapacityOffset = friendlyBaselessCapacityOffset;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		// on_game_continue_pre_start happens before start
		// to skip processing start function which contains all the logic, we set the tracker started at this point already,
		// the metagame won't then call start at all
		m_started = true;
	}
	
	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// --------------------------------------------
	void start() {
		_log("ParatrooperMode, start");
		m_started = true;

		startLosingState();
		
		// TODO: not sure how this works with load/save -- is start run after load?
	}

	// ----------------------------------------------------
	void onRemove() {
		m_started = false;
	}
	
	// --------------------------------------------
	protected void startLosingState() {
		_log("ParatrooperMode, startLosingState");
		startLoseTimer();
		setFriendliesToFullAttack();
	}

	// --------------------------------------------
	protected void endLosingState() {
		_log("ParatrooperMode, endLosingState");
		cancelLoseTimer();
		setFriendliesToNormal();
	}
	
	// --------------------------------------------
	protected void startLoseTimer() {
		_log("ParatrooperMode, startLoseTimer");
		// start end timer
		XmlElement command("command");
		command.setStringAttribute("class", "set_game_timer");
		// begin with enemy about to win
		command.setIntAttribute("faction_id", 1); 
		command.setIntAttribute("pause", 0); 
		command.setFloatAttribute("time", 360.0f); 
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	protected void cancelLoseTimer() {
		_log("ParatrooperMode, cancelLoseTimer");
		// cancel timer
		// - the timer doesn't show on screen when we have 0 or less as time 
		// - we might be able to skip match end by time by setting the timer to negative here and pausing it?
		XmlElement command("command");
		command.setStringAttribute("class", "set_game_timer");
		command.setIntAttribute("pause", 1); 
		command.setFloatAttribute("time", -1.0f); 
		command.setIntAttribute("faction_id", -1); 
		m_metagame.getComms().send(command);
	}
	
    // ----------------------------------------------------
	protected int getBasesForFaction(int factionId) {
		array<const XmlElement@> baseList = getBases(m_metagame);
		int bases = 0;
		// go through list of bases
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getIntAttribute("owner_id") == factionId) {
				bases++;
			}
		}
		return bases;
	}
	
	// --------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		int oldOwner = event.getIntAttribute("previous_owner_id");		
		int owner = event.getIntAttribute("owner_id");		
		_log("ParatrooperMode, handleBaseOwnerChangeEvent, previous_owner_id=" + oldOwner + ", owner=" + owner);
		if (owner == 0) {
			// if friendlies capture the first base, cancel timer
			if (getBasesForFaction(0) >= 1) {
			
				// now that we aren't checking just for one base but many
				// (it's is actually possible to capture several bases at the same time (within a script cycle))
				// make an additional check to only cancel the timer if the enemy is about to win
				const XmlElement@ general = getGeneralInfo(m_metagame);
				int timerWinner = general.getIntAttribute("match_winner");
				if (timerWinner == 1) {
					endLosingState();
				}
				
			}
		} else {
			// if friendlies no longer have any base left, restart timer
			if (getBasesForFaction(0) == 0) {
				startLosingState();
			}
		}
	}

// --------------------------------------------
    void setFriendliesToFullAttack() {
        _log("ParatrooperMode, setFriendliesToFullAttack");
		{
        XmlElement command("command");
        command.setStringAttribute("class", "commander_ai");
        command.setIntAttribute("faction", 0);
        command.setFloatAttribute("base_defense", 0.0);
        command.setFloatAttribute("border_defense", 0.0);
        m_metagame.getComms().send(command);
		}

        {
            XmlElement command("command");
            command.setStringAttribute("class", "change_game_settings");
            for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
                Faction@ f = m_metagame.getFactions()[i];
                XmlElement faction("faction");
                float capacityOffset = f.m_capacityOffset;
                if (i == 0) {
                    // supply customized friendly baseless capacity offset
                    capacityOffset = m_friendlyBaselessCapacityOffset * m_metagame.getUserSettings().m_fellowCapacityFactor;
                }
                faction.setFloatAttribute("capacity_offset", capacityOffset);
                if (i == 0) {
                    faction.setFloatAttribute("spawn_interval", 0.5);
                }
                command.appendChild(faction);
            }
            m_metagame.getComms().send(command);
        }
    }

	// --------------------------------------------
	void setFriendliesToNormal() {
		_log("ParatrooperMode, setFriendliesToNormal");
		{
		const array<Faction@>@ factions = m_metagame.getFactions();
		const XmlElement@ command = factions[0].m_defaultCommanderAiCommand;
		m_metagame.getComms().send(command);
		}
		
		{
			XmlElement command("command");
			command.setStringAttribute("class", "change_game_settings");
			for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
				Faction@ f = m_metagame.getFactions()[i];
				XmlElement faction("faction");
				// use default offset values for all factions 
				faction.setFloatAttribute("capacity_offset", f.m_capacityOffset);
                if (i == 0) {
                    faction.setFloatAttribute("spawn_interval", 3.0);
                }
				command.appendChild(faction);
			}
			m_metagame.getComms().send(command);
		}
	}
}

