#include "hawkins_grenade_test.as"
#include "flame_vehicle_damage.as"
#include "vehicle_preloader.as"
// internal
#include "metagame.as"
#include "gamemode.as"
#include "log.as"
#include "resource_unlocker.as"

// generic trackers
#include "basic_command_handler.as"
#include "command_handler.as"
#include "spawn_in_base_call_handler.as"
#include "call_marker_tracker.as"
#include "call_marker_configs.as"
#include "airstrike_strafing_run.as"
#include "rangefinder.as"

//unlockable lists
#include "unlock_ija.as"
#include "unlock_usmc.as"
#include "unlock_customizations.as"
#include "unlock_firemodes.as"

// --------------------------------------------
class GameModeQuickMatch : GameMode {
	protected string m_mapId;
	// --------------------------------------------
	GameModeQuickMatch(const XmlElement@ settings, string mapId = "") {
		super(settings.getStringAttribute("log_level"));
		m_mapId = mapId;
	}

	// --------------------------------------------
	void init() {
		GameMode::init();

		preBeginMatch();
		postBeginMatch();
	}

	// --------------------------------------------
	void postBeginMatch() {
		GameMode::postBeginMatch();
		addTracker(HawkinsGrenadeTracker(this));
		addTracker(FlameVehicleDamage(this));
		addTracker(HighDetailVehiclePreloader(this, m_mapId));
		
		addTracker(BasicCommandHandler(this));
		addTracker(CommandHandler(this));
		addTracker(StrafingRun(this));
        addTracker(RangeFinder(this));

		array<CallMarkerConfig@> configs = getCallMarkerConfigs();

		addTracker(CallMarkerTracker(this, configs, true));
		
		addTracker(SpawnInBaseCallHandler(this, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4a3e8.call", "usf_vehicle_m4a3e8_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));    
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));    
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle_medium_tank_chi_ha_early.call", "ija_vehicle_medium_tank_chi_ha_early_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));    

				
		const XmlElement@ player = getPlayerInfo(this, 0);
		if (player !is null) {
			string username = player.getStringAttribute("name");
			// add local player as admin for easy testing, hacks, etc
			if (!getAdminManager().isAdmin(username)) {
				getAdminManager().addAdmin(username);
			}
		}
		
		unlockFactionResources(0, getUnlockItemListUsmc());
		unlockFactionResources(1, getUnlockItemListIja());
	}
	
	// --------------------------------------------
	void unlockFactionResources(int factionId, array<Resource@>@ list) {		
		
		dictionary customizationsMap = getUnlockCustomizations();		
		if (customizationsMap.exists(m_mapId)) {
			dictionary@ customizations;
			customizationsMap.get(m_mapId, @customizations);	
			for (uint i = 0; i < list.size(); ++i) {
				Resource@ r = list[i];
				string source = r.m_key;
				if (customizations.exists(source)) {
					// replace
					string target;
					customizations.get(source, target);
					r.m_key = target;
				}
			}
		}
		
		dictionary firemodes = getUnlockFiremodes();
		for (uint i = 0; i < list.size(); ++i) {
			changeFactionResources(this, factionId, array<const Resource@> = {list[i]}, true);
			string baseMode = list[i].m_key;
			if (firemodes.exists(baseMode)) {
				string altMode;
				firemodes.get(baseMode, altMode);
				changeFactionResources(this, factionId, array<const Resource@> = {Resource(altMode, list[i].m_type)}, true);
			}
		}
	}

	// --------------------------------------------
	uint getFactionCount() const { 
		return 2;
	}
}
