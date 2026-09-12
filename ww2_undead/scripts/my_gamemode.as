#include "hawkins_grenade_test.as"
#include "gamemode_campaign.as"
#include "my_stage_configurator_allies.as"
//#include "my_stage_configurator_axis.as"
#include "my_map_rotator.as"
#include "my_server_map_rotator.as"
//#include "my_item_delivery_configurator_westfront_axis.as"
//#include "my_item_delivery_configurator_westfront_ukf.as"
#include "my_item_delivery_configurator_westfront_usf.as"
#include "my_vehicle_delivery_configurator.as"
#include "music_tracker_edel.as"
#include "multitarget_resource_controller.as"
#include "call_sorting.as"
#include "spawn_in_base_call_handler.as"
#include "command_handler.as"
#include "call_marker_tracker.as"
#include "airstrike_strafing_run.as"
#include "my_unlock_manager.as"
#include "unlock_customizations.as"
#include "repair_tank.as"
#include "rangefinder.as"

//#include "attack_order_randomizer.as"
#include "occult_seal_manager.as"
#include "spawn_time_handler.as"

#include "first_time_journal_message.as"

// --------------------------------------------
class MyGameMode : GameModeCampaign {
	// --------------------------------------------
	
	protected Music_Tracker@ m_musicTracker;
	
	MyGameMode(UserSettings@ settings) {
		super(settings);
		@m_musicTracker = Music_Tracker(this);
	}

	// --------------------------------------------
	void init() {
		// overriding GameModeCampaign behavior here
		GameMode::init();

		// we need to obtain user settings differently in Pacific
		// to handle loading faction choice data earlier 
		// for setting up faction specific stage configurators
		if (m_userSettings.m_continue) {
			loadUserSettings();
		}

		setupMapRotator();
		setupUnlockManager();
		setupSpecialCrateManager();
		setupSpecialCargoVehicleManager();
		setupItemDeliveryOrganizer();
		setupPenaltyManager();
		setupLocalBanManager();
		setupTestingToolsTracker();

		if (m_userSettings.m_continue) {
			_log("* restoring old game");

			// if loading, load metagame first
			updateGeneralInfo();
			load();
			// note, load handles initing map rotator / unlock_manager / etc at appropriate time

			m_mapRotator.startRotation(true);
		} else {
			// starting the invasion for the first time now, 
			// pick user settings from command line

			m_unlockManager.init(0);

			// - init sets up map rotator according to settings
			// - settings are stored in metagame savegame data
			m_mapRotator.init();

			// changes map, start the match, calls pre/post_begin_match
			m_mapRotator.startRotation();

			// NOTE: the beginning is a bit messed up here;
			// - we start from lobby, so we can't really query faction stuff
			//   or do much anything until the first map changes
			// - also, post_begin_match is set to add most of "metagame level"
			//   things as trackers for the game
			// - problem is, those components haven't been initialized at that point
			// - we only get to initialize them here
			// - right now, it's only item_delivery_organizer that needs to setup something
			//   before executing what normally would be done in post_begin_match, i.e.
			//   set up objectives, then add objectives as trackers in post_begin_match
			// - in case of the very first start, that goes wrong: post_begin_match
			//   informs item_delivery_organizer to add objectives, which haven't been created
			//	 at that point
			// - we'll just workaround that by re-doing that start here, 
			//   after proper initialization
			if (m_itemDeliveryOrganizer !is null) {
				m_itemDeliveryOrganizer.init();
				m_itemDeliveryOrganizer.matchStarted();
			}

			if (m_specialCrateManager !is null) {
				m_specialCrateManager.init();
			}

			if (m_specialCargoVehicleManager !is null) {
				m_specialCargoVehicleManager.init();
			}
		}

		// also do what GameModeCampaign does:
		// add local player as admin for easy testing, hacks, etc
		if (!getAdminManager().isAdmin(getUserSettings().m_username)) {
			getAdminManager().addAdmin(getUserSettings().m_username);
		}
	}

	// --------------------------------------------
	void loadUserSettings() {
		_log("loading user settings", 1);
		XmlElement@ query = XmlElement(
			makeQuery(this, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", "user_settings.xml"} } }));

		const XmlElement@ doc = getComms().query(query);
		if (doc !is null) {
			const XmlElement@ root = doc.getFirstChild();
			// read user-settings too, have them around separately..
			const XmlElement@ settings = root.getFirstElementByTagName("settings");
			if (settings !is null) {
				m_userSettings.fromXmlElement(settings);
				m_userSettings.m_continue = true;
			}
			m_userSettings.print();
		}
	}

	// --------------------------------------------
	void load() {
		// load metagame status now:
		_log("loading metagame", 1);

		XmlElement@ query = XmlElement(
			makeQuery(this, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "saved_data"} } }));
		const XmlElement@ doc = getComms().query(query);

		if (doc !is null) {
			const XmlElement@ root = doc.getFirstChild();

			// note, GameModeCampaign loads user settings here from metagame_invasion.xml, we do it earlier at loadUserSettings

			m_mapRotator.init();
			m_mapRotator.load(root);

			m_unlockManager.init(0);
			m_unlockManager.load(root);

			if (m_specialCrateManager !is null) {
				m_specialCrateManager.init();
				m_specialCrateManager.load(root);
			}

			if (m_specialCargoVehicleManager !is null) {
				m_specialCargoVehicleManager.init();
				m_specialCargoVehicleManager.load(root);
			}

			if (m_itemDeliveryOrganizer !is null) {
				m_itemDeliveryOrganizer.init();
				m_itemDeliveryOrganizer.load(root);
			}

			_log("loaded", 1);
		} else {
			_log("load failed");
			m_mapRotator.init();
			m_unlockManager.init(0);
			if (m_specialCrateManager !is null) {
				m_specialCrateManager.init();
			}
			if (m_specialCargoVehicleManager !is null) {
				m_specialCargoVehicleManager.init();
			}
			if (m_itemDeliveryOrganizer !is null) {
				m_itemDeliveryOrganizer.init();
			}
		}
	}

	// --------------------------------------------
	void save() {
		// also save user settings separately
		saveUserSettings();

		// save metagame status now:
		_log("saving metagame", 1);

		XmlElement commandRoot("command");
		commandRoot.setStringAttribute("class", "save_data");

		XmlElement root("saved_metagame");

		m_mapRotator.save(root);
		m_unlockManager.save(root);
		m_specialCrateManager.save(root);
		if (m_specialCargoVehicleManager !is null) {
			m_specialCargoVehicleManager.save(root);
		}
		if (m_itemDeliveryOrganizer !is null) {
			m_itemDeliveryOrganizer.save(root);
		}
	
		commandRoot.appendChild(root);

		// save through game
		getComms().send(commandRoot);
	}

	// --------------------------------------------
	void saveUserSettings() {
		// save metagame status now:
		_log("saving metagame", 1);

		XmlElement commandRoot("command");
		commandRoot.setStringAttribute("class", "save_data");
		commandRoot.setStringAttribute("filename", "user_settings.xml");

		XmlElement root("save");
		XmlElement@ settings = m_userSettings.toXmlElement("settings");
		root.appendChild(settings);

		commandRoot.appendChild(root);

		// save through game
		getComms().send(commandRoot);
	}

	// --------------------------------------------
	void postBeginMatch() {
		GameModeCampaign::postBeginMatch();
		addTracker(HawkinsGrenadeTracker(this));

		addTracker(CommandHandler(this));

		addTracker(m_musicTracker);
		m_musicTracker.reset();
		
		//addTracker(AttackOrderRandomizer(this));
		addTracker(OccultSealManager(this));

		array<string> sorting = getCallSorting();

		{
			array<Resource@> resources = {
				Resource("airstrike.call", "call"),
				Resource("airstrike1.call", "call"),
				Resource("airstrike2.call", "call")				
			};
			array<string> targetKeys = {
				'aa_gun.vehicle',
				'aa_gun2.vehicle'
			};
			addTracker(MultitargetResourceController(this, targetKeys, resources, sorting));
		}
		
		{
			array<Resource@> resources = {
				Resource("artillery.call", "call"),
				Resource("artillery1.call", "call")
			};
			array<string> targetKeys = {
				'coastal_gun.vehicle',
				'coastal_gun2.vehicle',
				'coastal_gun3.vehicle'    
			};
			addTracker(MultitargetResourceController(this, targetKeys, resources, sorting));
		}
		
		setupSpawnTimeHandler();

		addTracker(FirstTimeJournalMessage(this, "use some ww2 undead specific tag here"));
	}

/*
	// --------------------------------------------
	protected void setupMinibosses() {
		{
			// disable flamethrower veterans in friendly faction 
			// to add more challenge in invasion
			XmlElement command("command");
			command.setStringAttribute("class", "faction");
			command.setIntAttribute("faction_id", 0);
			command.setStringAttribute("soldier_group_name", "flamethrower_operator_veteran");
			command.setFloatAttribute("spawn_score", 0.0f);
			getComms().send(command);
		}
 	}
*/
	// --------------------------------------------
	void onSoundtrackChanged() {
		m_musicTracker.onExternalSoundtrackChanged();
	}

	// --------------------------------------------
	protected void setupMapRotator() {
		MyMapRotator@ mapRotator;
		//No doors, always automatic map rotation
		@mapRotator = MyServerMapRotator(this);
		/*if (!isInServerMode()) {
			@mapRotator = MyMapRotator(this);
		} else {
			@mapRotator = MyServerMapRotator(this);
		}*/
		//if (getUserSettings().m_factionChoice == 0) {
			MyStageConfiguratorAllies configurator(this, mapRotator);
		//} else {
		//	MyStageConfiguratorAxis configurator(this, mapRotator);
		//}
		@m_mapRotator = @mapRotator;
	}
	
	// --------------------------------------------
	protected void setupUnlockManager() {
		@m_unlockManager = MyUnlockManager(this, this, getUnlockCustomizations(), (isInServerMode() ? 4.0 : 100.0) * 60.0 * 60.0);
	}
	
	// --------------------------------------------
	protected void setupExperimentalFeatures() {
		addTracker(StrafingRun(this));
        addTracker(RepairTank(this));
        addTracker(RangeFinder(this));
	}

	// --------------------------------------------
	protected void setupItemDeliveryOrganizer() 
	{
		const UserSettings@ settings = this.getUserSettings();
		_log("faction choice of player=" + settings.m_factionChoice);
		//if(settings.m_factionChoice == 0)
		//{
				setupItemsAllies();
		//}
		//if(settings.m_factionChoice == 1)
		//{
		//		setupItemsAxis();
		//}
		
	}
	
	protected void setupItemsAllies() 
	{
		MyItemDeliveryConfigurator_USF configurator(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, configurator);
	}
	
	/*protected void setupItemsAxis() 
	{
		MyItemDeliveryConfigurator_WH configurator(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, configurator);
	}*/
	
	protected void setupCallMarkers() {
		// if you're adding a call here, make sure it has notify_metagame="1" in it's <call> tag
		array<CallMarkerConfig@> configs = {
			//CallMarkerConfig(string key, int atlasIndex = 0, float size = 2.0, float range = 1.0, string text = "")
			CallMarkerConfig("mortar.call", 6, 0.5, 45.0),
			CallMarkerConfig("mortar1.call", 7, 0.5, 45.0),      
			CallMarkerConfig("mortar2.call", 14, 0.5, 55.0),      
			CallMarkerConfig("artillery.call", 8, 1.0, 75.0),
			CallMarkerConfig("artillery1.call", 9, 1.0, 80.0),
			CallMarkerConfig("artillery2.call", 8, 1.0, 75.0),
			CallMarkerConfig("artillery3.call", 9, 1.0, 80.0),
			CallMarkerConfig("airstrike.call", 10, 0.5, 25.0),
			CallMarkerConfig("airstrike1.call", 11, 0.5, 12.0)                         
			};

		addTracker(CallMarkerTracker(this, configs));
	}
	
	// --------------------------------------------
	protected void setupSpawnTimeHandler() {
		// add for all enemies, skipping friendly at 0
		for (uint i = 1; i < getFactionCount(); ++i) {
			const Faction@ faction = getFactions()[i];
			if (faction.isNeutral()) continue;
			
			// interpolate players 1 -> 24, spawn time 3.0 -> 1.0
			addTracker(SpawnTimeHandler(this, i, 1, 24, 3.0, getUserSettings().m_spawnTimeAtMaxPlayers));
		}
	}

	// --------------------------------------------
	protected void setupVehicleDeliveryObjectives() {
		MyVehicleDeliveryConfigurator configurator(this);
		configurator.setup();
	}
	
	// --------------------------------------------
	protected void setupGenericObjectiveInstructions() {
		// not used in pacific
		/*
		array<string> vehicles = {
			"radar_tower.vehicle",
			"radio_jammer.vehicle",
			"radio_jammer2.vehicle",
			"prison_building.vehicle",
			"prison_door.vehicle",
			"submarine.vehicle",
			"submarine2.vehicle"
			};
		addTracker(GenericDestroyObjectiveInstructor(this, vehicles));
		*/
		// aa_gun* and coastal_gun* would need to be handled via MultitargetResourceController
		// to get hint comment at spot event happen only for one of the targets and
		// make the congrats comment happen only once all of them are destroyed
	}
		
}
