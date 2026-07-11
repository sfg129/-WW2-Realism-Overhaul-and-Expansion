#include "my_stage_configurator_usmc.as"


// ------------------------------------------------------------------------------------------------
class MyStageConfiguratorUSMCInvasion : MyStageConfiguratorUSMC {
	// ------------------------------------------------------------------------------------------------
	MyStageConfiguratorUSMCInvasion(GameModeInvasion@ metagame, MyMapRotator@ mapRotator) {
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
		addStage(setupStageElk());
		addStage(setupStageFinal());
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStageElk() {
		MyStage@ stage = createStage();
		stage.m_mapInfo.m_name = "Elk Island";
		stage.m_mapInfo.m_path = "media/packages/pacific/maps/island10";
		stage.m_mapInfo.m_id = "island10";
		stage.m_includeLayers.insertLast("bases.usmc"); 
		stage.m_includeLayers.insertLast("layer.usmc");     
		
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
					stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m4_e4.call", "vehicle_m4_e4_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_stuart_recce.call", "vehicle_stuart_recce_spawn.call", array<string> = {"Carrie"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "vehicle_m3_mortar.call", "vehicle_m3_mortar_spawn.call", array<string> = {"Carrie"}, true, "vehicle"));

		stage.addTracker(Overtime(m_metagame, 0));
				stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m3_halftrack.call", "usf_vehicle_m3_halftrack_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));


		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf.call", "usmc_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_inf_ai.call", "usmc_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_armoury_marine.call", "usf_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle.call", "usmc_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usmc_vehicle1.call", "usmc_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "usf_vehicle_m4_sherman.call", "usf_vehicle_m4_sherman_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf.call", "ija_inf_spawn.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_inf_ai.call", "ija_inf_spawn_ai.call", array<string> = {"Carrier"}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_armoury_marine.call", "ija_vehicle_armoury_marine_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle.call", "ija_vehicle_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle1.call", "ija_vehicle1_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));      
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle2.call", "ija_vehicle2_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));      
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "ija_vehicle_medium_tank_chi_ha.call", "ija_vehicle_medium_tank_chi_ha_spawn.call", array<string> = {"Carrier"}, true, "vehicle"));      
		
		
		stage.addTracker(DamagedVehicle(m_metagame, "stuart_damaged.vehicle", 0.6));
		stage.addTracker(DamagedVehicle(m_metagame, "hago_damaged.vehicle", 0.6));
		stage.addStartComment(Comment("map start with 1 base, part 1", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 2", 5.0));
		stage.addStartComment(Comment("map start with 1 base, part 3", 5.0));
		
		stage.m_maxSoldiers = 12 * 17;     // 194 units
		stage.m_playerAiCompensation = 3;
    // stage.m_playerAiReduction = 2;
		stage.m_soldierCapacityVariance = 0.5;
		
		    stage.addTracker(Spawner(m_metagame, 1, Vector3(767,15,675), 8, "regular"));        // Eastern pillbox filler   
		    stage.addTracker(Spawner(m_metagame, 1, Vector3(736,15,714), 8, "regular"));        // Western pillbox filler  
		    stage.addTracker(Spawner(m_metagame, 1, Vector3(724,15,689), 8, "regular"));        // AA filler 
		    stage.addTracker(Spawner(m_metagame, 1, Vector3(724,15,689), 1, "veteran"));        // AA filler       
			
			
		
		{				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.2));
			f.m_capacityOffset = 0;
			f.m_capacityMultiplier = 0.85;       
			f.m_bases = 1;
			f.m_overCapacity = 5;				
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.53, 0.23));
			f.m_overCapacity = 80;
			f.m_capacityOffset = 20;
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
}
