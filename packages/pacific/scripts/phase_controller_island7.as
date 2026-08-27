#include "tracker.as"
#include "phase_controller.as"
#include "phase_controller_island1.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "instance_spawner.as"
#include "debug.as"

// --------------------------------------------
class DefPhase1_Island7 : DefPhase {
	// --------------------------------------------
	DefPhase1_Island7(GameModeInvasion@ metagame, PhaseController@ controller) {
		super(metagame, controller, 0.0f);
	}

	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase1 starting");
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "downfall phase 1"));

		_debugAnnounce(m_metagame, "DefPhase1_Island7::start");

		m_metagame.getComms().send("<command class='update_base' base_key='landing_zone_sun' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='landing_zone_sun1' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='mortar_pits' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='magazine' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='overlook' capturable='1' />");

		m_metagame.getComms().send("<command class='update_base' base_key='hill_330' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='field_hospital' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='suburb' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='barracks' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='ammo_dump' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='forest_clearing' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='telegraph_post' capturable='0' />");

		m_metagame.getComms().send("<command class='update_base' base_key='the_armory' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='the_heights' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='submarine_pens' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='warehouses' capturable='0' />");
	}
};

// --------------------------------------------
class DefPhase2_Island7 : DefPhase {
	// --------------------------------------------
	DefPhase2_Island7(GameModeInvasion@ metagame, PhaseController@ controller) {
		super(metagame, controller, 0.0f);
	}

	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase2 starting");
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "downfall phase 2"));
		_debugAnnounce(m_metagame, "DefPhase2_Island7::start");

		m_metagame.getComms().send("<command class='update_base' base_key='landing_zone_sun' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='landing_zone_sun1' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='mortar_pits' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='magazine' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='overlook' capturable='0' />");

		m_metagame.getComms().send("<command class='update_base' base_key='hill_330' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='field_hospital' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='suburb' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='barracks' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='ammo_dump' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='forest_clearing' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='telegraph_post' capturable='1' />");

		m_metagame.getComms().send("<command class='update_base' base_key='the_armory' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='the_heights' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='submarine_pens' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='warehouses' capturable='0' />");
	}
};

// --------------------------------------------
class DefPhase3_Island7 : DefPhase {
	protected array<InstanceSpawner@> m_spawners;

	// --------------------------------------------
	DefPhase3_Island7(GameModeInvasion@ metagame, PhaseController@ controller) {
		super(metagame, controller, 0.0f);

		bool enemyIsUsmc = m_metagame.getUserSettings().m_factionChoice == 1;

		{
			string vehicleKey = "m4_75.vehicle";						//these used to be Light Tanks but in 1.87 we're changing to Mediums
			string vehicleCallKey = "usf_vehicle_m4_sherman.call";
			if (!enemyIsUsmc) {
				vehicleKey = "chi_ha.vehicle";
				vehicleCallKey = "ija_vehicle_medium_tank_chi_ha.call";
			}
			m_spawners.push_back(VehicleViaCallSpawner(
				"tank_spawner", // just a descriptive name or id (keep it unique within m_spawners)
				m_metagame, vehicleKey, 
				2, // max instances in game simultaneously
				12, // number of resources
				1, // faction id
				120.0f, // time to respawn
				vehicleCallKey));
		}

		{
			string infantryCallKey = enemyIsUsmc ? "usmc_inf.call" : "ija_inf.call";
			m_spawners.push_back(InfantryViaCallSpawner(
				"infantry_spawner", // just a descriptive name
				m_metagame, infantryCallKey, 
				12, // number of resources 
				1, // faction id
				60.0f // time to respawn
				));
		}
	}

	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase3 starting");
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "downfall phase 3"));
		_debugAnnounce(m_metagame, "DefPhase3_Island7::start");

		m_metagame.getComms().send("<command class='update_base' base_key='landing_zone_sun' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='landing_zone_sun1' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='mortar_pits' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='magazine' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='overlook' capturable='0' />");

		m_metagame.getComms().send("<command class='update_base' base_key='hill_330' capturable='0 />");
		m_metagame.getComms().send("<command class='update_base' base_key='field_hospital' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='suburb' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='barracks' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='ammo_dump' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='forest_clearing' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' base_key='telegraph_post' capturable='0' />");

		m_metagame.getComms().send("<command class='update_base' base_key='the_armory' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='the_heights' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='submarine_pens' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='warehouses' capturable='1' />");

		for (uint i = 0; i < m_spawners.size(); ++i) {
			InstanceSpawner@ spawner = m_spawners[i];
			m_metagame.addTracker(spawner);
		}
	}

	// --------------------------------------------
	void update(float time) {
		for (uint i = 0; i < m_spawners.size(); ++i) {
			InstanceSpawner@ spawner = m_spawners[i];
			spawner.update(time);
		}
	}

	// --------------------------------------------
	protected void end() {
		DefPhase::end();

		for (uint i = 0; i < m_spawners.size(); ++i) {
			InstanceSpawner@ spawner = m_spawners[i];
			m_metagame.removeTracker(spawner);
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		XmlElement@ parent = root;
		XmlElement subroot("phase3");

		for (uint i = 0; i < m_spawners.size(); ++i) {
			InstanceSpawner@ spawner = m_spawners[i];
			spawner.save(subroot);
		}

		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		const XmlElement@ subroot = root.getFirstElementByTagName("phase3");
		if (subroot !is null) {
			for (uint i = 0; i < m_spawners.size(); ++i) {
				InstanceSpawner@ spawner = m_spawners[i];
				spawner.load(subroot);
			}
		} 
	}
};

// --------------------------------------------
class PhaseControllerIsland7 : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started = false;

	protected uint m_currentPhaseIndex = 0;

	protected array<Phase@> m_phases;

	// --------------------------------------------
	PhaseControllerIsland7(GameModeInvasion@ metagame) {
		@m_metagame = metagame;

		// reset here initially
		// - continue: reset -> load -> game_continue_pre_start
		// - start: reset -> reset -> start
		// - restart: reset -> reset -> start, reset -> start
		reset();
	}

	// --------------------------------------------
	void reset() {
		m_phases = array<Phase@>();
		
		m_phases.insertLast(DefPhase1_Island7(m_metagame, this));
		m_phases.insertLast(DefPhase2_Island7(m_metagame, this));
		m_phases.insertLast(DefPhase3_Island7(m_metagame, this));

		m_currentPhaseIndex = 0;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		_log("starting PhaseControllerIsland7 tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
		// on_game_continue_pre_start happens before start

		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;
		startCurrentPhase();

		// not feeling good about this, but it has happened that
		// saved phase index was 0 but in reality the phase 0
		// bases were already captured, so phases were stuck
		XmlElement dummy("event");
		handleBaseOwnerChangeEvent(dummy);
	}

	// --------------------------------------------
	void start() {
		// call reset here, phases and targets are initialized fresh
		// - helps with handling restart_map
		reset();

		_log("starting PhaseControllerIsland7 tracker, phase=" + m_currentPhaseIndex);

		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void phaseEnded() {
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
	protected void startOrContinuePhase(int index) {
		if (index != int(m_currentPhaseIndex)) {
			if (m_currentPhaseIndex >= 0) {
				Phase@ phase = m_phases[m_currentPhaseIndex];
				phase.end();
			}
			m_currentPhaseIndex = index;
			startCurrentPhase();
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
		XmlElement subroot("map_phase_controller_island7");

		subroot.setIntAttribute("phase_index", m_currentPhaseIndex);
		_log("PhaseControllerIsland7::save phase=" + m_currentPhaseIndex);

		if (m_currentPhaseIndex < m_phases.size()) {
			m_phases[m_currentPhaseIndex].save(subroot);
		}

		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		const XmlElement@ controllerElement = root.getFirstElementByTagName("map_phase_controller_island7");
		// map completion makes the stage use generic completed stage which gets saved, but at load
		// phase we are still loading the real stage.. verify the data is ok before processing it
		if (controllerElement !is null) {
			const XmlElement@ subroot = controllerElement;

			m_currentPhaseIndex = subroot.getIntAttribute("phase_index");
			if (m_currentPhaseIndex < m_phases.size()) {
				m_phases[m_currentPhaseIndex].load(subroot);
			}

			_log("PhaseControllerIsland7::load phase=" + m_currentPhaseIndex);
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

		/*
		if (checkCommand(message, "end_phase")) {
			Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.end();
		}
		*/
	}
	
	protected void announce(string text) {
		sendFactionMessage(m_metagame, 0, text, 1.0);
	}
	
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
        // base_id
        // owner_id (faction)
		array<const XmlElement@> baseList = getBases(m_metagame);		
		if (baseList.size() > 0) {
			bool ownsLandingZoneSun = false;    
			bool ownsMortarPit = false;
			bool ownsMagazine = false;
			bool ownsOverlook = false;
			bool ownsSuburb = false;
			bool ownsFieldHospital = false;
			bool ownsBarracks = false;
			bool ownsHill330 = false;
			bool ownsAmmoDump = false;
			bool ownsForestClearing = false;
			bool ownsTelegraphPost = false;
			
			//Needs to be set up for phases of assault
			//Phase 1: Capture the Coastal Defenses before moving inland.
			//Phase 2: Capture the outskirts and the hill before moving into the city.

			for (uint i = 0; i < baseList.size(); ++i)  {
				const XmlElement@ base = baseList[i];
				string currentBaseName = base.getStringAttribute("key");
				int currentBaseOwner = base.getIntAttribute("owner_id");
				_log("base name is " + currentBaseName + " owned by " + currentBaseOwner);
				if (currentBaseOwner == 0) {
					if (currentBaseName == "landing_zone_sun") ownsLandingZoneSun = true;
					if (currentBaseName == "mortar_pits") ownsMortarPit = true;
					if (currentBaseName == "magazine") ownsMagazine = true;
					if (currentBaseName == "overlook") ownsOverlook = true;
					if (currentBaseName == "suburb") ownsSuburb = true;
					if (currentBaseName == "field_hospital") ownsFieldHospital = true;
					if (currentBaseName == "barracks") ownsBarracks = true;
					if (currentBaseName == "hill_330") ownsHill330 = true;
					if (currentBaseName == "ammo_dump") ownsAmmoDump = true;
					if (currentBaseName == "forest_clearing") ownsForestClearing = true;
					if (currentBaseName == "telegraph_post") ownsTelegraphPost = true;
				}
			}

			if (ownsLandingZoneSun && ownsMortarPit && ownsMagazine && ownsOverlook) {
				if (ownsSuburb && ownsFieldHospital && ownsBarracks && ownsHill330 && ownsAmmoDump && ownsForestClearing && ownsTelegraphPost) {
					startOrContinuePhase(2);
				} else {
					startOrContinuePhase(1);
				}
			} else {
				startOrContinuePhase(0);
			}
		}
    }
}
