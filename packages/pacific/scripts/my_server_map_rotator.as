#include "my_map_rotator.as"

// --------------------------------------------
// this is possibly the weirdest thing ever:
// MyServerMapRotator : MyMapRotator : MapRotatorCampaign : MapRotatorInvasion : MapRotator!
class MyServerMapRotator : MyMapRotator {
	// --------------------------------------------
	MyServerMapRotator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	void init() {
		MyMapRotator::init();
		setLoop(true);
	}

	// --------------------------------------------
	protected void readyToAdvance() {
		// MyMapRotator behaves like MapRotatorCampaign, updating extraction points and waiting for local player to enter the extraction point
		MyMapRotator::readyToAdvance();

		// MyServerMapRotator overrides determineExtractionHitboxList returning an empty list always, so no extraction points appear

		// MapRotatorInvasion::readyToAdvance will instantly advance to the next map
		MapRotatorInvasion::readyToAdvance();
	}

	// -------------------------------------------------------
	protected void determineExtractionHitboxList() {
		array<const XmlElement@> list;
		m_extractionHitboxes = list;
	}

	// -------------------------------------------------------
	protected void waitAndStartAtMapChangeCommit() {
		MapRotatorInvasion::waitAndStartAtMapChangeCommit();
	}

	// --------------------------------------------
	void refreshCompletionStatus(bool first) {
		// nothing to do here
	}

	// --------------------------------------------
	protected void ensureValidLocalPlayer(float time) {
		// nothing to do here
	}
}
