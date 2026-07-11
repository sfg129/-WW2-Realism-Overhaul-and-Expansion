// internal
#include "resource_unlocker.as"

// ----------------------------------------------------
class MyResourceUnlocker : ResourceUnlocker {
	protected GameMode@ m_gameMode;
	protected dictionary m_customizations;
	protected dictionary m_firemodes;
	
	// ----------------------------------------------------
	MyResourceUnlocker(GameMode@ gamemode, int factionId, const dictionary@ unlockList, const dictionary@ customizations, const dictionary@ firemodes, UnlockListener@ listener, string customStatTag = "", string thanks = "") {
		@m_gameMode = @gamemode;
		super(gamemode, factionId, unlockList, listener, customStatTag, thanks);
		
		m_customizations = customizations; // copy
		m_firemodes = firemodes; // copy
	}

	// ----------------------------------------------------
	protected Resource@ pickRewardItem(const array<Resource@>@ inputMasterList) const {
		applyCustomization(inputMasterList);
		return ResourceUnlocker::pickRewardItem(inputMasterList);
	}
	
	// ----------------------------------------------------
	bool handleItemDeliveryCompleted(const Resource@ item, int characterId = -1, int playerId = -1) {
		_log("handle_item_delivery_completed", 1);

		bool result = false;
	
		// link delivered item to a resource unlock:
		const Resource@ unlock = getUnlock(item);

		if (unlock !is null) {
			if (m_thanks != "" && playerId != -1) {
				sendPrivateMessageKey(m_metagame, playerId, m_thanks);
				sleep(1.0f);
			}
		
			result = true;
			_log("* item delivery completed, picking unlock for " + item.m_key + " (" + item.m_type + "): " + unlock.m_key + " (" + unlock.m_type + ")", 1);
			// enable a resource for the faction
			array<string> groupsChanged;
			changeFactionResources(m_metagame, m_factionId, array<const Resource@> = {unlock}, true, groupsChanged);

			// query for unlock name
			string name = getResourceName(m_metagame, unlock.m_key, unlock.m_type);
			if (name != "") {
				dictionary a = {
					{"%resource_name", name}
				};
				string textKey = getResourceAvailabilityTextKey("resource added in stock", groupsChanged);
				sendFactionMessageKey(m_metagame, m_factionId, textKey, a, 1.0);
			}

			// unlocks are lost over time, but they must carry over map changes
			// announce to metagame that we've unlocked something now, it'll handle that part
			m_listener.itemUnlocked(unlock);

			if (characterId >= 0 && m_customStatTag != "") {
				string c = "<command class='add_custom_stat' character_id='" + characterId + "' tag='" + m_customStatTag + "' />";
				m_metagame.getComms().send(c);
			}
			
			//checking if the unlock has an alt firemode specified, unlocking it as well
			string source = unlock.m_key;
			if (m_firemodes.exists(source)) {
				string target;
				m_firemodes.get(source, target);
				
				const Resource@ unlock_alt = Resource(target, unlock.m_type);

				_log("* item delivery completed, picking unlock for " + item.m_key + " (" + item.m_type + "): " + target + " (" + unlock.m_type + ")", 1);
				// enable a resource for the faction
				array<string> groupsChanged;
				changeFactionResources(m_metagame, m_factionId, array<const Resource@> = {unlock_alt}, true, groupsChanged);

				// unlocks are lost over time, but they must carry over map changes
				// announce to metagame that we've unlocked something now, it'll handle that part
				m_listener.itemUnlocked(unlock_alt);			
			}

		} else {
			_log("* failed to find an unlock", 1);

			if (playerId != -1) {
				sendPrivateMessageKey(m_metagame, playerId, "no more resources to unlock");
			}
	
			// comment about it?
			//$text = "objective completed, " . $this->item_name . " unlocked";

			// if all unlocks have been used:
			// - don't care for now?
		}
		
		return result;
	}

	// ----------------------------------------------------
	protected void applyCustomization(const array<Resource@>@ list) {
		string mapId = m_gameMode.getMapInfo().m_id;
		if (m_customizations.exists(mapId)) {
			dictionary@ customizations;
			m_customizations.get(mapId, @customizations);
	
			for (uint i = 0; i < list.size(); ++i) {
				Resource@ r = list[i];
				string source = r.m_key;
				if (customizations.exists(source)) {
					// replace
					string target;
					customizations.get(source, target);
					r.m_key = target;
				}
			}
		} else {
			for (uint i = 0; i < list.size(); ++i) {
				Resource@ r = list[i];
				
				bool handled = false;

				for (uint j = 0; j < m_customizations.getKeys().size()-1 && !handled; ++j) {
					string key = m_customizations.getKeys()[j];
					dictionary@ customizations;
					m_customizations.get(key, @customizations);
					for (uint k = 0; k < customizations.getKeys().size() && !handled; ++k) {
						string source = customizations.getKeys()[k];
						string target;
						customizations.get(source, target);
						if (r.m_key == target) {
							r.m_key = source;
							handled = true;
						}
					}
				}
			}
		}
	}
}

/*
	// ----------------------------------------------------
	protected const Resource@ getUnlock(const Resource@ item) const {
		_log("get_unlock", 1);
		const Resource@ result = null;
		if (m_unlockList.exists(item.m_key)) {
			// unlock list is an associative container of
			// "delivery target item key" -> "container potential reward resourcerefs"
			array<Resource@>@ list;
			m_unlockList.get(item.m_key, @list);
			
			applyCustomization(list);
			
			@result = pickRewardItem(list);
		} else {
			_log("key " + item.m_key + " doesn't exist in unlock_list", 1);
		}
		return result;
	}
*/
