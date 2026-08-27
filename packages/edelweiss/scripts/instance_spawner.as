#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "debug.as"

// --------------------------------------------
// base class, derive and implement
class InstanceSpawner : Tracker {
	protected string m_name;
	protected Metagame@ m_metagame;
	protected int m_factionId;
	protected float m_respawnTimer;
	protected float m_respawnTime;
	protected int m_spawnsLeft;
	protected bool m_started;

	// --------------------------------------------
	InstanceSpawner(string name, Metagame@ metagame, int maxSpawns, int factionId, float respawnTime) {
		super();
		m_name = name;
		@m_metagame = @metagame;
		m_spawnsLeft = maxSpawns;
		m_factionId = factionId;
		m_respawnTimer = -1.0f;
		m_respawnTime = respawnTime;
		m_started = false;
	}

	// --------------------------------------------
	void start() {
		_debugAnnounce(m_metagame, m_name + ", start");
		_log("InstanceSpawner, start, name=" + m_name);
		m_started = true;
		checkForRespawn();

		if (m_respawnTimer > 0.0f) {
			// truncate respawn timer at start to insta-spawn
			m_respawnTimer = 0.5f;
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
	protected void checkForRespawn() {
		if (m_spawnsLeft > 0 && m_respawnTimer < 0.0f) {
			_debugAnnounce(m_metagame, m_name + ", checkForRespawn, m_spawnsLeft=" + m_spawnsLeft);
			startRespawn();
		} else {
			_debugAnnounce(m_metagame, m_name + ", checkForRespawn, m_spawnsLeft=" + m_spawnsLeft + ", m_respawnTimer=" + m_respawnTimer + ", can't start");
		}
	}

	// --------------------------------------------
	protected void startRespawn() {
		if (m_respawnTimer < 0.0f) {
			_log("InstanceSpawner, respawn timer started");
			m_respawnTimer = m_respawnTime;
			_debugAnnounce(m_metagame, m_name + ", startRespawn, timer=" + m_respawnTimer);
		} else {
			_debugAnnounce(m_metagame, m_name + ", startRespawn, respawn timer already running");
		}
	}

	// --------------------------------------------
	protected void spawn() {
		m_spawnsLeft -= 1;
		_log("InstanceSpawner, spawn, then " + m_spawnsLeft + " left");
		_debugAnnounce(m_metagame, m_name + ", spawn, then " + m_spawnsLeft + " left");
	}

	// --------------------------------------------
	void update(float time) {
		if (m_spawnsLeft > 0) {
			if (m_respawnTimer >= 0.0f) {
				//_log("InstanceSpawner, update, name=" + m_name + ", respawnTimer=" + m_respawnTimer, 1);
				m_respawnTimer -= time;
				if (m_respawnTimer < 0.0f) {
					_debugAnnounce(m_metagame, m_name + ", update, respawn timer expired");
					spawn();
					checkForRespawn();
				}
			}
		}
	}

	// --------------------------------------------
	protected array<const XmlElement@> getOwnBases() {
		array<const XmlElement@> result;
		array<const XmlElement@> baseList = getBases(m_metagame);
		// go through list of bases
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getIntAttribute("owner_id") == m_factionId) {
				result.push_back(base);
			}
		}
		return result;
	}

	// --------------------------------------------
	protected Vector3 getTargetPosition() {
		Vector3 position(512,0,512);
		array<const XmlElement@> bases = getOwnBases();
		if (bases.size() > 0) {
			// get random base center position
			int i = rand(0, bases.size() - 1);
			position = stringToVector3(bases[i].getStringAttribute("position"));
		}
		return position;
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		XmlElement@ parent = root;
		XmlElement subroot("instance_spawner");
		saveImpl(subroot);
		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		array<const XmlElement@> list = root.getElementsByTagName("instance_spawner");
		if (list !is null) {
			for (uint i = 0; i < list.size(); ++i) {
				const XmlElement@ e = list[i];
				if (e.getStringAttribute("name") == m_name) {
					loadImpl(e);
					m_started = true; // skip start
					break;
				}
			}
		}
	}

	// --------------------------------------------
	protected void saveImpl(XmlElement@ e) {
		e.setStringAttribute("name", m_name);
		e.setIntAttribute("spawns_left", m_spawnsLeft);
		e.setFloatAttribute("respawn_timer", m_respawnTimer);
	}

	// --------------------------------------------
	protected void loadImpl(const XmlElement@ e) {
		m_spawnsLeft = e.getIntAttribute("spawns_left");
		m_respawnTimer = e.getFloatAttribute("respawn_timer");
		_log("InstanceSpawner, loadImpl, name=" + m_name + ", spawnsLeft=" + m_spawnsLeft + ", respawnTimer=" + m_respawnTimer);
	}
}

// --------------------------------------------
// base class for vehicle, derive and implement
class CountedVehicleSpawner : InstanceSpawner {
	protected string m_key;
	protected int m_maxInGame;
	protected int m_aliveOffset; // a trick to count in a spawn made happen right on the same update cycle

	// --------------------------------------------
	CountedVehicleSpawner(string name, Metagame@ metagame, string key, int maxInGame, int maxSpawns, int factionId, float respawnTime) {
		super(name, metagame, maxSpawns, factionId, respawnTime);
		m_key = key;
		m_maxInGame = maxInGame;
		m_aliveOffset = 0;
	}

	// --------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		// hmm, we probably should track spawn ids?
		if (key == m_key) {
			_log("CountedVehicleSpawner, name=" + m_name + ", handleVehicleDestroyEvent");
			_debugAnnounce(m_metagame, m_name + ", handleVehicleDestroyEvent, key=" + key);
			checkForRespawn();
		}
	}

	// --------------------------------------------
	protected void spawn() {
		InstanceSpawner::spawn();
		m_aliveOffset = 1;
	}

	// --------------------------------------------
	protected void checkForRespawn() {
		if (m_spawnsLeft >= 0) {
			array<const XmlElement@>@ vehicles = getVehicles(m_metagame, m_factionId, m_key);
			int alive = m_aliveOffset;
			for (uint i = 0; i < vehicles.size(); ++i) {
				const XmlElement@ vehicle = getVehicleInfo(m_metagame, vehicles[i].getIntAttribute("id"));
				float health = vehicle.getFloatAttribute("health");
				if (health > 0.0f) {
					alive++;
				}
			}
			if (alive < m_maxInGame) {
				_debugAnnounce(m_metagame, m_name + ", checkForRespawn, alive=" + alive + " maxInGame=" + m_maxInGame + ", ok");
				startRespawn();
			} else {
				_debugAnnounce(m_metagame, m_name + ", checkForRespawn, alive=" + alive + " maxInGame=" + m_maxInGame + ", not ok to start");
			}
		} else {
			_debugAnnounce(m_metagame, m_name + ", checkForRespawn, no more spawns left");
		}

		// reset alive offset
		m_aliveOffset = 0;
	}
}

// --------------------------------------------
// vehicle spawning via a suitable call
class VehicleViaCallSpawner : CountedVehicleSpawner {
	protected string m_callKey;

	// --------------------------------------------
	VehicleViaCallSpawner(string name, Metagame@ metagame, string key, int maxInGame, int maxSpawns, int factionId, float respawnTime, string callKey) {
		super(name, metagame, key, maxInGame, maxSpawns, factionId, respawnTime);
		m_callKey = callKey;
	}

	// --------------------------------------------
	protected void spawn() {
		CountedVehicleSpawner::spawn();
		XmlElement command("command");
		command.setStringAttribute("class", "create_call");
		command.setStringAttribute("key", m_callKey);
		command.setStringAttribute("position", getTargetPosition().toString());
		command.setIntAttribute("faction_id", m_factionId);
		m_metagame.getComms().send(command);
	}
}

// --------------------------------------------
// infantry spawning via a suitable call
class InfantryViaCallSpawner : InstanceSpawner {
	protected string m_callKey;

	// --------------------------------------------
	InfantryViaCallSpawner(string name, Metagame@ metagame, string callKey, int maxSpawns, int factionId, float respawnTime) {
		super(name, metagame, maxSpawns, factionId, respawnTime);
		m_callKey = callKey;
	}

	// --------------------------------------------
	protected void spawn() {
		InstanceSpawner::spawn();

		XmlElement command("command");
		command.setStringAttribute("class", "create_call");
		command.setStringAttribute("key", m_callKey);
		command.setStringAttribute("position", getTargetPosition().toString());
		command.setIntAttribute("faction_id", m_factionId);
		m_metagame.getComms().send(command);
	}
}

