#include "hawkins_grenade_test.as"
#include "gamemode_campaign.as"
#include "my_stage_configurator_usmc.as"
#include "my_stage_configurator_ija.as"
#include "my_map_rotator.as"
#include "my_server_map_rotator.as"
#include "my_item_delivery_configurator_usmc.as"
#include "my_item_delivery_configurator_ija.as"
#include "my_vehicle_delivery_configurator.as"
#include "music_tracker.as"
#include "call_sorting.as"
#include "spawn_in_base_call_handler.as"
#include "command_handler.as"
#include "call_marker_tracker.as"
#include "call_marker_configs.as"
#include "airstrike_strafing_run.as"
#include "rangefinder.as"
#include "my_unlock_manager.as"
#include "unlock_customizations.as"
#include "my_stage_configurator_usmc_invasion.as"
#include "my_stage_configurator_ija_invasion.as"
#include "emoticons.as"

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
		if (!isInServerMode()) {
			@mapRotator = MyMapRotator(this);
			if (getUserSettings().m_factionChoice == 0) {
				MyStageConfiguratorUSMC configurator(this, mapRotator);
			} else {
				MyStageConfiguratorIJA configurator(this, mapRotator);
			}
		} else {
			@mapRotator = MyServerMapRotator(this);
		if (getUserSettings().m_factionChoice == 0) {
				MyStageConfiguratorUSMCInvasion configurator(this, mapRotator);
		} else {
				MyStageConfiguratorIJAInvasion configurator(this, mapRotator);
			}
		}

		@m_mapRotator = @mapRotator;
	}

	// --------------------------------------------
	protected void setupItemDeliveryOrganizer() 
	{
		const UserSettings@ settings = this.getUserSettings();
		_log("faction choice of player=" + settings.m_factionChoice);
		if(settings.m_factionChoice == 0)
		{
				setupItemsUSMC();
		}
		if(settings.m_factionChoice == 1)
		{
				setupItemsIJA();
		}
		
	}
	
	protected void setupItemsUSMC() 
	{
		MyItemDeliveryConfigurator_USMC configurator(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, configurator);
	}
	
	protected void setupItemsIJA() 
	{
		MyItemDeliveryConfigurator_IJA configurator(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, configurator);
	}
	
	protected void setupCallMarkers() {
		// if you're adding a call here, make sure it has notify_metagame="1" in it's <call> tag
		array<CallMarkerConfig@> configs = getCallMarkerConfigs();

		addTracker(CallMarkerTracker(this, configs));
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
	}
		
	// --------------------------------------------
	protected void setupUnlockManager() {
		@m_unlockManager = MyUnlockManager(this, this, getUnlockCustomizations(), (isInServerMode() ? 4.0 : 100.0) * 60.0 * 60.0);
	}

	// --------------------------------------------
	protected void setupExperimentalFeatures() {
		addTracker(StrafingRun(this));
        	addTracker(RangeFinder(this));
		addTracker(Emoticons(this));
	}
}
