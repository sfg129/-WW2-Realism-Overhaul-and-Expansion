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
#include "phase_controller_swan.as"
#include "phase_controller_sealion.as"

#include "run_at_interval.as"

#include "run_at_start.as"

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
		addStage(setupStageUndead1());
		addStage(setupStageUndead2());
		addStage(setupStageUndead3());
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void prepareParatrooperMode(MyStage@ stage) {         
		array<ScoredResource@> resources = {
			ScoredResource("parachute.vehicle", "vehicle", 1.0f)
		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "parachute", 0, 10000 /* high count to ensure all nodes are used */));

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
		{
			// specific settings for enemy faction
			Faction@ f = stage.m_factions[2];
			// disable general game rule to win when owning all bases
			f.m_winWithAllBases = false;
		}		
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
	
	protected Stage@ setupStageUndead1() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Untoten: Varsity";
		stage.m_mapInfo.m_path = "media/packages/ww2_undead/maps/edelweiss7_undead";
		stage.m_mapInfo.m_id = "edelweiss7_undead";
		stage.m_includeLayers.insertLast("bases.allies");
		stage.m_includeLayers.insertLast("layer.allies");     
		
		//stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));

		stage.addStartComment(Comment("undead varsity intro pt 1", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 2", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 3", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 4", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 5", 5.0));
		
		stage.m_maxSoldiers = 370;			//was 390
		stage.m_playerAiCompensation = 3;	//was 4
		stage.m_playerAiReduction = 0;		//was 0
		stage.m_soldierCapacityVariance = 0;  // was 0.35
    	
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
		enemySpawnCompensationFactor *= 0.5f; // adjust this to control how many extra soldiers are spawned in each scripted spawn, as a portion of compensation factor
		stage.setPhaseController(PhaseControllerVarsity(m_metagame, enemySpawnCompensationFactor));
		
		//stage.addTracker(BossMusic(m_metagame, "mus_boss_battle_varsity.wav", "maus_boss.vehicle", 19.0, 180.0, 10.0, 1.5));	//volume was 5.0, last parameter - distance was 160, 2nd parameter		
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.0));
			f.m_overCapacity = 0;       
			f.m_capacityOffset = 0;      
			f.m_capacityMultiplier = 0.01;
			f.m_bases = 1;
			f.m_loseWithoutBases = false;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.6, 0.0)); 
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 0.7;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.9, 0.0));
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 1.75;
			stage.m_factions.insertLast(f);
		}
		
		prepareParatrooperMode(stage);
		
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
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 2);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		
		//not sure why these were commented out?
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 0);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 3);
			command.setFloatAttribute("side_base_attack_probability", 0.75);				// default value is 0.05. previously 0.75 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 1);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 4);
			command.setFloatAttribute("side_base_attack_probability", 0.75);				// default value is 0.05. previously 0.75 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 2);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 8);
			command.setFloatAttribute("side_base_attack_probability", 0.7);				// default value is 0.05. previously 0.7 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		
		setupMapView(stage);
        		
		return stage;
	}
	
	protected Stage@ setupStageUndead2() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Untoten: Swan river";
		stage.m_mapInfo.m_path = "media/packages/ww2_undead/maps/edelweiss9_undead";
		stage.m_mapInfo.m_id = "edelweiss9_undead";
		stage.m_includeLayers.insertLast("bases.allies");
		stage.m_includeLayers.insertLast("layer.allies");     
		
		//stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));

		stage.addStartComment(Comment("undead varsity intro pt 1", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 2", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 3", 5.0));
		stage.addStartComment(Comment("undead swan intro pt 4", 5.0));
		stage.addStartComment(Comment("undead swan intro pt 5", 5.0));
		
		stage.m_maxSoldiers = 300;			//was 370
		stage.m_playerAiCompensation = 3;	//was 4
		stage.m_playerAiReduction = 0;		//was 0
		stage.m_soldierCapacityVariance = 0;  // was 0.35
    	
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
		enemySpawnCompensationFactor *= 0.5f; // adjust this to control how many extra soldiers are spawned in each scripted spawn, as a portion of compensation factor
		stage.setPhaseController(PhaseControllerSwan(m_metagame, enemySpawnCompensationFactor));
		
		//stage.addTracker(BossMusic(m_metagame, "mus_boss_battle_varsity.wav", "maus_boss.vehicle", 19.0, 180.0, 10.0, 1.5));	//volume was 5.0, last parameter - distance was 160, 2nd parameter		
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.0));
			f.m_overCapacity = 0;       
			f.m_capacityOffset = 0;      
			f.m_capacityMultiplier = 0.01;
			f.m_bases = 1;
			f.m_loseWithoutBases = false;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.6, 0.0)); 
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 0.7; // was 0.7
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.9, 0.0));
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 1.25; // was 1.75
			stage.m_factions.insertLast(f);
		}
		
		prepareParatrooperMode(stage);
		
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
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 2);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		
		//not sure why these were commented out?
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 0);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 3);
			command.setFloatAttribute("side_base_attack_probability", 0.75);				// default value is 0.05. previously 0.75 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 1);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 4);
			command.setFloatAttribute("side_base_attack_probability", 0.75);				// default value is 0.05. previously 0.75 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 2);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 8);
			command.setFloatAttribute("side_base_attack_probability", 0.7);				// default value is 0.05. previously 0.7 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		
		setupMapView(stage);
        		
		return stage;
	}
	
	protected Stage@ setupStageUndead3() {
		MyPhasedStage@ stage = createPhasedStage();
		stage.m_mapInfo.m_name = "Untoten: Sealion";
		stage.m_mapInfo.m_path = "media/packages/ww2_undead/maps/edelweiss8_undead";
		stage.m_mapInfo.m_id = "edelweiss8_undead";
		stage.m_includeLayers.insertLast("bases.allies");
		stage.m_includeLayers.insertLast("layer.allies");     
		
		//stage.addTracker(PeacefulLastBase(m_metagame, 0));
		
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle.call", "wh_vehicle_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_stug.call", "wh_vehicle_stug_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_vehicle_sdkfz251.call", "wh_vehicle_sdkfz251_spawn.call", array<string> = {""}, true, "vehicle"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf.call", "wh_inf_spawn.call", array<string> = {""}, true, "infantry"));
		stage.addTracker(SpawnInBaseCallHandler(m_metagame, "wh_inf_ai.call", "wh_inf_spawn_ai.call", array<string> = {""}, true, "infantry"));

		stage.addStartComment(Comment("undead varsity intro pt 1", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 2", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 3", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 4", 5.0));
		stage.addStartComment(Comment("undead varsity intro pt 5", 5.0));
		
		stage.m_maxSoldiers = 370;			//was 390
		stage.m_playerAiCompensation = 3;	//was 4
		stage.m_playerAiReduction = 0;		//was 0
		stage.m_soldierCapacityVariance = 0;  // was 0.35
    	
		float enemySpawnCompensationFactor = stage.m_playerAiCompensation * m_metagame.getUserSettings().m_playerAiCompensationFactor;
		enemySpawnCompensationFactor *= 0.5f; // adjust this to control how many extra soldiers are spawned in each scripted spawn, as a portion of compensation factor
		stage.setPhaseController(PhaseControllerSealion(m_metagame, enemySpawnCompensationFactor));
		
		//stage.addTracker(BossMusic(m_metagame, "mus_boss_battle_varsity.wav", "maus_boss.vehicle", 19.0, 180.0, 10.0, 1.5));	//volume was 5.0, last parameter - distance was 160, 2nd parameter		
		
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.0));
			f.m_overCapacity = 0;       
			f.m_capacityOffset = 0;      
			f.m_capacityMultiplier = 0.01;
			f.m_bases = 1;
			f.m_loseWithoutBases = false;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.6, 0.0)); 
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 0.7;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.9, 0.0));
			f.m_overCapacity = 0;  
			f.m_capacityOffset = 0;   
			f.m_capacityMultiplier = 1.75;
			stage.m_factions.insertLast(f);
		}
		
		prepareParatrooperMode(stage);
		
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
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 2);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer_2.vehicle", "radio_jammer_3.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		
		//not sure why these were commented out?
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 0);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 3);
			command.setFloatAttribute("side_base_attack_probability", 0.75);				// default value is 0.05. previously 0.75 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 1);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 4);
			command.setFloatAttribute("side_base_attack_probability", 0.75);				// default value is 0.05. previously 0.75 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", 2);
			command.setIntAttribute("minimum_squad_size_to_send_to_side_base_attack", 8);
			command.setFloatAttribute("side_base_attack_probability", 0.7);				// default value is 0.05. previously 0.7 used here
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));
		}
		
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
	}
	
	// --------------------------------------------
	protected void setupStartingMaps() {
		//m_myMapRotator.addStartingMap("edelweiss7_undead");
		m_myMapRotator.addStartingMap("edelweiss8_undead");
	}
}
