#include "tracker.as"
#include "helpers.as"
#include "query_helpers.as"
#include "log.as"

// The native two-second trigger resolves the original body.  Continue only
// the inert visible canister; its native impact result starts smoke, sound and
// occlusion together.  There is deliberately no airborne smoke path.
class AnM8SmokeTracker : Tracker {
	protected Metagame@ m_metagame;
	protected float m_continuationSpeed = 12.0f;
	protected float m_timeStep = 0.017f;

	AnM8SmokeTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	bool hasStarted() const { return true; }
	bool hasEnded() const { return false; }
	void onAdd() { _log("AnM8SmokeTracker: frame-offset continuation active", 1); }
	void onRemove() {}
	void update(float time) {}

	protected void spawn(string key, Vector3 position, Vector3 frameOffset, int characterId, int factionId) {
		string command =
			"<command class='create_instance' instance_class='grenade'" +
			" instance_key='" + key + "'" +
			" position='" + position.toString() + "'" +
			" offset='" + frameOffset.toString() + "'";
		if (characterId >= 0) command += " character_id='" + characterId + "'";
		if (factionId >= 0) command += " faction_id='" + factionId + "'";
		command += " />";
		m_metagame.getComms().send(command);
	}

	protected void handleResultEvent(const XmlElement@ event) {
		if (event.getStringAttribute("key") != "an_m8_smoke_activate") return;

		Vector3 position = stringToVector3(event.getStringAttribute("position"));
		Vector3 direction = stringToVector3(event.getStringAttribute("direction"));
		float directionLength = getPositionDistance(direction, Vector3(0, 0, 0));
		Vector3 frameOffset = Vector3(0, 0, 0);
		if (directionLength > 0.001f) {
			frameOffset = direction.scale((m_continuationSpeed * m_timeStep) / directionLength);
		}

		int characterId = event.getIntAttribute("character_id");
		int factionId = -1;
		if (characterId >= 0) {
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) factionId = character.getIntAttribute("faction_id");
		}

		spawn("an_m8_smoke_wait_for_landing.projectile", position, frameOffset, characterId, factionId);
	}
}
