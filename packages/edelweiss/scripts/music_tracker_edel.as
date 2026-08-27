#include "tracker.as"
#include "gamemode.as"
#include "helpers.as"
#include "time_announcer_task.as"
#include "phase_controller.as"
#include "query_helpers.as"
#include "stage_configurator_invasion.as"
#include "basic_command_handler.as"
#include "user_settings.as"
#include "map_rotator_campaign.as"

// ----------
// -- Much of this code is not in use, nor is the music available.
// -- However the "victory music" handling is still done through this script, and remains enabled.
// ---------

// --------------------------------------------
class Music_Tracker : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected float m_timer = 28.45;
	protected int m_ch = 0;
	protected int m_ch_victory = 0;
	int isMatchEnd = 0;
	int factionLost = -1;
	int randomMusicSelection;
	int randomMusicTimeChange;
	string chosenCue;
	string m_lastSoundtrack = "";
	
	bool hasStarted() const {
      return true; 
	}
	
	bool hasEnded() const {
		// always on
		return false;
	}
	
	Music_Tracker(GameModeInvasion@ metagame) {
		@m_metagame = @metagame;
		
		reset();
	}

	// --------------------------------------------
	void reset() {
		if (m_lastSoundtrack != "") {
			stopLastSoundtrack();
		}
		m_timer = 28.45;
		m_ch = 0;
		m_ch_victory = 0;
		isMatchEnd = 0;
		m_lastSoundtrack = "";

		const UserSettings@ settings = m_metagame.getUserSettings();
		factionLost = settings.m_factionChoice;
	}

	// --------------------------------------------
	void onExternalSoundtrackChanged() {		
		if (m_timer >= 0 && m_ch_victory == 1) {
			resetVictorySoundtrackTimer();
		}
	}

	// --------------------------------------------
	protected void resetVictorySoundtrackTimer() {
		isMatchEnd = 0;
		m_ch_victory = 2;
	}
		
	protected void handleMatchEndEvent(const XmlElement@ event) {
		isMatchEnd = 1;
		m_ch_victory = 0;
	}
	
	string handleRandomMusicCue(int cueNumber) {
		int i = cueNumber;
		array<string> musicTrackNames;
		//musicTrackNames = loadStringsFromFile(m_metagame, "music.xml");
		
		musicTrackNames.push_back("mus_perc_01");
		musicTrackNames.push_back("mus_perc_01_w_snare");
		
		//etc I cut these from Edel cuz useless

		return musicTrackNames[i];
	}

	void playSoundtrack(string filename) {
		m_lastSoundtrack = filename;
		
		m_metagame.getComms().send(
		"<command " +
		" class='set_soundtrack' " + 
		" enabled='1' " + 
		" filename='" + filename + "'" + 
		" />");
	}

	void stopLastSoundtrack() {
		m_metagame.getComms().send(
		"<command " +
		" class='set_soundtrack' " + 
		" enabled='0' " + 
		" filename='" + m_lastSoundtrack + "'" + 
		" />");
	}

	void update(float time) {
		// _log("Music_Tracker_Edel::update, time=" + time + ", m_timer=" + m_timer + ", isMatchEnd=" + isMatchEnd + ", factionLost=" + factionLost);
	
		if (isMatchEnd == 1) {
			// --can type /0_win to hear victory music
			
			if (factionLost == 0 && m_ch_victory == 0) {
				//factionLost really is just factionChoice, dunno why it's called Lost
				//both 0 = Allies winning in Allied campaign
				//factionLost= 1 and ch_victory = 0 = Axis winning in Axis campaign
				string id = m_metagame.getMapInfo().m_id;
				// first set filename and timer to some default values
				string filename = "mus_victory_usf_paratroopers.wav";
				m_timer = 51;
				// then override if there's a specific variant
				//timer lengths for cues: 47 for USF Para, 38 for UKF, 24 for PL, 25 for WH/Axis, 46 for End of War
				if (id == "edelweiss3") {
					m_timer = 27;
					filename = "mus_victory_pl.wav";
				} else if (id == "edelweiss4") {
					m_timer = 43;
					filename = "mus_victory_ukf.wav";
				} else if (id == "edelweiss5") {
					m_timer = 43;
					filename = "mus_victory_ukf.wav";
				} else if (id == "edelweiss7") {
					m_timer = 48;
					filename = "mus_victory_end_of_war_allied.wav";
				}
				
				playSoundtrack(filename);
				m_ch_victory++;
			}
				
			if (factionLost == 1 && m_ch_victory == 0) {
				//factionLost really is just factionChoice, dunno why it's called Lost
				//both 0 = Allies winning in Allied campaign
				//factionLost= 1 and ch_victory = 0 = Axis winning in Axis campaign
				string id = m_metagame.getMapInfo().m_id;
				// first set filename and timer to some default values
				string filename = "mus_victory_wh.wav";
				m_timer = 27;
				// then override if there's a specific variant
				//timer lengths for cues: 47 for USF Para, 38 for UKF, 24 for PL, 25 for WH/Axis, 46 for End of War
				//, mus_victory_end_of_war_axis
				if (id == "edelweiss8") {
					m_timer = 49;
					filename = "mus_victory_end_of_war_axis.wav";
				}
			
				playSoundtrack(filename);
				m_ch_victory++;	
			}

			m_timer -= time;
			//factionLost = -1;
			
			if (m_timer <= 0 && m_ch_victory == 1){
				resetVictorySoundtrackTimer();
				stopLastSoundtrack();
			}
		}
 
		/// ----------------------------------------------------
		/// -- FOR NOW ALL LOOPING MUSIC IS DISABLED BY THIS *
		/// -- Removing the /* will re-enable the old music code.
		/// -----------------------------------------------------
		/*	
		if(isMatchEnd <= 0){
				


			m_timer -= time;    
			
			if (m_timer <= 28.45 && m_ch==0) {
			
				// --basically, 33% of the time we'll change cues more often, producing a greater sense of variation
				randomMusicTimeChange = rand(0,2);
				if(randomMusicTimeChange == 0){
				m_timer = 14.52;
				}
				
				randomMusicSelection = rand(0,42);
				chosenCue = handleRandomMusicCue(randomMusicSelection);
				
				sendFactionMessage(m_metagame, 0, "Attempting to launch music cue, choice is #" + randomMusicSelection + ", " + chosenCue, 1.0);
				sendFactionMessage(m_metagame, 1, "Attempting to launch music cue, choice is #" + randomMusicSelection + ", " + chosenCue, 1.0);

				m_metagame.getComms().send(
				"<command " +
				" class='set_soundtrack' " + 
				" enabled='1' " + 
				" filename='" + chosenCue + ".wav'" + 
				"</command>");
				// _log("Music_Tracker_Edel::play new cue");
				
				m_ch++;
			}
			if (m_timer <= 0.0 && m_ch==1) {
				sendFactionMessage(m_metagame, 0, "looping music", 1.0);
				sendFactionMessage(m_metagame, 1, "looping music", 1.0);
			
				m_timer = 28.45;
				m_ch = 0;
			}	
		}*/
	}
	
	
	// --huge wall of chat events to trigger cues if needed or wanted
	protected void handleChatEvent(const XmlElement@ event) {
		Tracker::handleChatEvent(event);

		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");

		if (checkCommand(message, "mus_0")) {
				chosenCue = handleRandomMusicCue(0);
				m_metagame.getComms().send(
				"<command " +
				" class='set_soundtrack' " + 
				" enabled='1' " + 
				" filename='" + chosenCue + ".wav'" + 
				" />");
		}		
	}
}





	
