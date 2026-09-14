#include "hawkins_grenade_test.as"
#include "flame_vehicle_damage.as"
#include "an_m8_smoke.as"
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
#include "call_marker_configs.as"
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
		addTracker(HawkinsGrenadeTracker(this));
		addTracker(FlameVehicleDamage(this));
		addTracker(AnM8SmokeTracker(this));
		
		addTracker(BasicCommandHandler(this));
		addTracker(CommandHandler(this));

		addTracker(StrafingRun(this));
        addTracker(RepairTank(this));
        addTracker(RangeFinder(this));

		array<CallMarkerConfig@> configs = getCallMarkerConfigs();

		addTracker(CallMarkerTracker(this, configs, true));
		
		addTracker(SpawnInBaseCallHandler(this, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"point_262","Power plant"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4a3e2_75.call", "usf_vehicle_m4a3e2_75_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4a3e2_76.call", "usf_vehicle_m4a3e2_76_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
	
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
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {"point_262","Woods","Docks","Lighthouse","Power plant"}, true, "vehicle"));
		
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
