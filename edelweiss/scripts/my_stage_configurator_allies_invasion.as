#include "my_stage_configurator_allies.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfiguratorAlliesInvasion : MyStageConfiguratorAllies {
	// ------------------------------------------------------------------------------------------------
	MyStageConfiguratorAlliesInvasion(GameModeInvasion@ metagame, MyMapRotator@ mapRotator) {
		super(metagame, mapRotator);
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void setupNormalStages() {
		addStage(setupStage1());
		addStage(setupStage2());
		addStage(setupStageOverlord());
		addStage(setupStageSwan());
		addStage(setupStage3());
		addStage(setupStage4());
		addStage(setupStage5());
/*		addStage(setupStagePowerJunction());
*/		addStage(setupStage6());
		addStage(setupStageFinal());
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStageSwan() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Swan River";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss9";
		stage.m_mapInfo.m_id = "edelweiss9";
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies"); 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_pl_inf.call", "ukf_pl_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_pl_inf_ai.call", "ukf_pl_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		
		stage.m_maxSoldiers = 19 * 15;
		stage.m_playerAiCompensation = 4;
		stage.m_playerAiReduction = 2;
		stage.m_soldierCapacityVariance = 0.6;
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.1));
			f.m_overCapacity = 0; 
			f.m_capacityOffset = 12;
			f.m_capacityMultiplier = 1;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.62, 0.15));   
			f.m_overCapacity = 120;
			f.m_capacityOffset = 0;
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 1);
			//command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 4); // irrelevant here but this is the default value (4)
			command.setFloatAttribute("side_base_attack_probability", 0.05);				// default value is 0.05
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}		

		setupMapView(stage);

		return stage;
	}
}
