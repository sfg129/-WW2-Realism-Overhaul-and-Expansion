// internal
#include "base_resource_controller.as"
#include "resource_helpers.as"

// has been replaced by spawn_in_base, though may still be useful

// --------------------------------------------
class BaseResourceControllerIsland4 : BaseResourceController {
	protected GameModeInvasion@ m_gameMode;
	// --------------------------------------------
	BaseResourceControllerIsland4(GameModeInvasion@ metagame, const array<string>@ sorting) {
		super(metagame, sorting);
		// also store specialized pointer to gamemode, we need getFactions()
		@m_gameMode = @metagame;
	}

	// ----------------------------------------------------
	bool ownsBase(int factionId, string baseKey) {
		array<const XmlElement@> baseList = getBases(m_metagame);
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getIntAttribute("owner_id") == factionId &&
				base.getStringAttribute("key") == baseKey) {
				return true;
			}
		}
		return false;
	}

	// ----------------------------------------------------
	protected void determineCalls(int factionId, array<const XmlElement@>@ calls) {
		array<Resource@> enableResources;
		array<Resource@> disableResources;

		// NOTE/TODO: this likely doesn't work; faction by factionChoice becomes index 0
		bool isUsmc = m_gameMode.getFactions()[factionId].m_config.m_index == 0;
		// something like this would work:
		//bool isUsmc = m_metagame.getFactions()[factionId].m_config.m_file == "usmc.xml";

		if (ownsBase(factionId, "Western Defenses")) {
			if (isUsmc) {
				enableResources.insertLast(Resource("usmc_inf1.call", "call"));
				enableResources.insertLast(Resource("usmc_vehicle1.call", "call"));
				enableResources.insertLast(Resource("usmc_vehicle3.call", "call"));
				disableResources.insertLast(Resource("usmc_inf.call", "call"));
				disableResources.insertLast(Resource("usmc_vehicle.call", "call"));
				disableResources.insertLast(Resource("usmc_vehicle2.call", "call"));
			} else {
				enableResources.insertLast(Resource("ija_inf1.call", "call"));
				enableResources.insertLast(Resource("ija_vehicle1.call", "call"));
				disableResources.insertLast(Resource("ija_inf.call", "call"));
				disableResources.insertLast(Resource("ija_vehicle.call", "call"));
			}
			
		} else {
			if (isUsmc) {
				disableResources.insertLast(Resource("usmc_inf1.call", "call"));
				disableResources.insertLast(Resource("usmc_vehicle1.call", "call"));
				disableResources.insertLast(Resource("usmc_vehicle3.call", "call"));
				enableResources.insertLast(Resource("usmc_inf.call", "call"));
				enableResources.insertLast(Resource("usmc_vehicle.call", "call"));
				enableResources.insertLast(Resource("usmc_vehicle2.call", "call"));
			} else {
				disableResources.insertLast(Resource("ija_inf1.call", "call"));
				disableResources.insertLast(Resource("ija_vehicle1.call", "call"));
				enableResources.insertLast(Resource("ija_inf.call", "call"));
				enableResources.insertLast(Resource("ija_vehicle.call", "call"));
			}
		}

		// add more enable/disable rules here if needed

		updateResources(calls, enableResources, true, m_sorting);
		updateResources(calls, disableResources, false, m_sorting);
	}

	// ----------------------------------------------------
	protected void setCalls(int factionId, array<const XmlElement@>@ calls) {
		XmlElement command("command");
		command.setStringAttribute("class", "faction_resources");
		command.setBoolAttribute("clear_calls", true);
		command.setIntAttribute("faction_id", factionId);
		for (uint i = 0; i < calls.size(); ++i) {
			const XmlElement@ call = calls[i];
			command.appendChild(call);
		}
		m_metagame.getComms().send(command);
	}

	// ----------------------------------------------------
	protected void refreshResources(int factionId) {
		_log("BaseResourceControllerIsland4, refreshResources, factionId " + factionId);
		array<const XmlElement@>@ calls = getFactionResources(m_metagame, factionId, "call", "calls");
		determineCalls(factionId, calls);
		setCalls(factionId, calls);
	}
}
