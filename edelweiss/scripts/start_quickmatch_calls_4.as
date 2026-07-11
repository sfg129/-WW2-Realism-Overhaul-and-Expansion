#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/edelweiss/scripts"
//#include "gamemode_base_spawn.as"
#include "gamemode_quickmatch.as"

void main(dictionary@ inputData) {
	XmlElement inputSettings(inputData);

	GameModeQuickMatch metagame(inputSettings, "edelweiss4");

	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}