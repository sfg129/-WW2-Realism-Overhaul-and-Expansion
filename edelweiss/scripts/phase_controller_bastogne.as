#include "tracker.as"
#include "phase_controller.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "resource_helpers.as"
#include "call_sorting.as"
#include "helpers2.as"
#include "phase_helpers.as"

// --------------------------------------------
const Vector3 EAST_POSITION_1 = Vector3(640, 12, 363);
const Vector3 EAST_POSITION_2 = Vector3(672, 12, 359);
const Vector3 EAST_POSITION_FARM = Vector3(715, 8, 456);
const Vector3 WEST_POSITION_1 = Vector3(481, 15, 197);
const Vector3 WEST_POSITION_2 = Vector3(521, 15, 193);

//for Bastogne
//artillery strike positions, eastern redoubt: (648, 12, 573) (686, 11, 586)
//artillery strike positions, western redoubt: (416, 8, 467)
//vehicles west (478, 15, 219) (491, 15, 219) (511, 15, 220)
//vehicles east (648, 11, 386) (662, 11, 383) (675, 11, 382)
//infantry west (481, 15, 197) (521, 15, 193)
//infantry east (640, 12, 363) (672, 12, 359)
//infantry west forward of vehicles (519, 14, 260)
//infantry east forward of vehicles (653, 9, 418)
//infantry east probing team at farm (715, 8, 456)
//boss spawn (752, 12, 84)
//boss crew spawn (744, 12, 71)

// --------------------------------------------
class DefPhase : DefPhaseBase {
	// --------------------------------------------
	DefPhase(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, m_enemySpawnCompensationFactor);
	}

	////////////
	// TIER 1 //
	////////////

	protected void spawn_probeEAST() {
		spawn(5, 1, EAST_POSITION_1, "regular");
		spawn(1, 1, EAST_POSITION_1, "nco");
		spawn_less_compensation(1, 1, EAST_POSITION_1, "flamethrower_operator");		
	}

	protected void spawn_probeWEST() {
		spawn(5, 1, WEST_POSITION_1, "regular");
		spawn(1, 1, WEST_POSITION_1, "nco");
		spawn_less_compensation(1, 1, WEST_POSITION_1, "flamethrower_operator");		
	}
	
	protected void spawn_crewWEST() {
		spawn(3, 1, WEST_POSITION_1, "regular");
		spawn(1, 1, WEST_POSITION_1, "nco");		
	}
	
	protected void spawn_crewEAST() {
		spawn(3, 1, EAST_POSITION_1, "regular");
		spawn(1, 1, EAST_POSITION_1, "nco");		
	}
		
	////////////
	// TIER 2 //
	////////////
	
	protected void spawn_CORE() {
		spawn(7, 1, EAST_POSITION_1, WEST_POSITION_1, "regular");
		spawn(1, 1, EAST_POSITION_1, WEST_POSITION_1, "nco");
		spawn(1, 1, EAST_POSITION_1, WEST_POSITION_1, "veteran");
		spawn_less_compensation(1, 1, EAST_POSITION_1, WEST_POSITION_1, "flamethrower_operator");
	}

	////////////
	// TIER 3 //
	////////////
	
	// --------------------------------------------
	// definitely hard //
	protected void spawn_hardA() {
		spawn(14, 1, EAST_POSITION_1, WEST_POSITION_1, "regular");
		spawn(2, 1, EAST_POSITION_1, WEST_POSITION_1, "veteran");
		//spawn_less_compensation(1, 1, EAST_POSITION, WEST_POSITION, "flamethrower_operator");
	}

	// --------------------------------------------
	// you. will. perish. //
	protected void spawn_hardB() {
		spawn(16, 1, EAST_POSITION_1, WEST_POSITION_1, "regular");
		spawn(3, 1, EAST_POSITION_1, WEST_POSITION_1, "veteran");
		//spawn(1, 1, EAST_POSITION, WEST_POSITION, "flamethrower_operator");
		//spawn_less_compensation(1, 1, EAST_POSITION, WEST_POSITION, "flamethrower_operator_veteran");
	}
};


// --------------------------------------------
class DefPhase0 : DefPhase {
	protected float m_timer = 0.0;
	protected int m_ch = 0;

	// --------------------------------------------
	DefPhase0(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhase::start();

		_log("Phase0 starting");
		
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}
		


		
        //announce("about to begin");
		
		array<Resource@> resources = { 
			
Resource("mortar3.call", "call"),
Resource("airstrike.call", "call"),
Resource("airstrike1.call", "call"),
Resource("airstrike5.call", "call"),
Resource("airstrike4.call", "call"),
			Resource("usf_para_armoury.call", "call"),
			Resource("artillery2.call", "call"),
			Resource("artillery3.call", "call") 
		};
		resetFactionCallResources(m_metagame, 0, resources, false, getCallSorting());
		
		{
			m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.2' border_defense='0.3' />");
			m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.5' border_defense='0.0' />");
		}

		m_timer = 1.0 * 60.0;
		m_ch = 1;
		//setVisualTimer(m_metagame, m_timer);
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='1' border_defense='0' attack_start_spread='0' />");

		// set enemy soldier ai modifications
		/*
		// NOTE, this changed default soldier group as it is, and default soldier group is player-only, so it doesn't do anything
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" +
			"  <parameter class='willingness_to_charge' value='0.0' />\n" +
			"</command>");
			*/

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.75' border_defense='0.05' />");
		
		spawn_probeEAST();
		//spawn_probeWEST();
		m_metagame.getComms().send("<command class='update_base' base_key='eastern_redoubt' capturable='0' />");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			end();
		}
	    if (m_timer < 80.0 && m_ch == 0){
			m_ch++;    
    		//m_metagame.getComms().send("<command class='create_instance' faction_id='0' position='591 50 365' instance_class='vehicle' instance_key='supply_box.vehicle'/>");
	    }    
		if (m_timer < 60.0 && m_ch==1){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 1"));
		}
		if (m_timer < 55.0 && m_ch==2){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 2"));
		}
		if (m_timer < 50.0 && m_ch==3){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 3"));
		}
		if (m_timer < 45.0 and m_ch==4){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 4"));
		}
		if (m_timer < 40.0 and m_ch==5){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 5"));
		}
		if (m_timer < 35.0 and m_ch==6){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 6"));
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='648 11 386' faction_id='1' />");		
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_stug_hidden.call' position='662 11 383' faction_id='1' />");		
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='478 15 219' faction_id='1' />");
			spawn_crewEAST();
		}
		if (m_timer < 7.0 and m_ch==7){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne intro, part 7"));
		}
	}
	
	void end() {
		DefPhase::end();
		//clearVisualTimer(m_metagame);
	}
	
	// --------------------------------------------
	void save(XmlElement@ root) {
		DefPhase::save(root);
		
		root.setIntAttribute("ch", m_ch);
		root.setFloatAttribute("timer", m_timer);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		DefPhase::load(root);

		m_ch = root.getIntAttribute("ch");
		m_timer = root.getFloatAttribute("timer");
	}	
};

    // -------------------------------------------- 
// this is the first attack post - commander chat
// for Bastogne this will serve as a preliminary attack with mild armour, a "probe"
class DefPhase1 : DefPhase {
	protected float m_timer = 0.0;
	protected int m_ch = 0;

	// --------------------------------------------
	DefPhase1(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase1 starting");
		
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}
		
		if (_logger.m_logLevel >= 1) {
			//announce("TEST: Phase1 starting");
		}
		
		m_timer = 3.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage 1"));
		
		//m_metagame.getComms().send("<command class='create_call' key='artillery.call' position='490 6 318' faction_id='1' />");
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.17' border_defense='0.12' attack_start_spread='0' attack_target_spread='0' attack_target_base_key='roadside_redoubt' />");


		// set enemy soldier ai modifications
		/*
		// NOTE, this changed default soldier group as it is, and default soldier group is player-only, so it doesn't do anything
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.35' />\n" +
			"</command>");
			*/
			
		/////////////////
		// EAST SPAWNS //
		/////////////////
		//m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='460 6 185' instance_class='vehicle' instance_tag='jeep'/>");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
		if (m_timer < 180.0 and m_ch==0){
			m_ch++;
			//spawn_probeWEST();
			/////////////////
			// EAST SPAWNS //
			//vehicles west (478, 15, 219) (491, 15, 219) (511, 15, 220)
			//vehicles east (648, 11, 386) (662, 11, 383) (675, 11, 382)
			/////////////////

			/////////////////
			// WEST SPAWNS //
			/////////////////
		}
		if (m_timer < 90.0 and m_ch==1){
			m_ch++;
			spawn_crewEAST();
		}
	}
	
	void end() {
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}
	
	// --------------------------------------------
	void save(XmlElement@ root) {
		DefPhase::save(root);
		
		root.setIntAttribute("ch", m_ch);
		root.setFloatAttribute("timer", m_timer);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		DefPhase::load(root);

		m_ch = root.getIntAttribute("ch");
		m_timer = root.getFloatAttribute("timer");
	}	
	
};

// -------------------------------------------- second attack
// for Bastogne this is a massive, full-on assault with preliminary bombardment and lots of Armour
//artillery strike positions, eastern redoubt: (648, 12, 573) (686, 11, 586)
//artillery strike positions, western redoubt: (416, 8, 467)
class DefPhase2 : DefPhase {
	protected float m_timer = 0.0;
	protected int m_ch=0;

	// --------------------------------------------
	DefPhase2(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase2 starting");
		
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}
		
		if (_logger.m_logLevel >= 1) {
			//announce("TEST: Phase2 starting");
		}
		
		m_timer = 12.0 * 60.0;      // was 7.0
		setVisualTimer(m_metagame, m_timer);

		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage 2"));
		
		m_metagame.getComms().send("<command class='create_call' key='artillery2.call' position='648 12 573' faction_id='1' />");
		
		// set enemy soldier ai modifications
		/*
		// NOTE, this changed default soldier group as it is, and default soldier group is player-only, so it doesn't do anything
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='1.0' />\n" +
			"</command>");
*/
			
		/////////////////
		// SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='511 15 220' faction_id='1' />");		
		//m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_panzer_hidden.call' position='665 11 382' faction_id='1' />");		
		spawn_crewEAST();
		spawn_crewWEST();
		
		m_metagame.getComms().send("<command class='update_base' base_key='eastern_redoubt' capturable='1' />");
		
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.15' border_defense='0.1' attack_start_spread='0' attack_target_spread='0' attack_target_base_key='eastern_redoubt' />");
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage attacks increase 1"));
	}

	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
			// base_id
			// owner_id (faction)
			
		int owner = event.getIntAttribute("owner_id");		
		string baseKey = event.getStringAttribute("base_key");
		_log("base name is " + baseKey + " owned by " + owner);
		if (baseKey == "eastern_redoubt") {
			// if eastern redoubt changes owner, change things
			if (owner == 0) {
					//if Allies own Eastern Redoubt, Axis attack with a lot of force
						m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.15' border_defense='0.1' attack_start_spread='0' attack_target_spread='0' attack_target_base_key='eastern_redoubt' />");
			} else if (owner == 1) {
					//if Axis own Eastern Redoubt, Axis continue to attack but with less force
				// NOTE, clear attack request with attack_target_base_key='' to let commander control again
				m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.3' border_defense='0.1' attack_start_spread='6' attack_target_spread='6' attack_target_base_key='' />");         // was 0.3 0.2
				}
			}
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
		if (m_timer < 420.0 and m_ch==0){
			m_ch++;
			spawn_CORE();
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_king_tiger_hidden.call' position='648 11 386' faction_id='1' />");		
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_king_tiger_hidden.call' position='662 11 383' faction_id='1' />");
            m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_stug_hidden.call' position='533 15 215' faction_id='1' />");		
			spawn_crewEAST();
			spawn_crewEAST();
		}
		if (m_timer < 320.0 and m_ch==1){
			m_ch++;
			spawn_CORE();
			spawn_CORE();
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage attacks increase 2"));
			/////////////////
			// EAST SPAWNS //
			//vehicles west (478, 15, 219) (491, 15, 219) (511, 15, 220)
			//vehicles east (648, 11, 386) (662, 11, 383) (675, 11, 382)
			/////////////////

			//m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='675 11 382' faction_id='1' />");		
			//m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_panzer_hidden.call' position='655 11 384' faction_id='1' />");				
			/////////////////
			// WEST SPAWNS //
			/////////////////
			m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_sdkfz251_hidden.call' position='478 15 219' faction_id='1' />");		
			//m_metagame.getComms().send("<command class='create_call' key='wh_vehicle_panzer_hidden.call' position='491 15 219' faction_id='1' />");		
			m_metagame.getComms().send("<command class='create_call' key='artillery2.call' position='648 12 573' faction_id='1' />");
		}
		if (m_timer <310 and m_ch==2) {
			m_ch++;
			spawn_probeEAST(); //hopefully these will crew the vehicle army we just made
			spawn_probeWEST();
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage attacks increase 3"));
		}
		if (m_timer < 210.0 and m_ch==3){
			m_ch++;
			m_metagame.getComms().send("<command class='create_call' key='artillery2.call' position='648 12 573' faction_id='1' />");
			
			
			
			//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne test info 1"));	//just to log when this happens
			//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne test info 1"));	//just to log when this happens
			//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne test info 1"));	//just to log when this happens
			{
				XmlElement command("command");
				command.setStringAttribute("class", "change_game_settings");
				
				command.setStringAttribute("soldier_capacity_model", "constant");

				
				// temporarily the Allies get a large boost to defenders; they will then be set to more normal values during counter-attack phase
				XmlElement f1("faction");
				f1.setFloatAttribute("capacity_multiplier", 1.6);
				//f1.setFloatAttribute("ai_accuracy", 0.95);
				//f1.setIntAttribute("lose_without_bases", 1);
				command.appendChild(f1);

				XmlElement f2("faction");
				f2.setFloatAttribute("capacity_multiplier", 0.8);
				//f2.setFloatAttribute("ai_accuracy", 0.85);
				//f2.setIntAttribute("lose_without_bases", 1);
				command.appendChild(f2);

				m_metagame.getComms().send(command);
			}
		}
		if (m_timer < 90.0 and m_ch==4){
			m_ch++;
			spawn_CORE();
		}
	}
	
	void end() {
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		DefPhase::save(root);
		
		root.setIntAttribute("ch", m_ch);
		root.setFloatAttribute("timer", m_timer);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		DefPhase::load(root);

		m_ch = root.getIntAttribute("ch");
		m_timer = root.getFloatAttribute("timer");
	}	
};

// --------------------------------------------
//-- this is the counter-attack phase where Allies retake map
class DefPhase7 : DefPhase {
	// --------------------------------------------
	DefPhase7(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase7 starting");
		
		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}

		if (_logger.m_logLevel >= 1) {
			//announce("TEST: Phase7 starting");
		}

		



		
		array<Resource@> resources = { 


Resource("mortar3.call", "call"),
Resource("airstrike.call", "call"),
Resource("airstrike1.call", "call"),
Resource("airstrike5.call", "call"),
Resource("airstrike4.call", "call"),
			Resource("usf_para_armoury.call", "call"),
			Resource("artillery2.call", "call"),
			Resource("artillery3.call", "call") 
		};
		resetFactionCallResources(m_metagame, 0, resources, true, getCallSorting());
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage 7"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage 8"));
		
		// set enemy commander ai
		// NOTE, clear requested attack_target_base_key, it could've been left set by the previous phase
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.7' border_defense='0.15' attack_start_spread='4' attack_target_spread='4' attack_target_base_key='' />");          // was 0.65 0.2

		// set enemy soldier ai modifications
		/*
		// NOTE, this changed default soldier group as it is, and default soldier group is player-only, so it doesn't do anything
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.0' />\n" +
			"</command>");
			*/
			
		// set enemy home base to capturable
		m_metagame.getComms().send("<command class='update_base' base_key='bois_jacques' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='foy_outskirts' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='foy_south' capturable='1' />");
		//m_metagame.getComms().send("<command class='update_base' base_key='foy_north' capturable='1' />");	//we need this uncapturable to conduct the boss fight
		m_metagame.getComms().send("<command class='update_base' base_key='farmhouse' capturable='1' />");

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.4' border_defense='0.1' attack_start_spread='4' attack_target_spread='4'/>");    // was 0.3 0.1
		
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 7.0, 0, "bastogne stage counterattack 1"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 10.0, 0, "bastogne stage counterattack 2"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 15.0, 0, "bastogne stage counterattack 3"));
		
		
		//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne test info 2"));	//just to log when this happens
		//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne test info 2"));	//just to log when this happens
		//m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne test info 2"));	//just to log when this happens
		{
				XmlElement command("command");
				command.setStringAttribute("class", "change_game_settings");
				
				command.setStringAttribute("soldier_capacity_model", "constant");

				
				// a bit more for Player faction, but enemy Faction gets a lot more resources, since they are no longer reinforced with waves.
				XmlElement f1("faction");
				f1.setFloatAttribute("capacity_multiplier", 1.0);
				//f1.setFloatAttribute("ai_accuracy", 0.95);
				//f1.setIntAttribute("lose_without_bases", 1);
				command.appendChild(f1);

				XmlElement f2("faction");
				f2.setFloatAttribute("capacity_multiplier", 1.4);       
				//f2.setFloatAttribute("ai_accuracy", 0.85);
				//f2.setIntAttribute("lose_without_bases", 1);
				command.appendChild(f2);

				m_metagame.getComms().send(command);
		}
	}

	// --------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		// response to base owner change event in DefPhase7 checking when enemy has only one base left, and end DefPhase7
		if (getBasesForFaction(m_metagame, 1) == 1) {
			end();
		}
	}
	
	void end() {
		DefPhase::end();
		//clearVisualTimer(m_metagame);
	}
};

// --------------------------------------------
class DefPhaseBoss : DefPhase {
	protected string m_bossVehicle;

	// --------------------------------------------
	DefPhaseBoss(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
		m_bossVehicle = "king_tiger_boss.vehicle";
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("DefPhaseBoss starting");

		if (m_loadingFromSave) {
			// trust that nothing needs to be re-set when loading from save
			return;
		}

		if (_logger.m_logLevel >= 1) {
			//announce("TEST: PhaseBoss starting");
		}

				/*
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage 7"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "bastogne stage 8"));
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.65' border_defense='0.2' attack_start_spread='4' attack_target_spread='4'/>");
		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.2' border_defense='0.15' attack_start_spread='4' attack_target_spread='4'/>");  
		
		{
				XmlElement command("command");
				command.setStringAttribute("class", "change_game_settings");
				
				command.setStringAttribute("soldier_capacity_model", "constant");

				
				// a bit more for Player faction, but enemy Faction gets a lot more resources, since they are no longer reinforced with waves.
				XmlElement f1("faction");
				f1.setFloatAttribute("capacity_multiplier", 1.0);
				//f1.setFloatAttribute("ai_accuracy", 0.95);
				//f1.setIntAttribute("lose_without_bases", 1);
				command.appendChild(f1);

				XmlElement f2("faction");
				f2.setFloatAttribute("capacity_multiplier", 1.0);
				//f2.setFloatAttribute("ai_accuracy", 0.85);
				//f2.setIntAttribute("lose_without_bases", 1);
				command.appendChild(f2);

				m_metagame.getComms().send(command);
		}
		*/
		
		//733 12 116
		//737 12 99  crew
		
		// capture enemy bases except the intended last one, allows proper testing by skipping phases 
		{
			// "foy_north" is last base?
			array<string> bases = {"bastogne", "supply_dump", "luzery", "eastern_redoubt", "farmhouse", "roadside_redoubt", "foy_outskirts", "bois_jacques", "foy_south"};
			for (uint i = 0; i < bases.size(); ++i) {
				XmlElement command("command");
				command.setStringAttribute("class", "update_base");
				command.setIntAttribute("owner_id", 0);
				command.setStringAttribute("base_key", bases[i]);
				m_metagame.getComms().send(command);
			}
			
			// make foy north uncapturable here, guess it should already be so?
		{
				XmlElement command("command");
				command.setStringAttribute("class", "update_base");
				command.setIntAttribute("capturable", 0);
				command.setStringAttribute("base_key", "foy_north");
				m_metagame.getComms().send(command);
		}
	}

		// make all friendly bases uncapturable at start of final boss phase
		array<const XmlElement@> bases = getBases(m_metagame);
		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base.getIntAttribute("owner_id") == 0 &&
				base.getBoolAttribute("capturable")) {
				XmlElement command("command");
				command.setStringAttribute("class", "update_base");
				command.setIntAttribute("base_id", base.getIntAttribute("id"));
				command.setIntAttribute("capturable", 0);
				m_metagame.getComms().send(command);
			}
		}
		
		//friendly AI attack the final base even though it cannot be captured:
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.1' border_defense='0.1' attack_target_base_key='foy_north' />");
		
		// when player has reached final objective, we need to spawn in and crew a special Boss Tank that must be killed to win the match.
		// spawn boss tank
		//733 12 116
		//737 12 99  crew
		{
			Vector3 position(733, 13, 116);
			string orientation("0 0 0 1");
			
			array<const XmlElement@>@ nodes = getGenericNodes(m_metagame, "", "boss_tank");
			if (nodes.size() > 0) {
				position = stringToVector3(nodes[0].getStringAttribute("position"));
				orientation = nodes[0].getStringAttribute("orientation");
			}				
			
			XmlElement command("command");
			command.setStringAttribute("class", "create_instance");
			command.setIntAttribute("faction_id", 1);
			command.setStringAttribute("position", position.toString());
			command.setStringAttribute("orientation", orientation);
			command.setStringAttribute("instance_class", "vehicle");
			command.setStringAttribute("instance_key", m_bossVehicle);
			m_metagame.getComms().send(command);
			
			
			// spawn crew too
			position = position.add(Vector3(5.0,0.0,0.0));	//handles crew position
			m_metagame.addTracker(Spawner(m_metagame, 1, position, 16, "regular"));
			m_metagame.addTracker(Spawner(m_metagame, 1, position, 4, "nco"));
			
			//Vector3 positionBossTank(733, 13, 116);
			//string vehicleKey = "king_tiger_boss.vehicle";
			//m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='"+positionBossTank.toString()+"' instance_class='vehicle' instance_key='"+vehicleKey+"' />");

		}

		{
			// insta-kill friendlies in Foy
			array<const XmlElement@> nodes = getGenericNodes(m_metagame, "", "unsafezone");
			array<string> unsafeBlocks = array<string>(0);
			for (uint i = 0; i < nodes.length(); ++i) {
				const XmlElement@ node = nodes[i];
				string coordinate = node.getStringAttribute("block");
				_log("marking block " + coordinate + " unsafe", 1);
				unsafeBlocks.insertLast(coordinate);
			}

			if (unsafeBlocks.size() > 0) {
				// faction id 0
				array<const XmlElement@> characters = getCharactersInBlocks(m_metagame, 0, unsafeBlocks);
				if (characters !is null) {
					for (uint j = 0; j < characters.length(); ++j) {
						const XmlElement@ character = characters[j];
						int id = character.getIntAttribute("id");
						string command = "<command class='update_character' id='" + id + "' dead='1' preserve_items='1' />";
						m_metagame.getComms().send(command);
					}
				}
			}
		}
	}

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		// watch for boss tank destroy event to end final boss phase or call match end, probably similar to map12 stuff
		string key = event.getStringAttribute("vehicle_key");
		if (key == m_bossVehicle) {
			_log("DefPhaseBoss, vehicle being destroyed, key " + key); 
			end();
		}
	}
};

// --------------------------------------------
class PhaseControllerBastogne : PhaseControllerBase {
	// --------------------------------------------
	PhaseControllerBastogne(GameModeInvasion@ metagame, float enemySpawnCompensationFactor) {
		super(metagame, "bastogne", enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void reset() {
		PhaseControllerBase::reset();
		
		m_phases.insertLast(DefPhase0(m_metagame, this, m_enemySpawnCompensationFactor));	//commander chat & setup
		m_phases.insertLast(DefPhase1(m_metagame, this, m_enemySpawnCompensationFactor));	//initial probing attack
		m_phases.insertLast(DefPhase2(m_metagame, this, m_enemySpawnCompensationFactor));	//full on assault
		m_phases.insertLast(DefPhase7(m_metagame, this, m_enemySpawnCompensationFactor));	//counter-attack
		m_phases.insertLast(DefPhaseBoss(m_metagame, this, m_enemySpawnCompensationFactor));//boss fight
	}


}
