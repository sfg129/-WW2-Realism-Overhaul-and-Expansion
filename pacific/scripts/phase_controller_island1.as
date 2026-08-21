#include "tracker.as"
#include "phase_controller.as"
#include "time_announcer_task.as"
#include "query_helpers.as"
#include "resource_helpers.as"
#include "call_sorting.as"
#include "helpers2.as"

// --------------------------------------------
void spawn(Metagame@ metagame, uint count, uint factionId, Vector3 position, string instanceKey) {
	for (uint i = 0; i < count; ++i) {
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position.toString() + "' " + 
		" offset='0 0 0' " +
		" instance_class='soldier' " + 
		" instance_key='" + instanceKey + "'> " + 
		"</command>");
	}
}

// --------------------------------------------
void spawn(Metagame@ metagame, uint count, uint factionId, Vector3 position1, Vector3 position2, string instanceKey) {
	spawn(metagame, count, factionId, position1, instanceKey);
	spawn(metagame, count, factionId, position2, instanceKey);
}

// --------------------------------------------
const Vector3 EAST_POSITION = Vector3(541, 6, 122);
const Vector3 WEST_POSITION = Vector3(429, 6, 148);

// --------------------------------------------
class Phase : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected PhaseController@ m_controller;
	protected bool m_started;
	protected bool m_ended;

	// --------------------------------------------
	Phase(GameModeInvasion@ metagame, PhaseController@ controller) {
		@m_metagame = @metagame;
		@m_controller = @controller;
		m_started = false;
		m_ended = false;
	}

	// --------------------------------------------
	void start() {
		m_started = true;
	}

	// --------------------------------------------
	void end() {
		Tracker::end();
		m_controller.phaseEnded();
		m_ended = true; // metagame will check has_ended, and will remove the phase from processing if it has ended
	}

	// --------------------------------------------
	void onRemove() {
		m_started = false;
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_ended;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
	}
};

// --------------------------------------------
class DefPhase : Phase {
	protected float m_enemySpawnCompensationFactor;
	// --------------------------------------------
	DefPhase(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller);
		m_enemySpawnCompensationFactor = enemySpawnCompensationFactor;
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
		m_metagame.getComms().send("<command class='create_call' key='special_inf.call' position='476 6 138' faction_id='1'/>");
	}
	protected void spawn_special2() {
		m_metagame.getComms().send("<command class='create_call' key='special_inf.call' position='476 6 138' faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='special_inf.call' position='476 6 138' faction_id='1'/>");
	}
	protected void spawn_special3() {
		m_metagame.getComms().send("<command class='create_call' key='special_inf.call' position='476 6 138' faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='special_inf.call' position='476 6 138' faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='special_inf.call' position='476 6 138' faction_id='1'/>");
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
        //announce("about to begin");
				
		array<Resource@> resources = { 
			Resource("mortar1.call", "call"),
			Resource("artillery.call", "call"),
			Resource("artillery1.call", "call") 
		};
		resetFactionCallResources(m_metagame, 0, resources, false, getCallSorting());
		
/*		
				//set up this map
		{
			XmlElement command("command");
			//command.setStringAttribute("class", "start_game");
			//command.setStringAttribute("savegame", m_metagame.getUserSettings().m_savegame);
			//command.setIntAttribute("vehicles", 1);
			//command.setIntAttribute("max_soldiers", 150);
			//command.setFloatAttribute("soldier_capacity_variance", 0.3);	// --i have no idea what this does
			//command.setFloatAttribute("player_ai_compensation", 0);
			//command.setFloatAttribute("player_ai_reduction", 0);
			//command.setFloatAttribute("xp_multiplier", 1.0);
			//command.setFloatAttribute("rp_multiplier", 1.0);
			//command.setFloatAttribute("initial_xp", 0.0);
			//command.setFloatAttribute("initial_rp", 0);
			//command.setStringAttribute("base_capture_system", "any");
			// --command.setStringAttribute("soldier_capacity_model", "constant");
			
			XmlElement f1("faction");
			//f1.setFloatAttribute("initial_over_capacity", 0);
			//f1.setFloatAttribute("ai_accuracy", 0.95);
			//f1.setFloatAttribute("capacity_multiplier", 0.45);
			//f1.setIntAttribute("lose_without_bases", 1);
			command.appendChild(f1);

			XmlElement f2("faction");
			//f2.setFloatAttribute("initial_over_capacity", 0);
			//f2.setFloatAttribute("ai_accuracy", 0.7);
			//f2.setFloatAttribute("capacity_multiplier", 0.2);
			//f2.setIntAttribute("lose_without_bases", 1);
			command.appendChild(f2);

			XmlElement player("local_player");
			player.setIntAttribute("faction_id", 0);
			player.setStringAttribute("username", m_metagame.getUserSettings().m_username);
			command.appendChild(player);

			m_metagame.getComms().send(command);
			//m_metagame.getComms().send("<command class='update_base' base_key='Outpost' capturable='0' />");	// can't take Outpost from the Attackers and outright win
		}
*/		
/*
			{
				const XmlElement@ player = getPlayerInfo(m_metagame, 0);
				if (player !is null) {
					string username = player.getStringAttribute("name");
					// add local player as admin for easy testing, hacks, etc
					if (!m_metagame.getAdminManager().isAdmin(username)) {
						m_metagame.getAdminManager().addAdmin(username);
					}
				}
			}
*/

		{
			m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.2' border_defense='0.3' />");
			m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.5' border_defense='0.0' />");
		}
			
		m_timer = 1.0 * 60.0;
		 m_metagame.getComms().send("<command class='create_call' key='vehicle_m3_mortar.call' position='313 5 414' faction_id='0' />");
				m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='506 5 404' faction_id='0' />");
				 m_metagame.getComms().send("<command class='create_call' key='usf_vehicle_armoury_marine.call' position='506 5 404' faction_id='0' />");
	spawn(5, 0, Vector3(489, 5.88, 389), "regular");
	spawn(5, 0, Vector3(492, 5.88, 389), "regular");
	spawn(5, 0, Vector3(300, 5, 439), "regular");
	spawn(5, 0, Vector3(296, 5, 439), "regular");
				 m_metagame.getComms().send("<command class='create_call' key='light_mortar.call' position='489 5.88 389' faction_id='0' rotation='0 90 0' />");

			  	 m_metagame.getComms().send("<command class='create_call' key='light_mortar.call' position='492 5.88 389' faction_id='0' rotation='0 0 0'/>");
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
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 1"));
		}
		if (m_timer < 55.0 && m_ch==2){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 2"));
		}
		if (m_timer < 50.0 && m_ch==3){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 3"));
		}
		if (m_timer < 45.0 and m_ch==4){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 4"));
		}
		if (m_timer < 40.0 and m_ch==5){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 5"));
		}
		if (m_timer < 35.0 and m_ch==6){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 6"));
		}
		if (m_timer < 7.0 and m_ch==7){
			m_ch++;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal intro, part 7"));
		}
	}
	
	void end() {
		DefPhase::end();
		//clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
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
		
		
		m_timer = 5.0 * 60.0;


		setVisualTimer(m_metagame, m_timer);
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 1"));
		
		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='490 6 318' faction_id='1' />");
		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='490 6 318' faction_id='1' />");
		
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
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='460 6 185' instance_class='vehicle' instance_tag='jeep'/>");
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
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='460 6 185' instance_class='vehicle' instance_tag='jeep'/>");
			/////////////////
			// WEST SPAWNS //
			/////////////////
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='509 6 187' instance_class='vehicle' instance_tag='jeep'/>");
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='520 6 187' instance_class='vehicle' instance_tag='jeep'/>");
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
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
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
		
		
		m_timer = 5.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);

		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 2"));
		
		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='499 6 372' faction_id='1' />");
		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='499 6 372' faction_id='1' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='1.0' />\n" +
			"</command>");
			
		/////////////////
		// WEST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='509 6 187' instance_class='vehicle' instance_tag='jeep'/>");
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='520 6 187' instance_class='vehicle' instance_tag='jeep'/>");
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
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='460 6 185' instance_class='vehicle' instance_tag='jeep'/>");
			m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='473 6 184' instance_class='vehicle' instance_tag='jeep'/>");
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
		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='499 6 372' faction_id='1' />");
		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='499 6 372' faction_id='1' />");

		}
	}
	
	void end() {
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase3 : DefPhase {
	protected float m_timer = 0.0;
	protected int m_ch=0;
	// --------------------------------------------
	DefPhase3(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
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
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 3"));
		
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
		m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
		
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
			m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
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
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase4 : DefPhase {
	protected float m_timer = 0.0;
	protected int m_ch=0;
	// --------------------------------------------
	DefPhase4(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase4 starting");
		
		m_timer = 6.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);		

		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 4"));
		
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
		m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
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
			m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='509 6 187' faction_id='1' />");
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
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase5 : DefPhase {
	protected float m_timer = 0.0;
	// --------------------------------------------
	DefPhase5(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase5 starting");
		m_metagame.getComms().send("<command class='create_call' key='ija_vehicle_medium_tank_chi_ha_early.call' position='489 5.88 389' faction_id='1' />");
		m_metagame.getComms().send("<command class='create_call' key='usmc_vehicle2.call' position='506 5 404' faction_id='0' />");
		m_timer = 2.0 * 60.0;

				
		//setVisualTimer(m_metagame, m_timer);	
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 5"));

		m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='505 6 500' faction_id='1' />");
m_metagame.getComms().send("<command class='create_call' key='mortar1.call' position='490 6 318' faction_id='1' />");
		
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
		m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='460 6 185' faction_id='1' />");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='473 6 184' faction_id='1' />");
		//m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='730 3 222' faction_id='1' />");
		/////////////////
		// WEST SPAWNS //
		/////////////////
		m_metagame.getComms().send("<command class='create_call' key='light_tank.call' position='509 6 187' faction_id='1' />");
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
		DefPhase::end();
		//clearVisualTimer(m_metagame);
	}
};

// --------------------------------------------
class DefPhase6 : DefPhase {
	protected float m_timer = 0.0;
	protected int m_ch=0;
	// --------------------------------------------
	DefPhase6(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase6 starting");
				
		m_timer = 5.0 * 60.0;
		setVisualTimer(m_metagame, m_timer);	
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 6"));
		
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
		DefPhase::end();
		clearVisualTimer(m_metagame);
	}

};

// --------------------------------------------
class DefPhase7 : DefPhase {
	protected float m_timer = 0.0;
	// --------------------------------------------
	DefPhase7(GameModeInvasion@ metagame, PhaseController@ controller, float enemySpawnCompensationFactor) {
		super(metagame, controller, enemySpawnCompensationFactor);
	}
	// --------------------------------------------
	void start() {
		DefPhase::start();
		_log("Phase7 starting");
				 m_metagame.getComms().send("<command class='create_call' key='usmc_vehicle2.call' position='506 5 404' faction_id='0' />");
		m_timer = 2.0 * 60.0;
				
				 
		//setVisualTimer(m_metagame, m_timer);	
		
		array<Resource@> resources = { 
			
			Resource("airstrike3.call", "call"),
			Resource("artillery.call", "call"),
			Resource("artillery1.call", "call") 
			
		};
		resetFactionCallResources(m_metagame, 0, resources, true, getCallSorting());
		
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 7"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, "guadalcanal stage 8"));
		
		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.75' border_defense='0.15' attack_start_spread='4' attack_target_spread='4'/>");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>\n" + 
			"  <parameter class='willingness_to_charge' value='0.0' />\n" +
			"</command>");
		// set enemy home base to capturable
		m_metagame.getComms().send("<command class='update_base' base_key='Outpost' capturable='1' />");

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
		DefPhase::end();
		//clearVisualTimer(m_metagame);
	}
};

// --------------------------------------------
class PhaseControllerIsland1 : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected float m_enemySpawnCompensationFactor;
	protected bool m_started = false;

	protected uint m_currentPhaseIndex = 0;

	protected array<Phase@> m_phases;

	// --------------------------------------------
	PhaseControllerIsland1(GameModeInvasion@ metagame, float enemySpawnCompensationFactor) {
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
		
		m_phases.insertLast(DefPhase0(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase1(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase2(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase3(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase4(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase5(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase6(m_metagame, this, m_enemySpawnCompensationFactor));
		m_phases.insertLast(DefPhase7(m_metagame, this, m_enemySpawnCompensationFactor));

		m_currentPhaseIndex = 0;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		_log("starting PhaseControllerIsland1 tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
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

		_log("starting PhaseControllerIsland1 tracker, phase=" + m_currentPhaseIndex);

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
		XmlElement subroot("map_phase_controller_island1");

		subroot.setIntAttribute("phase_index", m_currentPhaseIndex);

		if (m_currentPhaseIndex < m_phases.size()) {
			m_phases[m_currentPhaseIndex].save(subroot);
		}

		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		const XmlElement@ controllerElement = root.getFirstElementByTagName("map_phase_controller_island1");
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
	
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
        // base_id
        // owner_id (faction)
		array<const XmlElement@> baseList = getBases(m_metagame);
		bool ownsWestTrench = false;
		bool ownsCenterTrench = false;
		bool ownsEasternTrench = false;
		bool ownsMedical = false;
		bool ownsBarracks = false;
		bool ownsAirStrip = false;
		
		if (m_currentPhaseIndex == 8){
			if (baseList.size() > 0) 
			{
				for (uint i = 0; i < baseList.size(); ++i) 
				{
					const XmlElement@ base = baseList[i];
					string currentBaseName = base.getStringAttribute("key");
					int currentBaseOwner = base.getIntAttribute("owner_id");
				
					_log("base name is " + currentBaseName + " owned by " + currentBaseOwner);
					//base names for this map: Outpost (Attacking team's carrier), Western Trench Line, Center Trench Line, Eastern Trench Line, Medical Station, Barracks, Air Strip
					if (currentBaseName == "Western Trench Line" && currentBaseOwner == 0)
					{
						m_metagame.getComms().send("<command class='update_base' base_key='Western Trench Line' capturable='0' />");
						ownsWestTrench = true;
					}
					if (currentBaseName == "Center Trench Line" && currentBaseOwner == 0)
					{
						m_metagame.getComms().send("<command class='update_base' base_key='Center Trench Line' capturable='0' />");
						ownsCenterTrench = true;
					}
					if (currentBaseName == "Eastern Trench Line" && currentBaseOwner == 0)
					{
						m_metagame.getComms().send("<command class='update_base' base_key='Eastern Trench Line' capturable='0' />");
						ownsEasternTrench = true;
					}
					if (currentBaseName == "Medical Station" && currentBaseOwner == 0)
					{
						m_metagame.getComms().send("<command class='update_base' base_key='Medical Station' capturable='0' />");
						ownsMedical = true;
					}
					if (currentBaseName == "Barracks" && currentBaseOwner == 0)
					{
						m_metagame.getComms().send("<command class='update_base' base_key='Barracks' capturable='0' />");			
						ownsBarracks = true;
					}
					if (currentBaseName == "Air Strip" && currentBaseOwner == 0)
					{
						m_metagame.getComms().send("<command class='update_base' base_key='Air Strip' capturable='0' />");	// you've won, just take the island; stragglers can't attack your Air Strip.
						ownsAirStrip = true;
					}
					
				}	
			}
			if (ownsWestTrench == true && ownsCenterTrench == true && ownsEasternTrench == true && ownsMedical == true && ownsBarracks == true && ownsAirStrip == true)
			{
				completeMatch();	//win
			}
		}
    }
}
