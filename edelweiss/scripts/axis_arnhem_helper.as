// internal
#include "tracker.as"

// --------------------------------------------
class AxisArnhemHelper : Tracker {
	// --------------------------------------------
	protected Metagame@ m_metagame;

	// ----------------------------------------------------
	AxisArnhemHelper(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}
	
	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		if (event.getIntAttribute("owner_id") == 1) {
			string baseKey = event.getStringAttribute("base_key");
			if (baseKey == "kampfgruppe_hq") {
				sendFactionMessageKey(m_metagame, 0, "arnhem, supply cut");
			}
		}	
	}
}
