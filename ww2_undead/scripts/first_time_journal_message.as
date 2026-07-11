#include "tracker.as"
#include "helpers.as"
#include "log.as"

// --------------------------------------------
class FirstTimeJournalMessage : Tracker {
	protected Metagame@ m_metagame;
	protected string m_key;
	
	protected dictionary m_alreadyHandled;
	
	// --------------------------------------------
	FirstTimeJournalMessage(Metagame@ metagame, string key) {
		@m_metagame = @metagame;
		m_key = key;
	}
	
	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// ----------------------------------------------------
	protected void handlePlayerSpawnEvent(const XmlElement@ event) {
		_log("FirstTimeJournalMessage::handlePlayerSpawnEvent", 1);

		const XmlElement@ element = event.getFirstElementByTagName("player");
		string name = element.getStringAttribute("name");

		if (!m_alreadyHandled.exists(name)) {
			int characterId = element.getIntAttribute("character_id");
			
			XmlElement command("command");
			command.setStringAttribute("class", "add_custom_stat");
			command.setIntAttribute("character_id", characterId);
			command.setStringAttribute("tag", m_key);
			m_metagame.getComms().send(command);
			
			m_alreadyHandled.set(name, true);
			
			// no need to handle saving for m_alreadyHandled, we just avoid sending the stats more than one per session
		}
	}
	
}