#include "my_stage_configurator.as"
#include "spawn_in_base_call_handler.as"
#include "damaged_vehicle.as"
#include "uncapturable_last_base_end_timer.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfiguratorIJA : MyStageConfigurator {
	// ------------------------------------------------------------------------------------------------
	MyStageConfiguratorIJA(GameModeInvasion@ metagame, MyMapRotator@ mapRotator) {
		super(metagame, mapRotator);
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void setupNormalStages() {
		addStage(setupStage11());
		addStage(setupStage12());
		addStage(setupStage21());
		addStage(setupStage22());
		addStage(setupStage23());
		addStage(setupStage31());
		addStage(setupStage32());
		addStage(setupStage33());    
		addStage(setupStageFinal());
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void setupMapView(MyStage@ stage) {
        {
            XmlElement command("command");
            command.setStringAttribute("class", "update_map_view");
            command.setStringAttribute("overlay_texture", "map.png");
            stage.m_extraCommands.insertLast(command);
        }
		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("type", "frame");
			command.setStringAttribute("overlay_texture", "mapview_card_ija.png");
			stage.m_extraCommands.insertLast(command);
		}
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage11() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Guadalcanal";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island1";
		stage.m_mapInfo.m_id = "island1";
		stage.m_includeLayers.insertLast("bases.ija"); 
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));

				stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Outpost"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Outpost"}, true, "infantry"));		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Outpost"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Air Strip"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Air Strip"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Air Strip"}, true, "infantry"));		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Air Strip"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Air Strip"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Air Strip"}, true, "vehicle"));   		
		
		stage.addStartComment(Comment("guadalcanal, part 1", 5.0));
		stage.addStartComment(Comment("guadalcanal, part 2", 5.0));
		stage.addStartComment(Comment("guadalcanal, part 3", 5.0));
		stage.addStartComment(Comment("guadalcanal, part 4", 5.0));
		
		stage.m_maxSoldiers = 7 * 18;        // 126 units
	// 	stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2;  
		stage.m_soldierCapacityVariance = 0.55;
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.2, 0.1));
			f.m_overCapacity = 0;      
			f.m_capacityOffset = 5;  // was 0 
      f.m_capacityMultiplier = 0.85;         // was 0.8
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.69, 0.24));
			f.m_overCapacity = 30;
      f.m_capacityOffset = 5;      
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
        
		setupMapView(stage);
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage12() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Russell Islands";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island2";
		stage.m_mapInfo.m_id = "island2";
		stage.m_includeLayers.insertLast("bases.ija"); 
		stage.m_includeLayers.insertLast("layer.ija");     
		
		// required by UncapturableLastBaseEndTimer 
		stage.m_useCustomTimerMode = true;
		stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
//  timer to win, enemy capacity offset (default is 20)  
    stage.addTracker(UncapturableLastBaseEndTimer(m_metagame, 300.0, 20));	
	stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));    
		
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_maxSoldiers = 9 * 15;       // 135 units
	// 	stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2; 
		stage.m_soldierCapacityVariance = 0.55;

    stage.addTracker(Spawner(m_metagame, 1, Vector3(736,15,346), 15, "regular"));        // prison hatch protector filler
    stage.addTracker(Spawner(m_metagame, 1, Vector3(337,15,812), 15, "regular"));        // first base filler to avoid rush   
    stage.addTracker(Spawner(m_metagame, 1, Vector3(336,15,850), 10, "regular"));        // sub protectors       
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.2));
			f.m_overCapacity = 0;
			f.m_capacityOffset = 5;  // was 0 
			f.m_capacityMultiplier = 0.85;         // was 0.8
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
      Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.5, 0.25));
			f.m_overCapacity = 50;
			f.m_capacityOffset = 10;
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}    
        
		setupMapView(stage);
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage21() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Bougainville Island";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island3";
		stage.m_mapInfo.m_id = "island3";
		stage.m_includeLayers.insertLast("bases.ija");
    stage.m_includeLayers.insertLast("layer.ija");  //carrier southern of the island
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));

		stage.m_useCustomTimerMode = true;
		stage.m_defenseWinTime = 300.0; 
    stage.addTracker(UncapturableLastBaseEndTimer(m_metagame, 300.0, 40));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));

	stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));    		
		
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_maxSoldiers = 9 * 13;    // 117 units
	// 	stage.m_playerAiCompensation = 2;
    // stage.m_playerAiReduction = 2; 
		stage.m_soldierCapacityVariance = 0.7;
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.2, 0.15));
			f.m_overCapacity = 0;
			f.m_capacityOffset = 8;               // was 5
			f.m_capacityMultiplier = 0.9;         // was 0.85
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.4, 0.45));
			f.m_overCapacity = 40;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       

		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("overlay_texture", "map_ija.png");
			stage.m_extraCommands.insertLast(command);
		}
		{
            XmlElement command("command");
            command.setStringAttribute("class", "update_map_view");
            command.setStringAttribute("type", "frame");
            command.setStringAttribute("overlay_texture", "mapview_card_ija.png");
            stage.m_extraCommands.insertLast(command);
        }
        
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage22() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Tarawa";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island4";
		stage.m_mapInfo.m_id = "island4";
		stage.m_includeLayers.insertLast("bases.ija"); 
		stage.m_includeLayers.insertLast("layer.ija");    

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		// required by UncapturableLastBaseEndTimer 
		stage.m_useCustomTimerMode = true;
		stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
		stage.addTracker(UncapturableLastBaseEndTimer(m_metagame, 300.0, 30));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    		

		stage.addTracker(DamagedVehicle(m_metagame, "stuart_damaged.vehicle", 0.6));
		stage.addTracker(DamagedVehicle(m_metagame, "hago_damaged.vehicle", 0.6));
		
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_maxSoldiers = 9 * 15;    // 135 units
	// 	stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2;    
    stage.m_soldierCapacityVariance = 0.70;  
    
    stage.addTracker(Spawner(m_metagame, 1, Vector3(336,15,850), 10, "regular"));        // boat occupy         
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.3, 0.2));
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 5;  // was 0 
			f.m_capacityMultiplier = 0.85;         // was 0.8
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.4, 0.3));
      f.m_overCapacity = 50;
      f.m_capacityOffset = 0;
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       
        
		setupMapView(stage);
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage23() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Wake Island";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island9";
		stage.m_mapInfo.m_id = "island9";
		stage.m_includeLayers.insertLast("bases.ija"); 
		stage.m_includeLayers.insertLast("layer.ija");     
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(Overtime(m_metagame, 0));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));      
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));  
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));      
		
		stage.m_maxSoldiers = 21 * 5;     // was 33 * 3 in 1.65
		// stage.m_playerAiCompensation = 5;                                         // was 4 (1.81) was 5 (1.86)
		// stage.m_playerAiReduction = 2;                                            // was 2 (1.81) was 2.5 (1.86)  
		stage.m_soldierCapacityModel = "constant";
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(267,15,373), 10, "regular")); // jammer filler  
		stage.addTracker(Spawner(m_metagame, 1, Vector3(313,15,418), 10, "regular")); // pillbox filler  
		stage.addTracker(Spawner(m_metagame, 1, Vector3(316,15,375), 5, "regular")); // back filler  
		
		stage.m_defenseWinTime = 720.0;   // was 600 in 1.65
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
		
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.3, 0.1));      // was  0.1 0.1 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.25, 0.05));             // was 0.2 0.1 in 1.65
			f.m_overCapacity = 25;
			f.m_capacityMultiplier = 0.0001;                                                      // was 1.32 in 1.65, now working with offset only
			f.m_capacityOffset = 50;
			stage.m_factions.insertLast(f);
		}
		{
			// neutral
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "Airfield";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       

		{
			XmlElement command("command");
			command.setStringAttribute("class", "update_map_view");
			command.setStringAttribute("overlay_texture", "map_ija.png");
			stage.m_extraCommands.insertLast(command);
		}
		{
            XmlElement command("command");
            command.setStringAttribute("class", "update_map_view");
            command.setStringAttribute("type", "frame");
            command.setStringAttribute("overlay_texture", "mapview_card_ija.png");
            stage.m_extraCommands.insertLast(command);
        }
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage31() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Saipan";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island5";
		stage.m_mapInfo.m_id = "island5";
		stage.m_includeLayers.insertLast("bases.ija"); 
		stage.m_includeLayers.insertLast("layer.ija");    

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
		// required by UncapturableLastBaseEndTimer 
		stage.m_useCustomTimerMode = true;
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
		stage.addTracker(UncapturableLastBaseEndTimer(m_metagame, 300.0, 30));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    		
		
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_maxSoldiers = 6 * 17;    // 102 units
	// 	stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2; 
		stage.m_soldierCapacityVariance = 0.55;      
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.1, 0.1));
			f.m_overCapacity = 0;
			f.m_capacityOffset = 5;           // was 0
			f.m_capacityMultiplier = 1.0;      
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
		stage.m_primaryObjective = "capture";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       
        
		setupMapView(stage);
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage32() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Iwo Jima";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island6";
		stage.m_mapInfo.m_id = "island6";

    stage.m_fogOffset = 20.0;    
    stage.m_fogRange = 50.0;    

		stage.m_includeLayers.insertLast("bases.ija");
		stage.m_includeLayers.insertLast("layer.ija");     
    
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
		// required by UncapturableLastBaseEndTimer 
		stage.m_useCustomTimerMode = true;
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
		stage.addTracker(UncapturableLastBaseEndTimer(m_metagame, 300.0, 30));    
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));


		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    	
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));      
	
	
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
    stage.m_maxSoldiers = 11 * 16;       // 176 units
	// 	stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2; 
		stage.m_soldierCapacityVariance = 0.50;      
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.25, 0.1));
		  f.m_overCapacity = 0;
			f.m_capacityOffset = 5;  // was 0 
			f.m_capacityMultiplier = 0.85;         // was 0.8
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.45, 0.35));
      f.m_overCapacity = 50;
			f.m_capacityOffset = 15;
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       
        
		setupMapView(stage);
		
		return stage;
	}
	
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage33() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Peleliu Airfield";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island8";
		stage.m_mapInfo.m_id = "island8";

		//stage.m_fogOffset = 20.0;    
		//stage.m_fogRange = 50.0;    

		stage.m_includeLayers.insertLast("bases.ija");
		stage.m_includeLayers.insertLast("layer.ija");     
    

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		// required by UncapturableLastBaseEndTimer 
		stage.m_useCustomTimerMode = true;
		stage.m_defenseWinTime = 300.0; // any positive value is ok, UncapturableLastBaseEndTimer will handle
		stage.addTracker(UncapturableLastBaseEndTimer(m_metagame, 300.0, 40));            // ..30

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Attack Ship"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Attack Ship"}, true, "vehicle"));   
		
		
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 4", 5.0));
		
		stage.m_maxSoldiers = 13 * 17;       // 221 units. was 13 bases * 15 soldiers prior to 1.86
	// 	stage.m_playerAiCompensation = 3;    // 
		// stage.m_playerAiReduction = 2.4;		   // 
		
		stage.m_soldierCapacityVariance = 0.6;		      // 0.8
    
//    stage.addTracker(Spawner(m_metagame, 1, Vector3(749,15,185), 15));        // Headquarter base filler       
		stage.addTracker(Spawner(m_metagame, 1, Vector3(589,5,161), 30, "regular"));        // Barracks base filler
		stage.addTracker(Spawner(m_metagame, 1, Vector3(884,5,369), 20, "regular"));        // Airfield base filler
    
		{				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.2));
			f.m_capacityOffset = 5;  // was 0
			f.m_capacityMultiplier = 0.85;         // was 0.8
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.55, 0.35));                //  0.55, 0.35
			f.m_overCapacity = 70;            // 100
			f.m_capacityOffset = 0;           
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       
        
		setupMapView(stage);
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------------
	// FINAL STAGES
	// ------------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------------
	
	protected Stage@ setupStageFinal() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.setPhaseController(PhaseControllerIsland7(m_metagame));
		stage.m_mapInfo.m_name = "Downfall";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island7";
		stage.m_mapInfo.m_id = "island7";
		stage.m_hidden = true;
		stage.m_includeLayers.insertLast("bases.campaign");
		stage.m_includeLayers.insertLast("layer.ija");      
		

stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));
		
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));

		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));



		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {}, true, "infantry"));
		// we want the enemy to be able to call vehicle reinforcements into their city, not the allies though
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));    
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"the_armory","submarine_pens","warehouses","the_heights"}, true, "vehicle"));    
	

		stage.addTracker(DamagedVehicle(m_metagame, "stuart_damaged.vehicle", 0.6));
		stage.addTracker(DamagedVehicle(m_metagame, "hago_damaged.vehicle", 0.6));
		
		stage.addStartComment(Comment("final map, part 1", 5.0));
		stage.addStartComment(Comment("final map, part 2", 5.0));
		stage.addStartComment(Comment("final map, part 3", 5.0));
		stage.addStartComment(Comment("final map, part 4", 5.0));
		stage.addStartComment(Comment("final map, part 5", 5.0));
		stage.addStartComment(Comment("final map, part 6", 5.0));
		stage.addStartComment(Comment("final map, part 7", 5.0));
		
    stage.m_maxSoldiers = 15 * 16;          // 240 units. was 15 bases * 13 soldiers prior to 1.86
	// 	stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2; 
		stage.m_soldierCapacityVariance = 0.7;  // was 0.8 in 1.72 
    
    stage.addTracker(Spawner(m_metagame, 1, Vector3(328,15,724), 20, "regular"));        // rush avoidance           
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.18));    // was 0.35, 0.2 in 1.72
			f.m_overCapacity = 0;
			f.m_capacityOffset = 10;           
			f.m_capacityMultiplier = 0.9;         // was 0.85
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.55, 0.35));  
			f.m_overCapacity = 110;        // was 100 in 1.72
			f.m_capacityOffset = 5;          // was 10 in 1.72
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		
		// metadata
		// changed m_primaryObjective from "capture" to "phases" to not use intel manager 
		// - doesn't make sense as there are no markers for if a base is capturable or not
		stage.m_primaryObjective = "phases";
		
		stage.m_hidden = true;
    
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}       
        
		setupMapView(stage);
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	void setupStageUnlockRules() {
		{
			// completing island1 opens island2
			StageUnlockRule rule(
				array<string> = {"island1"},
				array<string> = {"island2"});
			m_myMapRotator.addStageUnlockRule(rule);
		}
		{
			// completing island2 opens island3, island4, and island9
			StageUnlockRule rule(
				array<string> = {"island2"},
				array<string> = {"island3","island4","island9"});
			m_myMapRotator.addStageUnlockRule(rule);
		}
		{
			// completing island3, island4, and island9 opens island5, island6, and island8
			StageUnlockRule rule(
				array<string> = {"island3","island4","island9"},
				array<string> = {"island5","island6","island8"});
			m_myMapRotator.addStageUnlockRule(rule);
		}
		{
			// completing island5, island6, and island8 opens island7 
			StageUnlockRule rule(
				array<string> = {"island5","island6","island8"},
				array<string> = {"island7"});
			m_myMapRotator.addStageUnlockRule(rule);
		}
	}
	
	// --------------------------------------------
	protected void setupTransports() {
		addTransport("island1", "hitbox_extraction2", "island2");
		
	    addTransport("island2", "hitbox_extraction1_ija", "island1");
	    addTransport("island2", "hitbox_extraction3", "island3");
	    addTransport("island2", "hitbox_extraction4", "island4");
		addTransport("island2", "hitbox_extraction9", "island9");
		
	    addTransport("island3", "hitbox_extraction2_ija", "island2");
		addTransport("island3", "hitbox_extraction4_ija", "island4");
		addTransport("island3", "hitbox_extraction5", "island5");
		addTransport("island3", "hitbox_extraction6", "island6");
		addTransport("island3", "hitbox_extraction8", "island8");
		addTransport("island3", "hitbox_extraction9_ija", "island9");
		
	    addTransport("island4", "hitbox_extraction2_ija", "island2");
	    addTransport("island4", "hitbox_extraction3_ija", "island3");
	    addTransport("island4", "hitbox_extraction5", "island5");
	    addTransport("island4", "hitbox_extraction6", "island6");
	    addTransport("island4", "hitbox_extraction8", "island8");
		addTransport("island4", "hitbox_extraction9", "island9");
		
		addTransport("island9", "hitbox_extraction2_ija", "island2");
		addTransport("island9", "hitbox_extraction3_ija", "island3");
		addTransport("island9", "hitbox_extraction4_ija", "island4");
		addTransport("island9", "hitbox_extraction5", "island5");
		addTransport("island9", "hitbox_extraction6", "island6");
	    addTransport("island9", "hitbox_extraction8", "island8");
		
	    addTransport("island5", "hitbox_extraction3_ija", "island3");
	    addTransport("island5", "hitbox_extraction4_ija", "island4");
	    addTransport("island5", "hitbox_extraction8_ija", "island8");
	    addTransport("island5", "hitbox_extraction6", "island6");
	    addTransport("island5", "hitbox_extraction7", "island7");
		addTransport("island5", "hitbox_extraction9", "island9");
		
	    addTransport("island6", "hitbox_extraction3_ija", "island3");
	    addTransport("island6", "hitbox_extraction4_ija", "island4");
	    addTransport("island6", "hitbox_extraction5_ija", "island5");
	    addTransport("island6", "hitbox_extraction8_ija", "island8");
	    addTransport("island6", "hitbox_extraction7", "island7");
		addTransport("island6", "hitbox_extraction9", "island9");
		
		addTransport("island8", "hitbox_extraction3_ija", "island3");
		addTransport("island8", "hitbox_extraction4_ija", "island4");
		addTransport("island8", "hitbox_extraction5_ija", "island5");
	    addTransport("island8", "hitbox_extraction6_ija", "island6");
		addTransport("island8", "hitbox_extraction7", "island7");
		addTransport("island8", "hitbox_extraction9_ija", "island9");
		
	    addTransport("island7", "hitbox_extraction5", "island5");
	    addTransport("island7", "hitbox_extraction6", "island6");
	}
	
	// --------------------------------------------
	protected void setupStartingMaps() {
		m_myMapRotator.addStartingMap("island1");
	}
}
