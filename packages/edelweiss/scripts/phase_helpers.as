#include "tracker.as"

// --------------------------------------------
void spawn(Metagame@ metagame, uint count, uint factionId, Vector3 position, string instanceKey) {
	for (uint i = 0; i < count; ++i) {
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position.toString() + "' " + 
		" offset='0 0 0' " +
		" instance_class='soldier' " + 
		" instance_key='" + instanceKey + "'> " + 
		"</command>");
	}
}

// --------------------------------------------
void spawn(Metagame@ metagame, uint count, uint factionId, Vector3 position1, Vector3 position2, string instanceKey) {
	spawn(metagame, count, factionId, position1, instanceKey);
	spawn(metagame, count, factionId, position2, instanceKey);
}

// --------------------------------------------
class Phase : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected PhaseController@ m_controller;
	protected bool m_started;
	protected bool m_ended;

	protected bool m_loadingFromSave;

	// --------------------------------------------
	Phase(GameModeInvasion@ metagame, PhaseController@ controller) {
		@m_metagame = @metagame;
		@m_controller = @controller;
		m_started = false;
		m_ended = false;
		m_loadingFromSave = false;
	}

	// --------------------------------------------
	void start() {
		m_started = true;
	}

	// --------------------------------------------
	void end() {
		Tracker::end();
		m_controller.phaseEnded();
		m_ended = true; // metagame will check has_ended, and will remove the phase from processing if it has ended
	}

	// --------------------------------------------
	void onRemove() {
		m_started = false;
		m_loadingFromSave = false;
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_ended;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		m_loadingFromSave = true;
	}
};

// --------------------------------------------
class DefPhaseBase : Phase {
	protected float m_enemySpawnCompensationFactor;
	// --------------------------------------------
	DefPhaseBase(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller);
		m_enemySpawnCompensationFactor = enemySpawnCompensationFactor;
	}

	// --------------------------------------------
	protected uint getCompensatedEnemyCount(uint count) {
		int playerCount = getPlayerCount(m_metagame);
		count = max(1, int((count + m_enemySpawnCompensationFactor * max(0, playerCount - 1)) * m_metagame.getUserSettings().m_enemyCapacityFactor)); // --not compensated
		return count;
	}
	
	// --------------------------------------------
	protected uint getCompensatedEnemyCount_less(uint count) {
		int playerCount = getPlayerCount(m_metagame);
		count = max(1, int((count + (m_enemySpawnCompensationFactor/4) * max(0, playerCount - 1)) * m_metagame.getUserSettings().m_enemyCapacityFactor));	// --should yield an eigth as many of the addition factor. So with Max Server, you get +6 men rather than +23.
		return count;
	}
	
	// --------------------------------------------
	protected void spawn(uint count, uint factionId, Vector3 position, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount(count), factionId, position, instanceKey);
	}

	// --------------------------------------------
	protected void spawn(uint count, uint factionId, Vector3 position1, Vector3 position2, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount(count), factionId, position1, position2, instanceKey);
	}
	
	// -------------------------------------------- previous two spawns are defined twice because one is for when only given 1 position; other spawns at 2 positions. below spawns at 2 only.
	protected void spawn_less_compensation(uint count, uint factionId, Vector3 position, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount_less(count), factionId, position, instanceKey);
	}

	protected void spawn_less_compensation(uint count, uint factionId, Vector3 position1, Vector3 position2, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount_less(count), factionId, position1, position2, instanceKey);
	}

    // ----------------------------------------------------
    protected void announce(string text) {
		sendFactionMessage(m_metagame, 0, text, 1.0);
    }
}
