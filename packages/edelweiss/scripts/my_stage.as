#include "stage_invasion.as"

// --------------------------------------------
class Comment {
	string m_key;
	float m_duration;

	// --------------------------------------------
	Comment(string key, float duration) {
		m_key = key;
		m_duration = duration;
	}
}

// --------------------------------------------
class MyStage : Stage {
	bool m_useCustomTimerMode;

	protected array<Comment@> m_startComments;

	bool m_showMapAtStartIfDead;
	bool m_useCaptureTimer;
	Vector3 m_playerFirstSpawnPositionHint;

	// --------------------------------------------
	MyStage(const UserSettings@ userSettings) {
		super(userSettings);
		m_useCustomTimerMode = false;
		
		m_showMapAtStartIfDead = true;
		m_useCaptureTimer = true;
		m_playerFirstSpawnPositionHint = Vector3(-1,-1,-1);
	}

	// --------------------------------------------
	protected void appendScene(XmlElement@ mapConfig) const {
		XmlElement scene("scene");
		appendCamera(scene);
		appendFog(scene);
		appendCharacter(scene);
		mapConfig.appendChild(scene); 
	}

	// --------------------------------------------
	protected void appendCharacter(XmlElement@ scene) const {
		XmlElement character("character");
		character.setFloatAttribute("voxel_size", 0.53);
		scene.appendChild(character);
	}

	// --------------------------------------------
	void addStartComment(Comment@ comment) {
		m_startComments.push_back(comment);
	}
	
	// --------------------------------------------
	void announceStart(Metagame@ metagame) {
		dictionary a = {
			{"%map_name", m_mapInfo.m_name},
			{"%faction_name", m_factions.size() >= 2 ? m_factions[1].m_config.m_name : ""}
		};

		for (uint i = 0; i < m_startComments.size(); ++i) {
			Comment@ comment = m_startComments[i];
			metagame.getTaskSequencer().add(AnnounceTask(metagame, comment.m_duration, 0, comment.m_key, a));
		}
	}

	// --------------------------------------------
	void transformCompleted() {
		m_maxSoldiers = 40;
		// leave only the first faction
		while (m_factions.size() > 1) {
			m_factions.removeLast();
		}

		// remove certain types of trackers when map completion happens
		// so they won't be there when coming back to the map
		for (int i = 0; i < int(m_trackers.size()); ++i) {
			Tracker@ t = m_trackers[i];

			Spawner@ spawner = cast<Spawner@>(t);
			if (spawner !is null) {
				m_trackers.removeAt(i);
				i--;
			}
		}
	}

	// --------------------------------------------
	const XmlElement@ getStartGameCommand(GameModeInvasion@ metagame, float completionPercentage = 0.5) const {
		const XmlElement@ c = Stage::getStartGameCommand(metagame, completionPercentage);
		XmlElement command(c.toDictionary()); // copy to remove const
		if (m_useCustomTimerMode) {
			command.setStringAttribute("defense_win_time_mode", "custom");
		}
		
		command.setBoolAttribute("show_map_at_start_if_dead", m_showMapAtStartIfDead);
		command.setBoolAttribute("run_init_match_commands", false);

		// extend vanilla way of handling owned bases to work better with initially fully designated maps
		{
			array<const XmlElement@>@ factions = command.getElementsByTagName("faction");
			// remove factions
			for (uint i = 0; i < factions.size(); ++i) {
				command.removeChild("faction");
			}

			// then edit and add
			for (uint i = 0; i < factions.size(); ++i) {
				XmlElement faction(factions[i].toDictionary()); // copy to remove const

				Faction@ f = m_factions[i];
				faction.setBoolAttribute("capture_by_timer", m_useCaptureTimer);
				
				if (f.m_ownedBases.size() > 0) {
					faction.setIntAttribute("initial_occupied_bases", f.m_ownedBases.size());
				} else if (f.m_bases >= 0) {
					faction.setIntAttribute("initial_occupied_bases", f.m_bases);
				} else {
					faction.setIntAttribute("initial_occupied_bases", 0);
				}

				// add player first spawn position hint here
				if (i == 0) {
					faction.setStringAttribute("player_first_spawn_position_hint", m_playerFirstSpawnPositionHint.toString());
				}
				
				for (uint j = 0; j < f.m_ownedBases.size(); ++j) {
					XmlElement base("base");
					base.setIntAttribute("id", f.m_ownedBases[j]);
					faction.appendChild(base);
				}
				command.appendChild(faction);
			}
		}

		return command;
	}

}

// --------------------------------------------
class MyPhasedStage : MyStage {
	protected PhaseController@ m_phaseController;

	// --------------------------------------------
	MyPhasedStage(const UserSettings@ userSettings) {
		super(userSettings);
	}

	// --------------------------------------------
	void setPhaseController(PhaseController@ phaseController) {
		@m_phaseController = @phaseController;
		addTracker(m_phaseController);
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		if (m_phaseController !is null) {
			m_phaseController.save(root);
		}
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		if (m_phaseController !is null) {
			m_phaseController.load(root);
		}
	}

	// --------------------------------------------
	void transformCompleted() {
		MyStage::transformCompleted();

		if (m_phaseController !is null) {
			int index = m_trackers.findByRef(m_phaseController);
			if (index >= 0) {
				m_trackers.removeAt(index);
			}

			// forget phases
			@m_phaseController = null;
		}
	}
}
