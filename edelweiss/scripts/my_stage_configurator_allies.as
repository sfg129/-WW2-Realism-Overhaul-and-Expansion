#include "my_stage_configurator.as"
#include "spawn_in_base_call_handler.as"
#include "damaged_vehicle.as"
#include "pausing_koth_timer.as"
#include "airstrike_strafing_run.as"

#include "paratrooper_mode.as"
#include "spawn_at_node.as"

#include "uncapturable_last_base_end_timer.as"
#include "uncapturable_last_base_end_timer_sicily.as"
#include "uncapturable_last_base_end_timer_brecourt.as"

#include "boss_music.as"

#include "phase_controller_bastogne.as"
#include "phase_controller_arnhem.as"
#include "phase_controller_varsity.as"
#include "phase_controller_overlord_allies.as"

#include "run_at_interval.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfiguratorAllies : MyStageConfigurator {
	// ------------------------------------------------------------------------------------------------
	MyStageConfiguratorAllies(GameModeInvasion@ metagame, MyMapRotator@ mapRotator) {
		super(metagame, mapRotator);
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void addStage(Stage@ stage) {


		if (m_metagame.isInServerMode()) {
			stage.m_includeLayers.insertLast("layer_invasion.allies");
		} else {
			stage.m_includeLayers.insertLast("layer_campaign.allies");
		}
		MyStageConfigurator::addStage(stage);
	}

	// ------------------------------------------------------------------------------------------------
	protected void setupNormalStages() {
		addStage(setupStage1());
		addStage(setupStageOverlord());
		addStage(setupStage2());
		addStage(setupStage3());
		addStage(setupStage4());
		addStage(setupStage5());
		addStage(setupStage6());
		addStage(setupStageFinal());
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
	protected void prepareVisualTimer(MyStage@ stage) {
		// doesn't matter much what is set here as time, time is expected to be set by setVisualTimer at various phases
		stage.m_defenseWinTime = 60.0; 
		// "custom_ignore_end" -> match will not end when timer runs out
		stage.m_defenseWinTimeMode = "custom_ignore_end"; 
	}	
	
	// ------------------------------------------------------------------------------------------------
	protected void setupMapView(MyStage@ stage) {
		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("overlay_texture", "map_allies.png");
			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("type", "frame");
			command.setStringAttribute("overlay_texture", "mapview_card_allies.png");
			stage.m_extraCommands.insertLast(command);
		}
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage1() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Sicily";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss1";
		stage.m_mapInfo.m_id = "edelweiss1";
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies");    

		
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_para_no_parachuting.call ", "usf_para_no_parachuting_spawn.call", array<string> = {""}, true, "infantry"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));

						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"route_115_north"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"route_115_north"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
				
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"route_115_north"}, true, "vehicle"));
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		// required by UncapturableLastBaseEndTimer 
		//stage.m_useCustomTimerMode = true;
		//stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
		//  timer to win, enemy capacity offset (default is 20)  
		stage.addTracker(UncapturableLastBaseEndTimerSicily(m_metagame, 300.0, 5));	

		stage.addStartComment(Comment("map start with paradrop, part 1", 5.0));
		stage.addStartComment(Comment("map start with paradrop, part 2", 5.0));
		stage.addStartComment(Comment("map start with paradrop, part 3", 5.0));
		stage.addStartComment(Comment("map start with paradrop, part 4", 5.0));
		
		stage.m_maxSoldiers = 10 * 20;        // 200
		// stage.m_playerAiCompensation = 3.5;     // was 2.5 hotfix2
		// stage.m_playerAiReduction = 1;        // was 1.5 hotfix2
		stage.m_soldierCapacityVariance = 0.55;        
		
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.25, 0.15));
			f.m_overCapacity = 0;           
			// NOTE: this is the capacity offset after having captured the first base
			f.m_capacityOffset = 10; 
			f.m_capacityMultiplier = 0.75;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.8, 0.2));
			f.m_overCapacity = 90;		 
			f.m_capacityOffset = 10;      // NOTE: This is used in the UncapturableLastBase counter-attack as a boost to manpower as well (is slight ofc)
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
		
		prepareParatrooperMode(stage);
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		setupMapView(stage);

{
    array<string> positions = {
        "576 13 294", 
        "631 3 437", 
        "571 11 628", 
        "626 7 767",
        "741 16 631", 
        "840 11 911", 
        "785 6 319"
    };
    for (uint i = 0; i < positions.size(); ++i) {
        XmlElement command("command");
        command.setStringAttribute("class", "create_call");
        command.setStringAttribute("key", "usf_para_armoury_s.call");
        command.setStringAttribute("position", positions[i]);
        command.setIntAttribute("faction_id", 0);
        stage.m_extraCommands.insertLast(command);
    }
}
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage2() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Sainte-Marie-du-Mont";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss2";
		stage.m_mapInfo.m_id = "edelweiss2";
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies");     
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		// required by UncapturableLastBaseEndTimer 
		//stage.m_useCustomTimerMode = true;
		//stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
		//  timer to win, enemy capacity offset (default is 20); this offset is also added to the default offset below
		stage.addTracker(UncapturableLastBaseEndTimerBrecourt(m_metagame, 270.0, 10));	

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));

				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));

						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));


		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"hauchmail"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"hauchmail"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"hauchmail"}, true, "vehicle"));

		stage.addStartComment(Comment("map start with paradrop, part 1", 5.0));
		stage.addStartComment(Comment("map start with paradrop, part 2", 5.0));
		stage.addStartComment(Comment("map start with paradrop, part 3", 5.0));
		stage.addStartComment(Comment("map start with paradrop, part 4", 5.0));
		
		stage.m_maxSoldiers = 10 * 22;       // 220 
	//stage.m_playerAiCompensation = 2;    // was 2.5 (hotfix 2)
		//stage.m_playerAiReduction = 1;     // was 1.5 (hotfix2)
		stage.m_soldierCapacityVariance = 0.5;     

		stage.addTracker(Spawner(m_metagame, 1, Vector3(450,5,788), 10, "regular"));       // St-Marie filler
		stage.addTracker(Spawner(m_metagame, 1, Vector3(450,5,788), 2, "veteran"));       // St-Marie filler		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.3, 0.15));    
			f.m_overCapacity = 15;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 0.8;	          // was 0.75
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.72, 0.22));       
			f.m_overCapacity = 22;          
			f.m_capacityOffset = 10;       // NOTE: This is used in the UncapturableLastBase counter-attack as a boost to manpower as well as the above
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
		
		prepareParatrooperMode(stage);
		
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
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies");
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"castle"}, true, "vehicle"));
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
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		m_metagame.getComms().send("<command class='create_call' key='usf_vehicle_m4_sherman.call' position='528 3.5 798' faction_id='0' />");
// 定时为盟军生成坦克
{
    XmlElement cmd1("command");
    cmd1.setStringAttribute("class", "create_instance");
    cmd1.setStringAttribute("instance_key", "m4_75.vehicle");
    cmd1.setStringAttribute("position", "528 3.5 798");
    cmd1.setIntAttribute("instances", 1);
    cmd1.setStringAttribute("instance_class", "vehicle");
    cmd1.setIntAttribute("faction_id", 0);
    stage.addTracker(RunAtInterval(m_metagame, cmd1, 300));
}
{
    XmlElement cmd2("command");
    cmd2.setStringAttribute("class", "create_instance");
    cmd2.setStringAttribute("instance_key", "m10.vehicle");
    cmd2.setStringAttribute("position", "476 5 755");
    cmd2.setIntAttribute("instances", 1);
    cmd2.setStringAttribute("instance_class", "vehicle");
    cmd2.setIntAttribute("faction_id", 0);
    stage.addTracker(RunAtInterval(m_metagame, cmd2, 240));
}
{
    XmlElement cmd3("command");
    cmd3.setStringAttribute("class", "create_instance");
    cmd3.setStringAttribute("instance_key", "m4_75.vehicle");  
    cmd3.setStringAttribute("position", "487 5 766");
    cmd3.setIntAttribute("instances", 1);
    cmd3.setStringAttribute("instance_class", "vehicle");
    cmd3.setIntAttribute("faction_id", 0);
    stage.addTracker(RunAtInterval(m_metagame, cmd3, 180));
}

		//stage.addStartComment(Comment("Overlord Allies, part 1", 5.0));
		//stage.addStartComment(Comment("Overlord Allies, part 2", 5.0));
		//stage.addStartComment(Comment("Overlord Allies, part 3", 5.0));
		stage.addStartComment(Comment("highway intro, part 1", 3.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 5", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 6", 5.0));

		stage.m_maxSoldiers = 13 * 17; 
		//stage.m_playerAiCompensation = 3;
		//stage.m_playerAiReduction = 1.5;
		stage.m_soldierCapacityVariance = 0.4;
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
	enemySpawnCompensationFactor *= 0.5f;
	
		stage.setPhaseController(PhaseControllerOverlord_Allies(m_metagame, enemySpawnCompensationFactor));
		stage.m_useCustomTimerMode = true;

		stage.m_defenseWinTime = 60; 
		stage.m_defenseWinTimeMode = "custom";

		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.07, 0.2));  
			f.m_overCapacity = 0;       
			f.m_capacityOffset = 30;      
			f.m_capacityMultiplier = 0.88;  
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.77, 0.2)); 
			f.m_overCapacity = 80;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 1.2;
			stage.m_factions.insertLast(f);
		}
		
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

		prepareParatrooperModeOverlord(stage);
		setupMapView(stage);
        		
		return stage;
	}

	protected void prepareParatrooperModeOverlord(MyStage@ stage) {
		array<ScoredResource@> resources = {
			ScoredResource("parachute.vehicle", "vehicle", 1.0f)
		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "parachute", 0, 10000));
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
	protected Stage@ setupStage3() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Hill 262";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss3";
		stage.m_mapInfo.m_id = "edelweiss3";
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies");  
        
		stage.m_fogOffset = 20.0;    
		stage.m_fogRange = 50.0;            
		
		//stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(Overtime(m_metagame, 0));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));


				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"point_262"}, true, "vehicle"));

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
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {"point_262"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {"point_262"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"point_262"}, true, "vehicle"));


		stage.addStartComment(Comment("hill 262, part 1", 5.0));
		stage.addStartComment(Comment("hill 262, part 2", 5.0));
		stage.addStartComment(Comment("hill 262, part 3", 5.0));
		stage.addStartComment(Comment("hill 262, part 4", 5.0));
		
		stage.m_maxSoldiers = 6 * 35;       // 210
		//stage.m_playerAiCompensation = 2.5;   // was 4 
		//stage.m_playerAiReduction = 1;    // was 1.5
		stage.m_soldierCapacityModel = "constant";
		
		stage.m_defenseWinTime = 720.0;
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.3, 0.1));
			f.m_capacityOffset = 10;                                             
			f.m_capacityMultiplier = 0.85;											
			f.m_overCapacity = 0;                                                 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.3, 0.1));
			f.m_capacityOffset = 80;           
			f.m_capacityMultiplier = 0.00001;   
			f.m_overCapacity = 40;            
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
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies"); 
        stage.m_includeLayers.insertLast("offroad.allies");    

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));

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
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addStartComment(Comment("highway intro, part 1", 5.0));
		stage.addStartComment(Comment("highway intro, part 2", 5.0));
		stage.addStartComment(Comment("highway intro, part 3", 5.0));
		stage.addStartComment(Comment("highway intro, part 4", 5.0));
		stage.addStartComment(Comment("highway intro, part 5", 5.0));
		
		stage.m_maxSoldiers = 10 * 20;    // 200 (was 190 hotfix2) 
		//stage.m_playerAiCompensation = 3;   // was 3.5 (hotfix2)
		//stage.m_playerAiReduction = 1;    // was 2 (hotfix2)
		stage.m_soldierCapacityVariance = 0.5;    
        
		stage.addTracker(Spawner(m_metagame, 1, Vector3(641,5,1144), 10, "regular"));       // pak40 filler 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(641,5,1144), 2, "veteran"));       // pak40 filler        
		
		{
			XmlElement command("command");
			command.setStringAttribute("class", "create_call");
			command.setStringAttribute("key", "ukf_inf.call");
			command.setStringAttribute("position", "489 4 1473");
			command.setIntAttribute("faction_id", 0);
			stage.addTracker(RunAtInterval(m_metagame, command, 90.0));	
		}
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.25, 0.1));
			f.m_overCapacity = 0; 
			f.m_capacityOffset = 15;  // was 10 (hotfix2)
			f.m_capacityMultiplier = 0.75;   // was 0.725 (hotfix2)
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.4, 0.15));   // was 0.4 0.3
			f.m_overCapacity = 40;
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
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 200); // default value is 4, but making sure absolutely no back caps are attempted aside from lonewolves
			command.setFloatAttribute("side_base_attack_probability", 0.0);				// default value is 0.05, reasoning above
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}		

		setupMapView(stage);

		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage5() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Arnhem";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss5";
		stage.m_mapInfo.m_id = "edelweiss5";
		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies");     

		//stage.addTracker(PeacefulLastBase(m_metagame, 0));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un.call", "ukf_vehicle_un_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_un_b.call", "ukf_vehicle_un_b_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_unk.call", "ukf_vehicle_unk_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));
		
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {""}, true, "vehicle"));


		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {""}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_m4_sherman_v.call", "ukf_vehicle_m4_sherman_v_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_sherman_firefly.call", "ukf_vehicle_sherman_firefly_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_vehicle_churchill.call", "ukf_vehicle_churchill_spawn.call", array<string> = {"point_262"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_para_no_parachuting.call", "ukf_para_no_parachuting_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ukf_para_no_parachuting_ai.call", "ukf_para_no_parachuting_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {""}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {""}, true, "vehicle"));

		//stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		//stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		//stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		//stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_maxSoldiers = 13 * 15;    // 195
		//stage.m_playerAiCompensation = 2;   // was 4
		//stage.m_playerAiReduction = 1;   // was 1.5
		stage.m_soldierCapacityVariance = 0.5;     
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
	enemySpawnCompensationFactor *= 0.5f;
	
		stage.setPhaseController(PhaseControllerArnhem(m_metagame, enemySpawnCompensationFactor));
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.2, 0.1)); 
			f.m_overCapacity = 0;
			f.m_capacityOffset = 10;  
			f.m_capacityMultiplier = 0.8;      
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.45, 0.4));
			f.m_overCapacity = 50;
			f.m_capacityOffset = 0;
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "phases";
		
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
		
		prepareVisualTimer(stage);
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

		stage.m_includeLayers.insertLast("bases.allies"); 
		stage.m_includeLayers.insertLast("layer.allies");    
						stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle")); 
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
    stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
		//stage.addTracker(PeacefulLastBase(m_metagame, 0));
	stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"foy_north"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"foy_north"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));


		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"foy_north"}, true, "vehicle"));

		stage.addTracker(BossMusic(m_metagame, "mus_boss_battle_bastogne.wav", "king_tiger_boss.vehicle", 23.0, 170.0, 10.0, 1.5));	//volume was 5.0, last parameter - distance was 150, 2nd parameter
		
		//stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		//stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		//stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		//stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_soldierCapacityVariance = 0.4;  
		stage.m_maxSoldiers = 10 * 14;      // 140 
		//stage.m_playerAiCompensation = 2;    // was 3
		//stage.m_playerAiReduction = 1;       // was 2
		
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
	enemySpawnCompensationFactor *= 0.5f;
	
		stage.setPhaseController(PhaseControllerBastogne(m_metagame, enemySpawnCompensationFactor));
		
		
		// set all defend initially, the phases will control it once things start moving
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 1.0, 0.0));
			f.m_capacityMultiplier = 0.85; 
			f.m_capacityOffset = 20;             
			stage.m_factions.insertLast(f);
		}
		{
			// in adventure mode, this faction config will be replaced with the correct one when final battle 1 opponent is decided 
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 1.0, 0.0));
			f.m_capacityMultiplier = 1.5;  
			f.m_overCapacity = 50;             
			f.m_loseWithoutBases = true;
			stage.m_factions.insertLast(f); 
		}
		
		// metadata
		stage.m_primaryObjective = "phases";
		
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

		prepareVisualTimer(stage);
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
		stage.m_mapInfo.m_name = "Operation Varsity";
		stage.m_mapInfo.m_path = "media/packages/edelweiss/maps/edelweiss7";
		stage.m_mapInfo.m_id = "edelweiss7";
		stage.m_includeLayers.insertLast("bases.allies");
		stage.m_includeLayers.insertLast("layer.allies");     
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_pak40.call", "wh_vehicle_sdkfz251_pak40_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_mortar.call", "wh_vehicle_sdkfz251_mortar_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251_flak.call", "wh_vehicle_sdkfz251_flak_spawn.call", array<string> = {""}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		
	stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"castle"}, true, "vehicle"));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle.call", "usf_vehicle_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle1.call", "usf_vehicle1_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting.call", "usf_para_no_parachuting_spawn.call", array<string> = {"castle"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_para_no_parachuting_ai.call", "usf_para_no_parachuting_spawn_ai.call", array<string> = {"castle"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m10.call", "usf_vehicle_m10_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"castle"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_luchs.call", "wh_vehicle_luchs_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_stuart.call", "usf_vehicle_stuart_spawn.call", array<string> = {"castle"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman_76.call", "usf_vehicle_m4_sherman_76_spawn.call", array<string> = {"castle"}, true, "vehicle"));

		stage.addStartComment(Comment("varsity, part 1", 5.0));
		stage.addStartComment(Comment("varsity, part 2", 5.0));
		stage.addStartComment(Comment("varsity, part 3", 5.0));
		stage.addStartComment(Comment("varsity, part 4", 5.0));
		stage.addStartComment(Comment("varsity, part 5", 5.0));
		stage.addStartComment(Comment("varsity, part 6", 5.0));
		stage.addStartComment(Comment("varsity, part 7", 5.0));
		stage.addStartComment(Comment("varsity, part 8", 5.0));
		
		stage.m_maxSoldiers = 13 * 17;          // 221 units. capacity mult = half of max soldiers * capacity mult; so 130 * 0.5 = 65      // was 10 * 17
		//stage.m_playerAiCompensation = 3; // was 2.5 (hotfix2)
		//stage.m_playerAiReduction = 1.5; // was 2
		stage.m_soldierCapacityVariance = 0.4;  // was 0.35
    	
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
	enemySpawnCompensationFactor *= 0.5f;
	
		stage.setPhaseController(PhaseControllerVarsity(m_metagame, enemySpawnCompensationFactor));
		
		stage.addTracker(BossMusic(m_metagame, "mus_boss_battle_varsity.wav", "maus_boss.vehicle", 19.0, 180.0, 10.0, 1.5));	//volume was 5.0, last parameter - distance was 160, 2nd parameter		
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.2, 0.4));  
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
		    // Sicily -> Overlord
			addTransport("edelweiss1", "hitbox_extraction2_1", "edelweiss11");
			// Overlord -> Sainte-Marie-du-Mont
	 		 addTransport("edelweiss11", "hitbox_extraction3", "edelweiss2");


		//addTransport("edelweiss1", "hitbox_extraction2_1", "edelweiss2");
		
	    addTransport("edelweiss2", "hitbox_extraction3", "edelweiss3");
	    //addTransport("edelweiss2", "hitbox_extraction11", "edelweiss11");

	    //addTransport("edelweiss11", "hitbox_extraction3", "edelweiss3");
		
	    //addTransport("edelweiss3", "hitbox_extraction2_1", "edelweiss2");
		addTransport("edelweiss3", "hitbox_extraction4", "edelweiss4");
		
	    //addTransport("edelweiss4", "hitbox_extraction3_1", "edelweiss3");
	    addTransport("edelweiss4", "hitbox_extraction5_1", "edelweiss5");
		
	    //addTransport("edelweiss5", "hitbox_extraction4_1", "edelweiss4");
	    addTransport("edelweiss5", "hitbox_extraction6", "edelweiss6");
		
	    //addTransport("edelweiss6", "hitbox_extraction5_1", "edelweiss5");
	    addTransport("edelweiss6", "hitbox_extraction7_1", "edelweiss7");
	}
	
	// --------------------------------------------
	protected void setupStartingMaps() {
		m_myMapRotator.addStartingMap("edelweiss1");
		//m_myMapRotator.addStartingMap("edelweiss6");
		//m_myMapRotator.addStartingMap("edelweiss7");

	}
}
