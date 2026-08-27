// internal
#include "metagame.as"
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class DamagedVehicle : Tracker {
	protected Metagame@ m_metagame;
	protected string m_vehicleKey;
	protected float m_initialHealth;

	// --------------------------------------------
	DamagedVehicle(Metagame@ metagame, string vehicleKey, float initialHealth) {
		@m_metagame = @metagame;
		m_vehicleKey = vehicleKey;
		m_initialHealth = initialHealth;
	}

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}

	// --------------------------------------------
	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		if (event.getStringAttribute("vehicle_key") == m_vehicleKey) {
			XmlElement command("command");
			command.setStringAttribute("class", "update_vehicle");
			command.setIntAttribute("id", event.getIntAttribute("vehicle_id"));
			command.setFloatAttribute("health", m_initialHealth);
			m_metagame.getComms().send(command);
		}
	}
}

