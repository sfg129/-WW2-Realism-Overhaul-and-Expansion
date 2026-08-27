// declare include paths
#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/test/scripts"
#include "path://media/packages/pacific/scripts"
#include "path://media/packages/edelweiss/scripts"

#include "gamemode_campaign.as"

// --------------------------------------------
void main(dictionary@ inputData) {
	XmlElement inputSettings(inputData);

	UserSettings settings;
	settings.m_initialRp = 50;
	settings.m_journalEnabled = true;
	settings.m_fellowDisableEnemySpawnpointsSoldierCountOffset = 2;
	
	settings.m_testingToolsEnabled = false;

	array<string> overlays = {
			"media/packages/pacific"
	};
	settings.m_overlayPaths = overlays;
	
	settings.fromXmlElement(inputSettings);
	

	_setupLog(inputSettings);
	//_setupLog("dev_verbose");

	settings.print();

	GameModeCampaign metagame(settings);

	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}
