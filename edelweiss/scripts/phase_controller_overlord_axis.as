#include "tracker.as"
#include "phase_controller.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "resource_helpers.as"
#include "call_sorting.as"
#include "helpers2.as"
#include "phase_helpers.as"

// --------------------------------------------
const Vector3 EAST_POSITION = Vector3(530, 4, 805);
const Vector3 WEST_POSITION = Vector3(410, 3, 850);
const string EAST_VEHICLE_P = "'536 3 798'";
const string WEST_VEHICLE_P = "'524 3 801'";
const string EAST_VEHICLE_O = "'0 1 0 3.14'";
const string WEST_VEHICLE_O = "'0 1 0 3.14'";
const string EAST_SPECIAL_P = "'926 13 428'";
const string WEST_SPECIAL_P = "'240 12 409'";
const string CENT_ARTILLERY = "'512 12 590'";

// --------------------------------------------
class DefPhaseOverlord : DefPhaseBase {
	// --------------------------------------------
	DefPhaseOverlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, m_enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	protected uint getCompensatedEnemyCount(uint count) {
		int playerCount = getPlayerCount(m_metagame);
		count = max(1, int((count + m_enemySpawnCompensationFactor * max(0, playerCount - 1)) * m_metagame.getUserSettings().m_enemyCapacityFactor));
		return count;
	}
	
	// --------------------------------------------
	protected uint getCompensatedEnemyCount_less(uint count) {
		int playerCount = getPlayerCount(m_metagame);
		count = max(1, int((count + (m_enemySpawnCompensationFactor/4) * max(0, playerCount - 1)) * m_metagame.getUserSettings().m_enemyCapacityFactor));	// --should yield a quarter as many of the addition factor. So with Max Server, you get +6 men rather than +23.
		return count;
	}
	
	// --------------------------------------------
	protected void spawn(uint count, uint factionId, Vector3 position, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount(count), factionId, position, instanceKey);
	}

	// --------------------------------------------
	protected void spawn(uint count, uint factionId, Vector3 position1, Vector3 position2, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount(count), factionId, position1, position2, instanceKey);
	}
	
	// -------------------------------------------- previous two spawns are defined twice because one is for when only given 1 position; other spawns at 2 positions. below spawns at 2 only.
	protected void spawn_less_compensation(uint count, uint factionId, Vector3 position1, Vector3 position2, string instanceKey) {
		::spawn(m_metagame, getCompensatedEnemyCount_less(count), factionId, position1, position2, instanceKey);
	}

	////////////
	// TIER 1 //
	////////////
	// --------------------------------------------	
	// very easy //
	protected void spawn_easyA() {
		spawn(14, 1, EAST_POSITION, "regular");
	}

	// --------------------------------------------
	// easy //
	protected void spawn_easyB() {
		spawn(14, 1, WEST_POSITION, "regular");
	}
		
	////////////
	// TIER 2 //
	////////////
	
	// --------------------------------------------
	// toasty //
	protected void spawn_mediumA() {
		spawn(15, 1, EAST_POSITION, WEST_POSITION, "regular");
	}

	// --------------------------------------------
	// medium rare //
	protected void spawn_mediumB() {
		spawn(12, 1, EAST_POSITION, WEST_POSITION, "regular");
		spawn(2, 1, EAST_POSITION, WEST_POSITION, "veteran");
	}

	////////////
	// TIER 3 //
	////////////
	
	// --------------------------------------------
	// definitely hard //
	protected void spawn_hardA() {
		spawn(13, 1, EAST_POSITION, WEST_POSITION, "regular");
		spawn(2, 1, EAST_POSITION, WEST_POSITION, "veteran");
		spawn_less_compensation(1, 1, EAST_POSITION, WEST_POSITION, "flamethrower_operator");
	}

	// --------------------------------------------
	// you. will. perish. //
	protected void spawn_hardB() {
		spawn(16, 1, EAST_POSITION, WEST_POSITION, "regular");
		spawn(3, 1, EAST_POSITION, WEST_POSITION, "veteran");
		//spawn(1, 1, EAST_POSITION, WEST_POSITION, "flamethrower_operator");
		spawn_less_compensation(1, 1, EAST_POSITION, WEST_POSITION, "flamethrower_operator_veteran");
	}

	//////////////////////
	// SPECIAL INFANTRY //
	//////////////////////

	// --------------------------------------------
	protected void spawn_special1() {
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + EAST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + WEST_SPECIAL_P + " faction_id='1'/>");
	}
	protected void spawn_special2() {
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + EAST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + WEST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + EAST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + WEST_SPECIAL_P + " faction_id='1'/>");
	}
	protected void spawn_special3() {
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + EAST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + WEST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + EAST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + WEST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + EAST_SPECIAL_P + " faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='usf_para.call' position=" + WEST_SPECIAL_P + " faction_id='1'/>");
	}

	// --------------------------------------------
	// some special infantry //
	protected void spawn_special_easy()  {
		spawn_special1();
	}

	// --------------------------------------------
	// more special infantry //
	protected void spawn_special_medium()  {
		spawn_special2();
	}

	// --------------------------------------------
	// all the special infantry //
	protected void spawn_special_hard()  {
		spawn_special3();
	}

    // ----------------------------------------------------
    protected void announce(string text) {
		sendFactionMessage(m_metagame, 0, text, 1.0);
    }
};


// --------------------------------------------
class DefPhase0Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	protected int m_ch = 0;

	// --------------------------------------------
	DefPhase0Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase0 starting");
        //announce("about to begin");
				
		array<Resource@> resources = { 
			
			Resource("airstrike10.call", "call"),
			Resource("artillery2.call", "call"),
			Resource("wh_vehicle_stug.call", "call"),
			Resource("wh_vehicle.call", "call"),
			Resource("wh_vehicle_sdkfz251_pak40.call", "call"),
			Resource("wh_vehicle_sdkfz251_flak.call", "call"),
			Resource("wh_vehicle_sdkfz251_mortar.call", "call"),
			Resource("wh_vehicle_sdkfz251.call", "call"),
			Resource("wh_vehicle_luchs.call", "call"),
			Resource("mortar2.call", "call")

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
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" +
			"  <parameter class='willingness_to_charge' value='0.0' />\n" +
			"</command>");

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.99' border_defense='0.01' />");
		
		spawn_easyA();
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
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 1"));
		}
		if (m_timer < 55.0 && m_ch==2){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 2"));
		}
		if (m_timer < 50.0 && m_ch==3){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 3"));
		}
		if (m_timer < 45.0 and m_ch==4){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 4"));
		}
		if (m_timer < 40.0 and m_ch==5){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 5"));
		}
		if (m_timer < 35.0 and m_ch==6){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 6"));
		}
		if (m_timer < 7.0 and m_ch==7){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord intro, part 7"));
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		//clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase1Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	protected int m_ch = 0;

	// --------------------------------------------
	DefPhase1Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase1 starting");
		
		
		m_timer = 5.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 1"));
		
		m_metagame.getComms().send("<command class='create_call' key='artillery1.call' position=" + CENT_ARTILLERY + " faction_id='1' />");
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.25' border_defense='0.0' attack_start_spread='4' attack_target_spread='4' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='1.0' />\n" +
			"</command>");
		/////////////////
		// EAST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='willys_mb.vehicle'/>");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
		if (m_timer < 300.0 and m_ch==0){
			m_ch++;
			spawn_easyB();
			spawn_special_easy();
			/////////////////
			// EAST SPAWNS //
			/////////////////
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='willys_mb.vehicle'/>");
			/////////////////
			// WEST SPAWNS //
			/////////////////
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + WEST_VEHICLE_O + " instance_class='vehicle' instance_key='willys_mb.vehicle'/>");
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + WEST_VEHICLE_O + " instance_class='vehicle' instance_key='m3_halftrack.vehicle'/>");
		}
		if (m_timer < 240.0 and m_ch==1){
			m_ch++;
			spawn_easyA();
		}
		if (m_timer < 180.0 and m_ch==2){
			m_ch++;
			spawn_easyB();
		}
		if (m_timer < 120.0 and m_ch==3){
			m_ch++;
			spawn_easyA();
		}
		if (m_timer < 60.0 and m_ch==4){
			m_ch++;
			spawn_easyB();
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase2Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	protected int m_ch=0;

	// --------------------------------------------
	DefPhase2Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}

	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase2 starting");
		
		
		m_timer = 5.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);

		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 2"));
		
		//m_metagame.getComms().send("<command class='create_call' key='artillery1.call' position='499 6 372' faction_id='1' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='1.0' />\n" +
			"</command>");
			
		/////////////////
		// WEST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + WEST_VEHICLE_O + " instance_class='vehicle' instance_key='willys_mb.vehicle'/>");
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + WEST_VEHICLE_O + " instance_class='vehicle' instance_key='m3_halftrack.vehicle'/>");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
		if (m_timer < 300.0 and m_ch==0){
			m_ch++;
			spawn_easyA();
		}
		if (m_timer < 240.0 and m_ch==1){
			m_ch++;
			spawn_easyB();
			spawn_special_easy();
			/////////////////
			// EAST SPAWNS //
			/////////////////
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m3_halftrack.vehicle'/>");
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m3_halftrack.vehicle'/>");
		}
		if (m_timer < 180.0 and m_ch==2){
			m_ch++;
			spawn_easyA();
		}
		if (m_timer < 120.0 and m_ch==3){
			m_ch++;
			spawn_easyB();
		}
		if (m_timer < 60.0 and m_ch==4){
			m_ch++;
			spawn_mediumA();
			//m_metagame.getComms().send("<command class='create_call' key='artillery1.call' position='499 6 372' faction_id='1' />");
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase3Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	protected int m_ch=0;
	// --------------------------------------------
	DefPhase3Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase3 starting");
		
		m_timer = 7.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);

		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.25' border_defense='0.0' attack_start_spread='4' attack_target_spread='4' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.75' />\n" +
			"</command>");
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 3"));
		
		//{
				//XmlElement command("command");
				//command.setStringAttribute("class", "change_game_settings");
				
				//command.setStringAttribute("soldier_capacity_model", "constant");

				
				// more defending Soldiers because generally they lose some bases here, and that greatly reduces their manpower
				//XmlElement f1("faction");
				//f1.setFloatAttribute("capacity_multiplier", 0.65);
				//f1.setFloatAttribute("ai_accuracy", 0.95);
				//f1.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f1);

				//XmlElement f2("faction");
				//f2.setFloatAttribute("capacity_multiplier", 0.2);
				//f2.setFloatAttribute("ai_accuracy", 0.7);
				//f2.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f2);

				//m_metagame.getComms().send(command);
		//}
		
		/////////////////
		// EAST SPAWNS //
		/////////////////
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
		/////////////////
		// WEST SPAWNS //
		/////////////////
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='509 6 187' faction_id='1' />");
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
			spawn_easyB();
		}
		if (m_timer < 350.0 and m_ch==1){
			m_ch++;
			spawn_easyA();
			spawn_special_medium();
			/////////////////
			// EAST SPAWNS //
			/////////////////
			//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
			/////////////////
			// WEST SPAWNS //
			/////////////////
			//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='509 6 187' faction_id='1' />");
		}
		if (m_timer < 210.0 and m_ch==2){
			m_ch++;
			spawn_easyB();
		}
		if (m_timer < 150.0 and m_ch==3){
			m_ch++;
			spawn_easyB();
		}
		if (m_timer < 90.0 and m_ch==4){
			m_ch++;
			spawn_mediumA();
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase4Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	protected int m_ch=0;
	// --------------------------------------------
	DefPhase4Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase4 starting");
		
		m_timer = 6.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);		

		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 4"));
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.25' border_defense='0.0' attack_start_spread='4' attack_target_spread='4' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.4' />\n" +
			"</command>");
			
		//{
				//XmlElement command("command");
				//command.setStringAttribute("class", "change_game_settings");
				
				//command.setStringAttribute("soldier_capacity_model", "constant");
		
				// more defending Soldiers because generally you can be down to one base here
				//XmlElement f1("faction");
				//f1.setFloatAttribute("capacity_multiplier", 0.8);
				//f1.setFloatAttribute("ai_accuracy", 1.0);
				//f1.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f1);

				//XmlElement f2("faction");
				//f2.setFloatAttribute("capacity_multiplier", 0.2);
				//f2.setFloatAttribute("ai_accuracy", 0.7);
				//f2.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f2);

				//m_metagame.getComms().send(command);
		//}
			
		/////////////////
		// EAST SPAWNS //
		/////////////////
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
		/////////////////
		// WEST SPAWNS //
		/////////////////
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='509 6 187' faction_id='1' />");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='520 6 187' faction_id='1' />");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
		if (m_timer < 360.0 and m_ch==0){
			m_ch++;
			spawn_mediumA();
		}
		if (m_timer < 300.0 and m_ch==1){
			m_ch++;
			spawn_mediumA();
		}
		if (m_timer < 240.0 and m_ch==2){
			m_ch++;
			spawn_easyB();
			spawn_special_medium();
			/////////////////
			// EAST SPAWNS //
			/////////////////
			//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
			/////////////////
			// WEST SPAWNS //
			/////////////////
			//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='509 6 187' faction_id='1' />");
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + WEST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
		}
		if (m_timer < 150.0 and m_ch==3){
			m_ch++;
			spawn_mediumB();
		}
		if (m_timer < 90.0 and m_ch==4){
			m_ch++;
			spawn_hardA();
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase5Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	// --------------------------------------------
	DefPhase5Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase5 starting");
		
		m_timer = 2.0 * 60.0;
		//setVisualTimer(m_metagame, m_timer);	
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 5"));

		//m_metagame.getComms().send("<command class='create_call' key='artillery.call' position='505 6 500' faction_id='1' />");

		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='1.0' border_defense='0.0' attack_start_spread='0' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.0' />\n" +
			"</command>");

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.99' border_defense='0.01' />");
		
		/////////////////
		// EAST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='473 6 184' faction_id='1' />");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='730 3 222' faction_id='1' />");
		/////////////////
		// WEST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + WEST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='520 6 187' faction_id='1' />");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='404 6 78' faction_id='1' />");
		
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		//clearVisualTimer(m_metagame);
	}
};

// --------------------------------------------
class DefPhase6Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	protected int m_ch=0;
	// --------------------------------------------
	DefPhase6Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase6 starting");
				
		m_timer = 5.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);	
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 6"));
		
		//{
				//XmlElement command("command");
				//command.setStringAttribute("class", "change_game_settings");
				
				//command.setStringAttribute("soldier_capacity_model", "constant");
		
				// more defending Soldiers because generally you can be down to one base here
				//XmlElement f1("faction");
				//f1.setFloatAttribute("capacity_multiplier", 0.85);
				//f1.setFloatAttribute("ai_accuracy", 1.0);
				//f1.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f1);

				//XmlElement f2("faction");
				//f2.setFloatAttribute("capacity_multiplier", 0.2);
				//f2.setFloatAttribute("ai_accuracy", 0.7);
				//f2.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f2);

				//m_metagame.getComms().send(command);
		//}
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.4' border_defense='0.0' attack_start_spread='4' attack_target_spread='4' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.5' />\n" +
			"</command>");

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.99' border_defense='0.01' />");
		
		/////////////////
		// EAST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + EAST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
		/////////////////
		// WEST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position=" + WEST_VEHICLE_P + " orientation=" + EAST_VEHICLE_O + " instance_class='vehicle' instance_key='m4_75.vehicle'/>");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
		if (m_timer < 300.0 and m_ch==0){
			m_ch++;
			spawn_mediumB();
		}
		if (m_timer < 240.0 and m_ch==1){
			m_ch++;
			spawn_hardA();
		}
		if (m_timer < 180.0 and m_ch==2){
			m_ch++;
			spawn_hardA();
		}
		if (m_timer < 120.0 and m_ch==3){
			m_ch++;
			spawn_hardB();
		}
		if (m_timer < 60.0 and m_ch==4){
			m_ch++;
			spawn_special_hard();
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase7Overlord : DefPhaseOverlord {
	protected float m_timer = 0.0;
	// --------------------------------------------
	DefPhase7Overlord(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhaseOverlord::start();
		_log("Phase7 starting");
				
		m_timer = 2.0 * 60.0;
		//setVisualTimer(m_metagame, m_timer);	
		
		array<Resource@> resources = { 
			
			Resource("airstrike10.call", "call"),
			Resource("artillery2.call", "call"),
			Resource("wh_vehicle_stug.call", "call"),
			Resource("wh_vehicle.call", "call"),
			Resource("wh_vehicle_sdkfz251_pak40.call", "call"),
			Resource("wh_vehicle_sdkfz251_flak.call", "call"),
			Resource("wh_vehicle_sdkfz251_mortar.call", "call"),
			Resource("wh_vehicle_sdkfz251.call", "call"),
			Resource("wh_vehicle_luchs.call", "call"),
			Resource("mortar2.call", "call")
		};
		resetFactionCallResources(m_metagame, 0, resources, true, getCallSorting());
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 7"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "overlord stage 8"));
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.75' border_defense='0.15' attack_start_spread='4' attack_target_spread='4'/>");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.0' />\n" +
			"</command>");
		// set enemy home base to capturable
		//m_metagame.getComms().send("<command class='update_base' base_key='Omaha Beach' capturable='1' />");	//capturing all other bases triggers victory
		checkBases(m_metagame);

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.2' border_defense='0.15' attack_start_spread='4' attack_target_spread='4'/>");  
		
		//{
				//XmlElement command("command");
				//command.setStringAttribute("class", "change_game_settings");
				
				//command.setStringAttribute("soldier_capacity_model", "constant");

				
				// a bit more for Player faction, but enemy Faction gets a lot more resources, since they are no longer reinforced with waves.
				//XmlElement f1("faction");
				//f1.setFloatAttribute("capacity_multiplier", 0.85);
				//f1.setFloatAttribute("ai_accuracy", 0.95);
				//f1.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f1);

				//XmlElement f2("faction");
				//f2.setFloatAttribute("capacity_multiplier", 0.7);
				//f2.setFloatAttribute("ai_accuracy", 0.85);
				//f2.setIntAttribute("lose_without_bases", 1);
				//command.appendChild(f2);

				//m_metagame.getComms().send(command);
		//}
	}
	
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		checkBases(m_metagame);
    }
	
	void checkBases(Metagame@ metagame) {
		if (getBasesForFaction(m_metagame, 1) == 1) {
			end(); //win
		}	
		
		array<const XmlElement@> baseList = getBases(metagame);
		if (baseList.size() > 0) {
			for (uint i = 0; i < baseList.size(); ++i) {
				if (baseList[i].getIntAttribute("owner_id") == 0) {
					metagame.getComms().send("<command class='update_base' base_key='" + baseList[i].getStringAttribute("key") + "' capturable='0' />");
				}
			}
		}
	}

	// --------------------------------------------
	void update(float time)
		{
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			//end();	
		}
	}
	
	void end() {
		DefPhaseOverlord::end();
		//clearVisualTimer(m_metagame);
	}
};

// --------------------------------------------
class PhaseControllerOverlord_Axis : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected float m_enemySpawnCompensationFactor;
	protected bool m_started = false;

	protected uint m_currentPhaseIndex = 0;

	protected array<Phase@> m_phases;

	// --------------------------------------------
	PhaseControllerOverlord_Axis(GameModeInvasion@ metagame, float enemySpawnCompensationFactor) {
		@m_metagame = metagame;

		m_enemySpawnCompensationFactor = enemySpawnCompensationFactor;

		// reset here initially
		// - continue: reset -> load -> game_continue_pre_start
		// - start: reset -> reset -> start
		// - restart: reset -> reset -> start, reset -> start
		reset();
	}

	// --------------------------------------------
	void reset() {
		m_phases = array<Phase@>();
		
		m_phases.insertLast(DefPhase0Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase1Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase2Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase3Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase4Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase5Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase6Overlord(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase7Overlord(m_metagame, this, m_enemySpawnCompensationFactor));

		m_currentPhaseIndex = 0;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		_log("starting PhaseControllerOverlord tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
		// on_game_continue_pre_start happens before start

		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void start() {
		// call reset here, phases and targets are initialized fresh
		// - helps with handling restart_map
		reset();

		_log("starting PhaseControllerOverlord tracker, phase=" + m_currentPhaseIndex);

		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void phaseEnded() {
		// advance to next phase
		m_currentPhaseIndex += 1;
		if (m_currentPhaseIndex < m_phases.size()) {
			startCurrentPhase();
		} else {
			// finished, no more phases left
			completeMatch();
		}
	}

	// --------------------------------------------
	protected void completeMatch() {
		m_metagame.getComms().send("<command class='set_match_status' faction_id='1' lose='1' />");
		m_metagame.getComms().send("<command class='set_match_status' faction_id='0' win='1' />");
	}

	// --------------------------------------------
	void startCurrentPhase() {
		if (m_currentPhaseIndex < m_phases.size()) {
			Phase@ phase = m_phases[m_currentPhaseIndex];

			m_metagame.addTracker(phase);
		}
	}

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// --------------------------------------------
	protected void handleFactionLoseEvent(const XmlElement@ event) {
		// if lost a battle, start over
		int factionId = -1;

		const XmlElement@ loseCondition = event.getFirstElementByTagName("lose_condition");
		if (loseCondition !is null) {
			factionId = loseCondition.getIntAttribute("faction_id");
		}

		if (factionId == 0) {
			// friendly faction lost
			// - mark this tracker not started so that it will be added again when map restarts
			m_metagame.removeTracker(this);
			m_started = false;
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		// store which phase we've reached
		// and let phase store additional stuff
		XmlElement@ parent = root;
		XmlElement subroot("map_phase_controller_overlord");

		subroot.setIntAttribute("phase_index", m_currentPhaseIndex);

		if (m_currentPhaseIndex < m_phases.size()) {
			m_phases[m_currentPhaseIndex].save(subroot);
		}

		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		const XmlElement@ controllerElement = root.getFirstElementByTagName("map_phase_controller_overlord");
		// map completion makes the stage use generic completed stage which gets saved, but at load
		// phase we are still loading the real stage.. verify the data is ok before processing it
		if (controllerElement !is null) {
			const XmlElement@ subroot = controllerElement;

			m_currentPhaseIndex = subroot.getIntAttribute("phase_index");
			if (m_currentPhaseIndex < m_phases.size()) {
				m_phases[m_currentPhaseIndex].load(subroot);
			}
		} 
	}

    // ----------------------------------------------------
    protected void handleChatEvent(const XmlElement@ event) {
		Tracker::handleChatEvent(event);

		// player_id
		// player_name
		// message
		// global

		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

		if (checkCommand(message, "end_phase")) {
			Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.end();
		}
	}
}