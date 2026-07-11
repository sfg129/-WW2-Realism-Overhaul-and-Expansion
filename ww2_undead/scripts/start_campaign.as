#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/edelweiss/scripts"
#include "path://media/packages/ww2_undead/scripts"

#include "my_gamemode.as"

// --------------------------------------------
void main(dictionary@ inputData) {
	XmlElement inputSettings(inputData);
	
    array<string> overlays = {
            "media/packages/ww2_base"
    };
	
	UserSettings settings;
    settings.m_overlayPaths = overlays;
	
	settings.m_initialRp = 450;  
	settings.m_initialXp = 0.0;  
	settings.m_journalEnabled = true;

	// TODO: to be disabled before release
	settings.m_testingToolsEnabled = true;

	settings.fromXmlElement(inputSettings);
	_setupLog(inputSettings);
	settings.print();

	MyGameMode metagame(settings);

	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}
