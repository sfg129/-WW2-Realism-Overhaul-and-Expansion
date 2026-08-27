#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/edelweiss/scripts"

#include "my_gamemode.as"

// --------------------------------------------
void main(dictionary@ inputData) {
	XmlElement inputSettings(inputData);

	UserSettings settings;

        _setupLog("dev_verbose");

	settings.m_factionChoice = 0;
        settings.m_playerAiCompensationFactor = 1.1;
        settings.m_enemyAiAccuracyFactor = 0.95;
        settings.m_playerAiReduction = 1.0;
        settings.m_teamKillPenaltyEnabled = true;
	settings.m_initialRp = 50;

        array<string> overlays = {
                "media/packages/pacific_invasion"
        };
        settings.m_overlayPaths = overlays;

        settings.m_startServerCommand = """
<command class='start_server'
	server_name='PacificTest'
	server_port='1240'
	comment='Coop campaign'
	url=''
	register_in_serverlist='1'
	mode='COOP'
	persistency='forever'
	max_players='24'>
	<client_faction id='0' />
</command>
""";

	settings.print();

	MyGameMode metagame(settings);

	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}
