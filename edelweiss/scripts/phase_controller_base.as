#include "phase_controller.as"

// --------------------------------------------
abstract class PhaseControllerBase : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected string m_name;
	protected float m_enemySpawnCompensationFactor;
	protected bool m_started = false;

	protected uint m_currentPhaseIndex = 0;

	protected array<Phase@> m_phases;

	// --------------------------------------------
	PhaseControllerBase(GameModeInvasion@ metagame, string name, float enemySpawnCompensationFactor) {
		@m_metagame = metagame;
		
		m_name = name;

		m_enemySpawnCompensationFactor = enemySpawnCompensationFactor;

		// reset here initially
		// - continue: reset -> load -> game_continue_pre_start
		// - start: reset -> reset -> start
		// - restart: reset -> reset -> start, reset -> start
		reset();
	}

	// --------------------------------------------
	void reset() {
		m_phases = array<Phase@>();
		
		// TODO: override this method in specialized clas and insert phases 
		//m_phases.insertLast(DefPhase0(m_metagame, this, m_enemySpawnCompensationFactor));	//commander chat & setup
		
		m_currentPhaseIndex = 0;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		_log("starting PhaseControllerBase (" + m_name + ") tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
		// on_game_continue_pre_start happens before start

		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

	// --------------------------------------------
	void start() {
		// call reset here, phases and targets are initialized fresh
		// - helps with handling restart_map
		reset();

		_log("starting PhaseControllerBase (" + m_name + ") tracker, phase=" + m_currentPhaseIndex);

		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void phaseEnded() {
		// advance to next phase
		m_currentPhaseIndex += 1;
		if (m_currentPhaseIndex < m_phases.size()) {
			startCurrentPhase();
		} else {
			// finished, no more phases left
			completeMatch();
		}
	}

	// --------------------------------------------
	protected void completeMatch() {
		m_metagame.getComms().send("<command class='set_match_status' faction_id='1' lose='1' />");
		m_metagame.getComms().send("<command class='set_match_status' faction_id='0' win='1' />");
	}

	// --------------------------------------------
	void startCurrentPhase() {
		if (m_currentPhaseIndex < m_phases.size()) {
			Phase@ phase = m_phases[m_currentPhaseIndex];

			m_metagame.addTracker(phase);
		}
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
	protected void handleFactionLoseEvent(const XmlElement@ event) {
		// if lost a battle, start over
		int factionId = -1;

		const XmlElement@ loseCondition = event.getFirstElementByTagName("lose_condition");
		if (loseCondition !is null) {
			factionId = loseCondition.getIntAttribute("faction_id");
		}

		if (factionId == 0) {
			// friendly faction lost
			// - mark this tracker not started so that it will be added again when map restarts
			m_metagame.removeTracker(this);
			m_started = false;
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		// store which phase we've reached
		// and let phase store additional stuff
		XmlElement@ parent = root;
		XmlElement subroot("map_phase_controller_" + m_name);

		subroot.setIntAttribute("phase_index", m_currentPhaseIndex);

		if (m_currentPhaseIndex < m_phases.size()) {
			m_phases[m_currentPhaseIndex].save(subroot);
		}

		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		const XmlElement@ controllerElement = root.getFirstElementByTagName("map_phase_controller_" + m_name);
		// map completion makes the stage use generic completed stage which gets saved, but at load
		// phase we are still loading the real stage.. verify the data is ok before processing it
		if (controllerElement !is null) {
			const XmlElement@ subroot = controllerElement;

			m_currentPhaseIndex = subroot.getIntAttribute("phase_index");
			if (m_currentPhaseIndex < m_phases.size()) {
				m_phases[m_currentPhaseIndex].load(subroot);
			}
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
		}
	}
}
