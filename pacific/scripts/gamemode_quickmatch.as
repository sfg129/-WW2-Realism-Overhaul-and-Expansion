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
		
		addTracker(BasicCommandHandler(this));
		addTracker(CommandHandler(this));
        addTracker(RangeFinder(this));

		array<CallMarkerConfig@> configs = {
			//CallMarkerConfig(string key, int atlasIndex = 0, float size = 2.0, float range = 1.0, string text = "")
			CallMarkerConfig("mortar.call", 6, 0.5, 45.0),
			CallMarkerConfig("mortar1.call", 7, 0.5, 45.0),      
			CallMarkerConfig("mortar2.call", 7, 0.5, 45.0),      
			CallMarkerConfig("artillery.call", 8, 1.0, 75.0),
			CallMarkerConfig("artillery1.call", 9, 1.0, 80.0),
			CallMarkerConfig("artillery2.call", 8, 1.0, 75.0),
			CallMarkerConfig("artillery3.call", 9, 1.0, 80.0),
			CallMarkerConfig("airstrike.call", 10, 0.5, 25.0),
			CallMarkerConfig("airstrike1.call", 11, 0.5, 12.0)                         
		};

		addTracker(CallMarkerTracker(this, configs, true));
		
		addTracker(SpawnInBaseCallHandler(this, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Carrier","Attack Ship"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));    
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Carrier","Attack Ship","Mt. Suribachi","The Armory","Submarine Pens","Warehouses","The Heights"}, true, "vehicle"));    
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
