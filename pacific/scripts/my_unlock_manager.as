// internal
#include "unlock_manager.as"

// --------------------------------------------
class MyUnlockManager : UnlockManager {
	protected GameMode@ m_gameMode;
	protected dictionary m_customizations;
	
	// --------------------------------------------
	MyUnlockManager(GameMode@ gameMode, UnlockRemoveListener@ listener, const dictionary@ customizations, float unlockStartTime = -1.0) {
		@m_gameMode = @gameMode;
		super(gameMode, listener, unlockStartTime);
	
		m_customizations = customizations; // copy
	}

	// --------------------------------------------
	void applyUnlocks() {
		applyCustomization();
		UnlockManager::applyUnlocks();
	}
	
	// --------------------------------------------
	protected void applyCustomization() {
		string mapId = m_gameMode.getMapInfo().m_id;
		_log("MyUnlockManager, customizations size=" + m_customizations.size(), 1);
		for (uint i = 0; i < m_customizations.getKeys().size(); ++i) {
			_log("MyUnlockManager, key " + i + ", " + m_customizations.getKeys()[i], 1);
		}
		if (m_customizations.exists(mapId)) {
			_log("MyUnlockManager, customization exists for " + mapId, 1);
			// customizations exist for this map, process them
			dictionary@ customizations;
			m_customizations.get(mapId, @customizations);
	
			// go through unlocks
			for (uint i = 0; i < m_unlocks.size(); ++i) {
				ResourceTimer@ rt = m_unlocks[i];
				
				// if we have a timer for a resource that is configured to be replaced in this map, do customization now
				string source = rt.getResource().m_key;
				if (customizations.exists(source)) {
					// replace
					string target;
					customizations.get(source, target);
					replace(rt, target);
				}
			}
		} else {
			_log("MyUnlockManager, no customization for " + mapId, 1);
			// no customizations for this map, reverse them if any

			// go through unlocks
			for (uint i = 0; i < m_unlocks.size(); ++i) {
				ResourceTimer@ rt = m_unlocks[i];
				
				// if we have a timer for a resource that is listed as a customization target in any customization entry, go back to source
				bool handled = false;
				for (uint j = 0; j < m_customizations.getKeys().size() && !handled; ++j) {
					string key = m_customizations.getKeys()[j];
					dictionary@ customizations;
					m_customizations.get(key, @customizations);
					for (uint k = 0; k < customizations.getKeys().size() && !handled; ++k) {
						string source = customizations.getKeys()[k];
						string target;
						customizations.get(source, target);
						if (rt.getResource().m_key == target) {
							replace(rt, source);
							handled = true;
						}
					}
				}
			}
		}
	}
	
	// --------------------------------------------
	protected void replace(ResourceTimer@ rt, string target) {
		// sorry, need to modify this
		//rt.getResource().m_key = target;
		//Resource@ mutable = cast<Resource@>(rt.getResource());
		//mutable.m_key = target;
	
		const Resource@ resource = rt.getResource();
		const MultiGroupResource@ mgResource = cast<const MultiGroupResource>(resource);
		if (mgResource !is null) {
			array<string> groups = mgResource.m_groups;
			MultiGroupResource newResource(target, mgResource.m_type, groups);
			rt.replaceResource(newResource);
		} else {
			Resource newResource(target, resource.m_type);
			rt.replaceResource(newResource);
		}
	}
}

