// gamemode specific
#include "faction_config.as"
#include "stage_configurator.as"
#include "my_stage.as"
#include "call_sorting.as"

// note, we could just have everything in my_stage_configurator.as for simplicity, 
// currently there is no reason to split these to StageConfiguratorInvasion, StageConfiguratorCampaign and MyStageConfigurator..

// it might change if different behavior is needed for online vs single player

// ------------------------------------------------------------------------------------------------
class StageConfiguratorInvasion : StageConfigurator {
	protected GameModeInvasion@ m_metagame;
	protected MapRotatorInvasion@ m_mapRotator;

	// ------------------------------------------------------------------------------------------------
	StageConfiguratorInvasion(GameModeInvasion@ metagame, MapRotatorInvasion@ mapRotator) {
		@m_metagame = @metagame;
		@m_mapRotator = mapRotator;
		mapRotator.setConfigurator(this);
	}

	// ------------------------------------------------------------------------------------------------
	void setup() {
		setupFactionConfigs();

		setupWorld();

		setupNormalStages();
		setupFinalStages();
	}

	// ------------------------------------------------------------------------------------------------
	const array<FactionConfig@>@ getAvailableFactionConfigs() const {
		array<FactionConfig@> availableFactionConfigs;

		availableFactionConfigs.push_back(FactionConfig(-1, "allies.xml", "Allies", "0.5 0.5 0.9", "allies.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "axis.xml", "Axis", "0.34 0.34 0.34", "axis.xml"));

		return availableFactionConfigs;
	}

	// ------------------------------------------------------------------------------------------------
	protected void setupFactionConfigs() {
		array<FactionConfig@> availableFactionConfigs = getAvailableFactionConfigs(); // copy for mutability

		const UserSettings@ settings = m_metagame.getUserSettings();
		// - the faction the player picks in lobby campaign menu needs to be inserted first in the faction configs list
		{
			_log("faction choice: " + settings.m_factionChoice, 1);
			FactionConfig@ userChosenFaction = availableFactionConfigs[settings.m_factionChoice];
			_log("player faction: " + userChosenFaction.m_file, 1);

			int index = int(getFactionConfigs().size()); // is 0
			userChosenFaction.m_index = index;
			m_mapRotator.addFactionConfig(userChosenFaction);

			availableFactionConfigs.erase(settings.m_factionChoice);
		}

		// - next add the rest of them, in random order
		while (availableFactionConfigs.size() > 0) {
			int index = int(getFactionConfigs().size());

			int availableIndex = rand(0, availableFactionConfigs.size() - 1);
			FactionConfig@ faction = availableFactionConfigs[availableIndex];

			_log("setting " + faction.m_name + " as index " + index, 1);

			faction.m_index = index;
			m_mapRotator.addFactionConfig(faction);

			availableFactionConfigs.erase(availableIndex);
		}

		// - finally add neutral
		{
			int index = getFactionConfigs().size();
			m_mapRotator.addFactionConfig(FactionConfig(index, "neutral.xml", "Neutral", "0 0 0"));
		}

		_log("total faction configs " + getFactionConfigs().size(), 1);
	}

	// ------------------------------------------------------------------------------------------------
	protected void addStage(Stage@ stage) {
		m_mapRotator.addStage(stage);
	}

	// ------------------------------------------------------------------------------------------------
	protected void setupNormalStages() {
	}

	// ------------------------------------------------------------------------------------------------
	protected void setupFinalStages() {
	}

	// --------------------------------------------
	protected MyStage@ createStage() const {
		return MyStage(m_metagame.getUserSettings());
	}

	// --------------------------------------------
	protected MyPhasedStage@ createPhasedStage() const {
		return MyPhasedStage(m_metagame.getUserSettings());
	}

	// --------------------------------------------
	const array<FactionConfig@>@ getFactionConfigs() const {
		return m_mapRotator.getFactionConfigs();
	}

	// ------------------------------------------------------------------------------------------------
	Stage@ setupCompletedStage(Stage@ inputStage) {
		// currently not in use in invasion
		return null;
	}
		
	// --------------------------------------------
	protected void setupWorld() {
		// World disabled in Invasion for now, map10 elements are missing
		//$this->world = new World($this->metagame);
	}
}
