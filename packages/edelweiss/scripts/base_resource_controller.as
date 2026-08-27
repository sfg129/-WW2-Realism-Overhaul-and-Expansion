// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "resource.as"

// has been replaced by spawn_in_base, though may still be useful

// --------------------------------------------
class BaseResourceController : Tracker {
	protected GameMode@ m_metagame;
	protected array<string> m_sorting;
	protected bool m_started;

	// --------------------------------------------
	BaseResourceController(GameMode@ metagame, const array<string>@ sorting) {
		@m_metagame = @metagame;
		m_sorting = sorting;
		m_started = false;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// ----------------------------------------------------
	void start() {
		m_started = true;

		for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
			refreshResources(i);
		}
	}

	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		_log("BaseResourceController, base ownership changed", 1); 
		for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
			refreshResources(i);
		}
	}

	// ----------------------------------------------------
	protected void refreshResources(int factionId) {
	}
}
