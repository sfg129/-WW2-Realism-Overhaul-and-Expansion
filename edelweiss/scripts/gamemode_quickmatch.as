// internal
#include "metagame.as"
#include "gamemode.as"
#include "log.as"
#include "resource_unlocker.as"

// generic trackers
#include "basic_command_handler.as"
#include "command_handler.as"
#include "spawn_in_base_call_handler.as"
#include "airstrike_strafing_run.as"
#include "call_marker_tracker.as"
#include "repair_tank.as"
#include "rangefinder.as"

//unlockable lists
#include "unlock_axis.as"
#include "unlock_usf.as"
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

		addTracker(StrafingRun(this));
        addTracker(RepairTank(this));
        addTracker(RangeFinder(this));

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

		addTracker(CallMarkerTracker(this, configs, true));
		
		addTracker(SpawnInBaseCallHandler(this, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
	
		addTracker(SpawnInBaseCallHandler(this, "ukf_inf.call", "ukf_inf_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_pl_inf.call", "ukf_pl_inf_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_para_no_parachuting.call", "ukf_para_no_parachuting_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_inf_ai.call", "ukf_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_pl_inf_ai.call", "ukf_pl_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_para_no_parachuting_ai.call", "ukf_para_no_parachuting_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));

		addTracker(SpawnInBaseCallHandler(this, "wh_inf.call", "wh_inf_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		
		addTracker(SpawnInBaseCallHandler(this, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle.call", "ija_vehicle1_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));

		const XmlElement@ player = getPlayerInfo(this, 0);
		if (player !is null) {
			string username = player.getStringAttribute("name");
			// add local player as admin for easy testing, hacks, etc
			if (!getAdminManager().isAdmin(username)) {
				getAdminManager().addAdmin(username);
			}
		}
		
		unlockFactionResources(0, getUnlockItemListUsf());
		unlockFactionResources(1, getUnlockItemListAxis());
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
