#include "stage_configurator_invasion.as"

// for now this is mostly empty; we've just stubbed out some of the vanilla campaign stuff; World could be useful at some point

// ------------------------------------------------------------------------------------------------
class StageConfiguratorCampaign : StageConfiguratorInvasion {
	MapRotatorCampaign@ m_mapRotatorCampaign;

	// ------------------------------------------------------------------------------------------------
	StageConfiguratorCampaign(GameModeInvasion@ metagame, MapRotatorCampaign@ mapRotator) {
		super(metagame, mapRotator);
		// also need to store the adventure specific pointer, avoid casting
		@m_mapRotatorCampaign = @mapRotator;
	}

	// ------------------------------------------------------------------------------------------------
	void setup() {
		StageConfiguratorInvasion::setup();
	}
}