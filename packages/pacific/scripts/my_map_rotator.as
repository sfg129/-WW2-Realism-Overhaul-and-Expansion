#include "map_rotator_campaign.as"

// --------------------------------------------
class StageUnlockRule {
	array<string> m_stagesToComplete;
	array<string> m_stagesToUnlock;

	// --------------------------------------------
	StageUnlockRule(const array<string>@ stagesToComplete, const array<string>@ stagesToUnlock) {
		// copy
		m_stagesToComplete = stagesToComplete;
		m_stagesToUnlock = stagesToUnlock;
	}
};

// --------------------------------------------
class MyMapRotator : MapRotatorCampaign {
	protected array<StageUnlockRule@> m_stageUnlockRules;

	// --------------------------------------------
	MyMapRotator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	void addStageUnlockRule(StageUnlockRule@ rule) {
		m_stageUnlockRules.insertLast(rule);
	}
	
	// --------------------------------------------
	protected void announceMapStart() {
		// happens when a map has changed and the match starts

		// regular map
		if (!isStageCompleted(m_currentStageIndex)) {
			MyStage@ stage = cast<MyStage@>(m_stages[m_currentStageIndex]);

			// commander says something
			if (stage !is null) {
				stage.announceStart(m_metagame);
			}
		} else {
			// completed, assuming friendly for now
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 0.0, 0, "map start with completed map"));
		}

		// finally enable "in game commander" radio, battle and event reports
		m_metagame.getTaskSequencer().add(CallFloat(CALL_FLOAT(this.setCommanderAiReports), 1.0));
	}

	// --------------------------------------------
	protected bool checkForFinalBattleUnlock() {
		// make vanilla final battle unlock into a stub, at least for now
		return false;
	}

	// --------------------------------------------
	protected void readyToAdvance() {
		MapRotatorCampaign::readyToAdvance();

		// use a more generic stage unlock in Pacific
		if (checkForStageUnlock()) {
			// we just unlocked something, re-determine extraction points, might be in this map
			determineExtractionHitboxList();
			refreshHitboxes();

			if (m_world !is null) {
				m_world.refresh(m_stages, m_stagesCompleted, m_currentStageIndex);
			}
		}
	}

	// -------------------------------------------------------
	protected void commitToMapChange(int index) {
		MapRotatorCampaign::commitToMapChange(index);

		// commitToMapChange will set soundtrack for extraction music,
		// notify our music tracker that its soundtrack will end now, possibly
		MyGameMode@ gamemode = cast<MyGameMode@>(m_metagame);
		if (gamemode !is null) {
			gamemode.onSoundtrackChanged();
		}
	}

	// --------------------------------------------
	protected bool checkForStageUnlock() {
		_log("checkForStageUnlock");
		bool changed = false;

		for (uint i = 0; i < m_stageUnlockRules.size(); ++i) {
			const StageUnlockRule@ rule = m_stageUnlockRules[i];

			bool unlock = true;
			_log("checking rule " + i);
			for (uint j = 0; j < rule.m_stagesToComplete.size(); ++j) {
				string mapId = rule.m_stagesToComplete[j];

				int stageIndex = getStageIndex(mapId);
				_log("checking stage requirement " + j + " " + mapId + ", stage index=" + stageIndex);				
				if (stageIndex >= 0) {
					if (isStageCompleted(stageIndex)) {
						_log("completed, check next if any");
					} else {
						// this one not completed, can't unlock yet
						_log("not completed, can't unlock");
						unlock = false;
						break;
					}
				} else {
					_log("ERROR, couldn't find stage index for " + mapId);
				}
			}

			if (unlock) {
				_log("can unlock");
				for (uint j = 0; j < rule.m_stagesToUnlock.size(); ++j) {
					string mapId = rule.m_stagesToUnlock[j];
					
					int stageIndex = getStageIndex(mapId);
					_log("checking stage unlock " + j + " " + mapId + ", stage index=" + stageIndex);				
					if (stageIndex >= 0) {
						Stage@ stage = m_stages[stageIndex];
						if (stage.m_hidden) {
							_log("unlocking stage " + stageIndex + ", " + mapId);
							unlockStage(stage);
							changed = true;
						} else {
							_log("stage already unlocked");				
						}
					} else {
						_log("ERROR, couldn't find stage index for " + mapId);
					}
				}
			}
		}

		return changed;
	}

	// --------------------------------------------
	protected void unlockStage(Stage@ stage) {
		stage.m_hidden = false;
	}

	// -------------------------------------------------------
	// copied from MapRotatorCampaign, added with denial of extraction to locked stages
	protected void determineExtractionHitboxList() {
		array<const XmlElement@> list;

		_log("determineExtractionHitboxList", 1);
		_log("current stage: " + m_currentStageIndex + ", completed=" + isStageCompleted(m_currentStageIndex), 1);

		bool finalBattleExtractionAvailable = false;
		// if current stage is a final stage, don't allow extraction until it's completed
		Stage@ currentStage = m_stages[m_currentStageIndex];
		if (!currentStage.isFinalBattle() || /* is final && */ isStageCompleted(m_currentStageIndex)) {
			list = getHitboxes(m_metagame);

			// go through the list and only leave the ones in we're interested of, extraction_*
			for (uint i = 0; i < list.size(); ++i) {
				const XmlElement@ hitboxNode = list[i];
				string id = hitboxNode.getStringAttribute("id");
				bool ruleOut = false;
				if (id.findFirst("extraction") < 0) {
					ruleOut = true;

				// - if the current map is completed, all exit points are ok
				// ----- EXCEPT exit points to final battle stages, which are ok additionally only once the final battle stage has been unlocked
				// - if the current map is not completed, only the exit points taking to a completed map are ok, check that
				} else if (!isStageCompleted(m_currentStageIndex)) {
					// current map not completed

					int stageIndex = getStageIndexFromExtractionHitboxId(id);
					if (!isStageCompleted(stageIndex)) {
						// the map this point takes to is not either
						ruleOut = true;
					} else {
						// this point takes to a completed map, it's ok
					}

				} else {
					// current stage completed, all exit points are fine

					// additionally check final battle stage unlock status
					int stageIndex = getStageIndexFromExtractionHitboxId(id);
					if (stageIndex < 0) {
						_log("WARNING, something wrong about " + id + ", not in transport map?", -1); 
						ruleOut = true;
					} else if (m_stages[stageIndex].m_hidden) {
						_log("stage " + stageIndex + " is hidden", 1); 
						ruleOut = true;
					} else if (m_stages[stageIndex].isFinalBattle()) {
						// target stage is final battle, check if it's unlocked
						int finalBattleIndex = getFinalBattleIndex(stageIndex);
						_log("stage " + stageIndex + " is final battle #" + finalBattleIndex, 1); 
						if (!isFinalBattleUnlocked(finalBattleIndex)) {
							_log("  is not unlocked", 1);
							// it's not, rule out
							ruleOut = true;
						} else {
							finalBattleExtractionAvailable = true;
							_log("  is unlocked", 1);
						}
					}
				}

				if (ruleOut) {
					_log("ruling out " + id, 1);
					// remove this
					list.erase(i);
					// one step back
					i--;
				} else {
					_log("including " + id, 1);
				}
			}
			_log("* " + list.size() + " extraction points found");
		}

		m_extractionHitboxes = list;

		// update map markers
		markExtractionPoints();

		// update world markers
		if (m_world !is null) {
			array<string> transports;
			dictionary@ transportMap;
			m_worldTransportMap.get(toWorldTransportMapKey(m_currentStageIndex), @transportMap);
			if (transportMap !is null) {
				string sourceMap = m_stages[m_currentStageIndex].m_mapInfo.m_id;
				for (uint i = 0; i < transportMap.getKeys().size(); ++i) {
					string hitboxId = transportMap.getKeys()[i];
					int targetStageIndex = 0;
					transportMap.get(hitboxId, targetStageIndex);
					// only show the hitboxes available that are among our accepted extraction hitboxes
					for (uint j = 0; j < m_extractionHitboxes.size(); ++j) {
						const XmlElement@ node = m_extractionHitboxes[j];
						string id = node.getStringAttribute("id");
						if (id == hitboxId) {
							string targetMap = m_stages[targetStageIndex].m_mapInfo.m_id;
							transports.insertLast(getTransportName(sourceMap, targetMap));
						}
					}
				}
			}
			m_world.setAvailableTransports(transports);
		}

		// enable decorative vehicles
		// if final battle extraction is available, enable helicopter 
		if (finalBattleExtractionAvailable)	{
			string command =
				"<command class='faction_resources' faction_id='0'>" +
				"   <vehicle key='heli_extraction.vehicle' enabled='1' />" + 
				"</command>";
			m_metagame.getComms().send(command);
		}
	}

	// --------------------------------------------
	void postProcessLoad() {
		// if current map is completed, refresh extraction points
		bool refresh = false;
		if (isStageCompleted(m_currentStageIndex)) {
			_log("current map is completed, refresh extraction hitboxes", 1);
			refresh = true;
		}

		if (checkForStageUnlock()) {
			refresh = true;
		}

		if (refresh) {
			determineExtractionHitboxList();
			refreshHitboxes();
			refreshCompletionStatus(false);

			if (m_world !is null) {
				m_world.refresh(m_stages, m_stagesCompleted, m_currentStageIndex);
			}
		}
	}

	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		// skip additional dialogue done in vanilla
	}
}
