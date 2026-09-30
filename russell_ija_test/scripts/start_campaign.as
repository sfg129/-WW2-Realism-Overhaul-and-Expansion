#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/pacific/scripts"
#include "my_gamemode.as"

// Use the real stage factory, maps and trackers. No second copy to maintain.
class RussellTestStageConfigurator : MyStageConfiguratorIJA {
    RussellTestStageConfigurator(GameModeInvasion@ metagame, MyMapRotator@ rotator) {
        super(metagame, rotator);
    }

    protected void setupNormalStages() {
        Stage@ stage = setupStage12();
        stage.m_hidden = false;
        addStage(stage);
    }

    void setupStageUnlockRules() {}
    protected void setupTransports() {}
    protected void setupStartingMaps() {
        m_myMapRotator.addStartingMap("island2");
    }
}

class RussellTestGameMode : MyGameMode {
    RussellTestGameMode(UserSettings@ settings) { super(settings); }

    protected void setupMapRotator() {
        MyMapRotator@ rotator = MyMapRotator(this);
        RussellTestStageConfigurator configurator(this, rotator);
        @m_mapRotator = @rotator;
    }
}

void main(dictionary@ inputData) {
    XmlElement inputSettings(inputData);
    // Match the original campaign entry syntax: the game's older
    // AngelScript rejects assigning an untyped initializer list to a member.
    array<string> overlays = {"media/packages/ww2_base"};
    UserSettings settings;
    settings.m_overlayPaths = overlays;
    settings.m_journalEnabled = true;
    settings.m_initialRp = 50;
    settings.fromXmlElement(inputSettings);
    // This temporary test entry must always start from phase zero. The menu
    // can load the old test slot and pass continue=1 even when launched from
    // the campaign selection screen. Ignore that mode here, and use a fresh
    // slot so the already-loaded world/profile cannot leak into the new run.
    // Two random components make accidental reuse of a previous test slot
    // extremely unlikely without touching or deleting any existing saves.
    settings.m_continue = false;
    settings.m_savegame = "russell_ija_script_test_" + rand(100000, 999999) + "_" + rand(100000, 999999);
    settings.m_continueAsNewCampaign = false;
    settings.m_factionChoice = 1;
    _setupLog(inputSettings);
    settings.print();
    RussellTestGameMode metagame(settings);
    metagame.init();
    metagame.run();
    metagame.uninit();
}
