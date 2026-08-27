// internal
#include "tracker.as"

// --------------------------------------------
class RunAtInterval : Tracker {
	// --------------------------------------------
	protected Metagame@ m_metagame;
	protected float m_timer;
	protected float m_interval;
	protected bool m_started;
	protected bool m_ended;
	protected XmlElement@ m_command;
	
	// ----------------------------------------------------
	RunAtInterval(Metagame@ metagame, const XmlElement@ command, float interval) {
		@m_metagame = @metagame;
		m_interval = interval;
		m_timer = m_interval;
		m_started = false;
		m_ended = false;

		@m_command = XmlElement(command.toDictionary()); // copy
	}

	// ----------------------------------------------------
	void start() {
		m_started = true;
		m_ended = false;
		m_timer = m_interval;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return m_ended;
	}

	// ----------------------------------------------------
	void onRemove() {
		m_started = false;
		m_ended = false;
	}

	// ----------------------------------------------------
	void gameContinuePreStart() {
		// check if game over already
		const XmlElement@ general = getGeneralInfo(m_metagame);
		if (general !is null) {
			bool matchOver = general.getIntAttribute("match_over") == 1;
			if (matchOver) {
				m_started = true;
				m_ended = true;
			}
		}
	}
	
	// ----------------------------------------------------
	protected void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			doit();
			m_timer = m_interval;
		}
	}

	// ----------------------------------------------------
	protected void doit() {
		m_metagame.getComms().send(m_command);
	}
	
	// ----------------------------------------------------
	protected void handleMatchEndEvent(const XmlElement@ event) {
		m_ended = true;
	}	
}
