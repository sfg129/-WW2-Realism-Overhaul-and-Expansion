#include "hawkins_grenade_test.as"
// internal
#include "metagame.as"
#include "gamemode.as"
#include "log.as"

// generic trackers
#include "basic_command_handler.as"
#include "command_handler.as"
#include "spawn_in_base_call_handler.as"

// --------------------------------------------
class GameModeBaseSpawn : GameMode {
	// --------------------------------------------
	GameModeBaseSpawn(const XmlElement@ settings) {
		super(settings.getStringAttribute("log_level"));
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
		
		addTracker(BasicCommandHandler(this));
		addTracker(CommandHandler(this));
		
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
	
		addTracker(SpawnInBaseCallHandler(this, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {"point_262"}, true, "vehicle"));

		addTracker(SpawnInBaseCallHandler(this, "ukf_inf.call", "ukf_inf_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_pl_inf.call", "ukf_pl_inf_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_para_no_parachuting.call", "ukf_para_no_parachuting_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_inf_ai.call", "ukf_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_pl_inf_ai.call", "ukf_pl_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "ukf_para_no_parachuting_ai.call", "ukf_para_no_parachuting_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));

		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		addTracker(SpawnInBaseCallHandler(this, "wh_inf.call", "wh_inf_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		addTracker(SpawnInBaseCallHandler(this, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
	
		const XmlElement@ player = getPlayerInfo(this, 0);
		if (player !is null) {
			string username = player.getStringAttribute("name");
			// add local player as admin for easy testing, hacks, etc
			if (!getAdminManager().isAdmin(username)) {
				getAdminManager().addAdmin(username);
			}
		}
	}

	// --------------------------------------------
	uint getFactionCount() const { 
		return 2;
	}
}
