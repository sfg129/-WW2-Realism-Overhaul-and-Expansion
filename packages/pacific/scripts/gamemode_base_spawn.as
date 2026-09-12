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
	}

	// --------------------------------------------
	uint getFactionCount() const { 
		return 2;
	}
}
