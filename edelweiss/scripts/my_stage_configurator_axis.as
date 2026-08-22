#include "my_stage_configurator.as"
#include "spawn_in_base_call_handler.as"
#include "damaged_vehicle.as"
#include "pausing_koth_timer.as"
#include "airstrike_strafing_run.as"

#include "paratrooper_mode.as"
#include "spawn_at_node.as"

#include "capture_base_with_vehicle.as"
#include "attack_target_order.as"
#include "run_at_start.as"
#include "axis_arnhem_helper.as"

#include "boss_music.as"

#include "phase_controller_sealion.as"
#include "phase_controller_overlord_axis.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfiguratorAxis : MyStageConfigurator {
	// ------------------------------------------------------------------------------------------------
	MyStageConfiguratorAxis(GameModeInvasion@ metagame, MyMapRotator@ mapRotator) {
		super(metagame, mapRotator);
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void addStage(Stage@ stage) {
		if (m_metagame.isInServerMode()) {
			stage.m_includeLayers.insertLast("layer_invasion.axis");
		} else {
			stage.m_includeLayers.insertLast("layer_campaign.axis");
		}
		MyStageConfigurator::addStage(stage);
	}
    
    
	
	// ------------------------------------------------------------------------------------------------
	protected void setupNormalStages() {
		addStage(setupStage1());
		addStage(setupStageOverlord());
		addStage(setupStage2());

		addStage(setupStage3());
		addStage(setupStage5());
		addStage(setupStage4());
		addStage(setupStage6());
		addStage(setupStageFinal());
	}

	protected void prepareVisualTimer(MyStage@ stage) {
		// doesn't matter much what is set here as time, time is expected to be set by setVisualTimer at various phases
		stage.m_defenseWinTime = 60.0; 
		// "custom_ignore_end" -> match will not end when timer runs out
		stage.m_defenseWinTimeMode = "custom_ignore_end"; 
	}	

	// ------------------------------------------------------------------------------------------------
	protected void setDefaultAttackBreakTimes(Stage@ stage) {
		for (uint i = 0; i < stage.m_factions.size(); ++i) {
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction", i);
			command.setFloatAttribute("start_attack_break_time", 30.0f);
	//		command.setFloatAttribute("attack_break_time", 5.0f);
			stage.m_extraCommands.insertLast(command);
		}
	}	

	// ------------------------------------------------------------------------------------------------
	protected void prepareParatrooperMode(MyStage@ stage) {
		// NOTE: capacity offset for bots to spawn when baseless at the start
		stage.addTracker(ParatrooperMode(m_metagame, 60.0f /* friendly baseless capacity offset */ ));           
		array<ScoredResource@> resources = {
			ScoredResource("parachute.vehicle", "vehicle", 1.0f)
		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "parachute", 0, 10000 /* high count to ensure all nodes are used */));
		
		// doesn't matter much what is set here as time, will be set into game by ParatrooperMode
		stage.m_defenseWinTime = 60.0; 
		// "custom" -> match will end when timer runs out
		stage.m_defenseWinTimeMode = "custom"; 

		stage.m_showMapAtStartIfDead = true;

		{
			// specific settings for friendly faction
			Faction@ f = stage.m_factions[0];
			f.m_bases = 0;
			f.m_loseWithoutBases = false;
		}		
		{
			// specific settings for enemy faction
			Faction@ f = stage.m_factions[1];
			// disable general game rule to win when owning all bases
			f.m_winWithAllBases = false;
		}		
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void setupMapView(MyStage@ stage) {
		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("overlay_texture", "map_axis.png");
			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("type", "frame");
			command.setStringAttribute("overlay_texture", "mapview_card_axis.png");
			stage.m_extraCommands.insertLast(command);
		}
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage1() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Sicily";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss1";
		stage.m_mapInfo.m_id = "edelweiss1";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis");      
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_para_no_parachuting.call ", "usf_para_no_parachuting_spawn.call", array<string> = {""}, true, "infantry"));  



stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_pziv_88.call", "wh_vehicle_pziv_88_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
								stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"route_115_north"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"route_115_north"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));

		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addStartComment(Comment("sicily, part 1", 5.0));
		stage.addStartComment(Comment("sicily, part 2", 5.0));
		stage.addStartComment(Comment("sicily, part 3", 5.0));
		stage.addStartComment(Comment("sicily, part 4", 5.0));
		
		stage.m_maxSoldiers = 11 * 20;        // 220 units
		//stage.m_playerAiCompensation = 2.5;    // was 2 (hotfix2)
		//stage.m_playerAiReduction = 1.5;       // was 2
		stage.m_soldierCapacityVariance = 0.55;
		
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.15));
			f.m_overCapacity = 0;      
			// NOTE: this is the capacity offset after having captured the first base
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 0.85;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.69, 0.2));               // was 0.67 0.2
			f.m_overCapacity = 80;
			f.m_capacityOffset = 0;       // was 5
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
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
		
		// metadata
		stage.m_primaryObjective = "capture";
        
		setupMapView(stage);
		



		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage2() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Sainte-Marie-du-Mont";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss2";
		stage.m_mapInfo.m_id = "edelweiss2";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis"); 
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));	
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addStartComment(Comment("brecourt, part 1", 5.0));
		stage.addStartComment(Comment("brecourt, part 2", 5.0));
		stage.addStartComment(Comment("brecourt, part 3", 5.0));
		stage.addStartComment(Comment("brecourt, part 4", 5.0));
		stage.addStartComment(Comment("brecourt, part 5", 5.0));
		stage.addStartComment(Comment("brecourt, part 6", 5.0));
		
		stage.m_maxSoldiers = 9 * 22;       // 198 units
		//stage.m_playerAiCompensation = 2.5;   // was 4 
		//stage.m_playerAiReduction = 1.5;      // was 2
		stage.m_soldierCapacityVariance = 0.58;         
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.42, 0.15));   
			f.m_overCapacity = 0;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;        
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.67, 0.25));     
			f.m_overCapacity = 70;
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
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
		
		// metadata
		stage.m_primaryObjective = "capture";
        
		setupMapView(stage);
		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStageOverlord() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Operation Overlord";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss11";
		stage.m_mapInfo.m_id = "edelweiss11";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis");

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
		//stage.addTracker(PeacefulLastBase(m_metagame, 0));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"castle"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"castle"}, true, "vehicle"));

								stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"castle"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"castle"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"castle"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"castle"}, true, "vehicle"));

		//stage.addStartComment(Comment("Overlord Axis, part 1", 5.0));
		//stage.addStartComment(Comment("Overlord Axis, part 2", 5.0));
		//stage.addStartComment(Comment("Overlord Axis, part 3", 5.0));
		//handled in phase controller

		stage.m_maxSoldiers = 13 * 17; 
		//		stage.m_playerAiCompensation = 3;
//		stage.m_playerAiReduction = 1.5;
		stage.m_soldierCapacityVariance = 0.4;
    	
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
	enemySpawnCompensationFactor *= 0.5f;
	
		stage.setPhaseController(PhaseControllerOverlord_Axis(m_metagame, enemySpawnCompensationFactor));
		//stage.m_useCustomTimerMode = true;

		//stage.m_defenseWinTime = 360; 
		//stage.m_defenseWinTimeMode = "custom";

		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.45, 0.1));  
			f.m_overCapacity = 0;       
			f.m_capacityOffset = 30;      
			f.m_capacityMultiplier = 0.88;  
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.77, 0.195)); 
			f.m_overCapacity = 80;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 1.2;
			stage.m_factions.insertLast(f);
		}
		
		prepareVisualTimer(stage);
		stage.m_primaryObjective = "phases";
		
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"m1919_hmg.vehicle","vickers_hmg.vehicle","armored_truck.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 1);
			command.setFloatAttribute("side_base_attack_probability", 0.05);
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		
		setupMapView(stage);
        		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage3() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Hill 262";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss3";
		stage.m_mapInfo.m_id = "edelweiss3";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis");
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(Overtime(m_metagame, 0));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {"point_262"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));

				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"castle"}, true, "point_262"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_pl_inf.call", "ukf_pl_inf_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_pl_inf_ai.call", "ukf_pl_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
	
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		
		stage.addStartComment(Comment("hill262, part 1", 5.0));
		stage.addStartComment(Comment("hill262, part 2", 5.0));
		stage.addStartComment(Comment("hill262, part 3", 5.0));
		stage.addStartComment(Comment("hill262, part 4", 5.0));
		stage.addStartComment(Comment("hill262, part 5", 5.0));
        
		stage.addTracker(Spawner(m_metagame, 1, Vector3(558,10,464), 5, "regular"));       // hill cap squad filler        
		
		stage.m_maxSoldiers = 6 * 28;       // 168
		//stage.m_playerAiCompensation = 2;   // was 3
//	stage.m_playerAiReduction = 1; // was 2 
		stage.m_soldierCapacityModel = "constant";
		
		stage.m_defenseWinTime = 720.0;
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.25, 0.1));              
			f.m_capacityOffset = 0;                                             
			f.m_capacityMultiplier = 1.0;											
			f.m_overCapacity = 0;                                                 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.22, 0.1));                    
			f.m_capacityOffset = 85;            // was 90
			f.m_capacityMultiplier = 0.00001;   
			f.m_overCapacity = 35;              // was 40 compensated with hill cap squad
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0, 1));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}

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

		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "Hill 262";
		stage.m_radioObjectivePresent = false;

		setupMapView(stage);

		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage4() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Hell's Highway";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss4";
		stage.m_mapInfo.m_id = "edelweiss4";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis"); 
        
        stage.m_useCaptureTimer = false;
		stage.addTracker(PeacefulLastBase(m_metagame, 0));

        stage.addTracker(CaptureBaseWithVehicle(m_metagame, "cargo_tank.vehicle", 0, MarkerWithHealthConfig("default", 16, array<int> = {27,26,25,24,23,22,21,20,19,18,17}, 1.0)));
		array<string> order = {
			"best",
			"son_fields",
			"son",
			"son_bridge",
			"eindhoven_north",
			"eindhoven_south",
			"aalst",
			"ridge_fortifications",
			"valkenswaard",
			"wet_fields",
			"leende",
            "leende_south",
			"leenderstrijp",
            "leenderstrijp_west",
			"grote-heide",
			"westerhoven",
			"joes_bridge"
		};
        stage.addTracker(AttackTargetOrder(m_metagame, 0, order));
		order.reverse();
        stage.addTracker(AttackTargetOrder(m_metagame, 1, order));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"castle"}, true, ""));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_inf.call", "ukf_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_inf_ai.call", "ukf_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addStartComment(Comment("hellshighway, part 1", 5.0));
		stage.addStartComment(Comment("hellshighway, part 2", 5.0));
		stage.addStartComment(Comment("hellshighway, part 3", 5.0));
		stage.addStartComment(Comment("hellshighway, part 4", 5.0));
		stage.addStartComment(Comment("hellshighway, part 5", 5.0));        
        
		stage.addTracker(Spawner(m_metagame, 0, Vector3(407,0,183), 10, "regular"));       // cargo tank filler 
		stage.addTracker(Spawner(m_metagame, 0, Vector3(407,0,183), 4, "nco"));       // cargo tank filler          

		stage.addTracker(Spawner(m_metagame, 1, Vector3(670,5,163), 13, "regular"));       // son fields base filler
		stage.addTracker(Spawner(m_metagame, 1, Vector3(687,5,170), 3, "veteran"));       // son fields base filler
		stage.addTracker(Spawner(m_metagame, 1, Vector3(891,5,174), 13, "regular"));       // son base filler 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(891,5,174), 3, "veteran"));       // son base filler        
                
		
		stage.m_maxSoldiers = 17 * 15;    // 255 units
		//stage.m_playerAiCompensation = 4;   // was 3
		//stage.m_playerAiReduction = 2;    // was 1
		stage.m_soldierCapacityVariance = 0.55;     
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.15, 0.1));       // was 0.45 0.1
			f.m_overCapacity = 12;              // was 7
			f.m_capacityOffset = 0;            
			f.m_capacityMultiplier = 0.7;    // was 0.6  
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.95, 0.03));       
			f.m_overCapacity = 35;              
			f.m_capacityOffset = 10;             
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";

        // pause only before the first initial attack 
		setDefaultAttackBreakTimes(stage);

		// set allied commander ai
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction", 0);
			command.setIntAttribute("attack_start_spread", 1);
			command.setIntAttribute("attack_target_spread", 1);
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
            XmlElement command("command");
            command.setStringAttribute("class", "soldier_ai");
            command.setIntAttribute("faction", 0);
            command.setIntAttribute("willingness_to_charge", 1.0);
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radar_tower.vehicle"}, false);

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
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage5() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Arnhem";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss5";
		stage.m_mapInfo.m_id = "edelweiss5";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis"); 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
        stage.m_playerFirstSpawnPositionHint = Vector3(500,0,900);  // spawns the player at south bridge and not at kampfgruppe_hq on initial spawn
		
		array<string> order = {
			"bridge_south",
			"kampfgruppe_hq",
			"bridge_north",
			"para_hq",
			"plaza",
			"church"
		};
        stage.addTracker(AttackTargetOrder(m_metagame, 0, order));
//		order.reverse();
//        stage.addTracker(AttackTargetOrder(m_metagame, 1, order));	
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));

				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"castle"}, true, ""));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));		

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_para_no_parachuting.call", "ukf_para_no_parachuting_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_para_no_parachuting_ai.call", "ukf_para_no_parachuting_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(AxisArnhemHelper(m_metagame));
		
		stage.addStartComment(Comment("arnhem, part 1", 5.0));
		stage.addStartComment(Comment("arnhem, part 2", 5.0));
		stage.addStartComment(Comment("arnhem, part 3", 5.0));
		stage.addStartComment(Comment("arnhem, part 4", 5.0));
		stage.addStartComment(Comment("arnhem, part 5", 5.0));    
		
		stage.m_maxSoldiers = 13 * 18;    // 234 units  
		//stage.m_playerAiCompensation = 3;  
		//stage.m_playerAiReduction = 1;     
		stage.m_soldierCapacityVariance = 0.5;      // was 0.45
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.15));      
			f.m_overCapacity = 5;    // was 10
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 0.85;      
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.69, 0.2));      // was 0.65 0.26 
			f.m_overCapacity = 70;        // was 100   
			f.m_capacityOffset = 10;         
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radar_tower.vehicle"}, false);

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
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage6() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Bastogne";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss6";
		stage.m_mapInfo.m_id = "edelweiss6";

		stage.m_fogOffset = 20.0;    
		stage.m_fogRange = 50.0;    

		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis");
    
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
		array<string> order = {
			"foy_north",
			"foy_south",
			"foy_outskirts",
			"bois_jacques"
		};
        stage.addTracker(AttackTargetOrder(m_metagame, 0, order));
        stage.addTracker(AttackTargetOrder(m_metagame, 1, order));	
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));	
								stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
										stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {""}, true, ""));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {""}, true, "vehicle"));


		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addStartComment(Comment("bastogne, part 1", 5.0));
		stage.addStartComment(Comment("bastogne, part 2", 5.0));
		stage.addStartComment(Comment("bastogne, part 3", 5.0));
		stage.addStartComment(Comment("bastogne, part 4", 5.0));
		stage.addStartComment(Comment("bastogne, part 5", 5.0));
		stage.addStartComment(Comment("bastogne, part 6", 5.0));
		
		stage.m_maxSoldiers = 10 * 20;       // 200 units
		//stage.m_playerAiCompensation = 3;  // was 2.5 (hotfix2)  
		//stage.m_playerAiReduction = 1;       // was 2
		stage.m_soldierCapacityVariance = 0.4;      
		
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.45, 0.12));       
			f.m_capacityMultiplier = 0.85;
			f.m_capacityOffset = 5;                      
			stage.m_factions.insertLast(f);
		}
		{
			// in adventure mode, this faction config will be replaced with the correct one when final battle 1 opponent is decided 
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.6, 0.35));
			f.m_overCapacity = 100;           
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
	
	
	// ------------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------------
	// FINAL STAGE
	// ------------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------------
	
	protected Stage@ setupStageFinal() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Operation Sealion";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss8";
		stage.m_mapInfo.m_id = "edelweiss8";
		stage.m_includeLayers.insertLast("bases.axis"); 
		stage.m_includeLayers.insertLast("layer.axis");
        
		stage.m_fogOffset = 24.0; 
		stage.m_fogRange = 60.0; 
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
								stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"castle"}, true, ""));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m3_halftrack.call", "ukf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_inf.call", "ukf_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_inf_ai.call", "ukf_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));

		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_panther.call", "wh_vehicle_panther_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_tiger.call", "wh_vehicle_tiger_spawn.call", array<string> = {"citadel"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {"citadel"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {"citadel"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));

		
		stage.addStartComment(Comment("sealion, part 1", 5.0));
		stage.addStartComment(Comment("sealion, part 2", 5.0));
		stage.addStartComment(Comment("sealion, part 3", 5.0));
		stage.addStartComment(Comment("sealion, part 4", 5.0));
		stage.addStartComment(Comment("sealion, part 5", 5.0));
		stage.addStartComment(Comment("sealion, part 6", 5.0));
		
		stage.m_maxSoldiers = 15 * 14;          // 210 units
		//stage.m_playerAiCompensation = 6;    // was 4 (1.81) then 5 (1.82-1.86)
		//stage.m_playerAiReduction = 1;       // was 1.5 (hotfix2)
		stage.m_soldierCapacityVariance = 0.4;       
    	
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
	enemySpawnCompensationFactor *= 0.5f;
	stage.setPhaseController(PhaseControllerSealion(m_metagame, enemySpawnCompensationFactor));
	
		stage.addTracker(BossMusic(m_metagame, "mus_boss_battle_sealion.wav", "tog2_boss.vehicle", 19.0, 330.0, 10.0, 1.5));	//volume was 5.0, last parameter - and distance was 170, 2nd parameter	
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.45, 0.1));  
			f.m_overCapacity = 0;       
			f.m_capacityOffset = 30;      
			f.m_capacityMultiplier = 0.8;             
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.77, 0.14));   // was 0.77 0.15 in 1.81
			f.m_overCapacity = 120;  
			f.m_capacityOffset = 15;   											//was 0 prior to 1.87
			f.m_capacityMultiplier = 1.3;										//was 1.2 prior to 1.87
			stage.m_factions.insertLast(f);
		}
		
		stage.m_primaryObjective = "capture";
		
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

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
		prepareParatrooperMode(stage);
		setupMapView(stage);
        		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
// will check this bit out later, edelweiss' campaign will be linear rather then unlocked by stages
//	void setupStageUnlockRules() {
//		{
//			// completing island1 opens island2
//			StageUnlockRule rule(
//				array<string> = {"island1"},
//				array<string> = {"island2"});
//			m_myMapRotator.addStageUnlockRule(rule);
//		}
//		{
//			// completing island2 opens island3 and island4 
//			StageUnlockRule rule(
//				array<string> = {"island2"},
//				array<string> = {"island3","island4"});
//			m_myMapRotator.addStageUnlockRule(rule);
//		}
//		{
//			// completing island3 and island4 opens island5 and island6 
//			StageUnlockRule rule(
//				array<string> = {"island3","island4"},
//				array<string> = {"island5","island6","island8"});
//			m_myMapRotator.addStageUnlockRule(rule);
//		}
//		{
//			// completing island5 and island6 opens island7 
//			StageUnlockRule rule(
//				array<string> = {"island5","island6","island8"},
//				array<string> = {"island7"});
//			m_myMapRotator.addStageUnlockRule(rule);
//		}
//	}
	
	// --------------------------------------------
	protected void setupTransports() {
		//addTransport("edelweiss1", "hitbox_extraction2_2", "edelweiss2");

		// Sicily -> Overlord
	
			addTransport("edelweiss1", "hitbox_extraction2_2", "edelweiss11");
			// Overlord -> Sainte-Marie-du-Mont
	 		 addTransport("edelweiss11", "hitbox_extraction3", "edelweiss2");


	    //addTransport("edelweiss2", "hitbox_extraction1", "edelweiss1");
	    addTransport("edelweiss2", "hitbox_extraction3", "edelweiss3");
	    //addTransport("edelweiss2", "hitbox_extraction11", "edelweiss11");

	    //addTransport("edelweiss11", "hitbox_extraction3", "edelweiss3");
		
	    //addTransport("edelweiss3", "hitbox_extraction3_2", "edelweiss2");
		addTransport("edelweiss3", "hitbox_extraction3_5", "edelweiss5");

	    //addTransport("edelweiss5", "hitbox_extraction5_3", "edelweiss3");
	    addTransport("edelweiss5", "hitbox_extraction5-4", "edelweiss4");
		
	    //addTransport("edelweiss4", "hitbox_extraction4_5", "edelweiss5");
	    addTransport("edelweiss4", "hitbox_extraction4_6", "edelweiss6");
		
	    //addTransport("edelweiss6", "hitbox_extraction6_4", "edelweiss4");
	    addTransport("edelweiss6", "hitbox_extraction6_8", "edelweiss8");
	}
	
	// --------------------------------------------
	protected void setupStartingMaps() {
		m_myMapRotator.addStartingMap("edelweiss1");
	}
}
