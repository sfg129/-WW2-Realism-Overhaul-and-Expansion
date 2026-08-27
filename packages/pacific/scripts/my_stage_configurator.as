#include "stage_configurator_campaign.as"
#include "my_map_rotator.as"
#include "world.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfigurator : StageConfiguratorCampaign {
	MyMapRotator@ m_myMapRotator;
	
	// ------------------------------------------------------------------------------------------------
	MyStageConfigurator(GameModeInvasion@ metagame, MyMapRotator@ mapRotator) {
		super(metagame, mapRotator);
		// also need to store the adventure specific pointer, avoid casting
		@m_myMapRotator = @mapRotator;
	}
	
	// ------------------------------------------------------------------------------------------------
	void setup() {
		StageConfiguratorInvasion::setup();
		
		setupStageUnlockRules();
		setupTransports();
		setupStartingMaps();
	}

	// ------------------------------------------------------------------------------------------------
	protected void addStage(Stage@ stage) {
		if (stage.isCapture()) {
			// note: IntelManager(GameModeInvasion@ metagame, float reward = 100.0, string requiredCallForHint = "paratroopers1.call", float requiredXPForHint = 0.150)
			// paratroopers1.call doesn't exist in pacific, so the "additional call hint" won't be used
			stage.setIntelManager(IntelManager(m_metagame));
		}
		m_mapRotator.addStage(stage);
	}
	
	// ------------------------------------------------------------------------------------------------
	void setupStageUnlockRules() {
	}

	// ------------------------------------------------------------------------------------------------
	Stage@ setupCompletedStage(Stage@ inputStage) {
		MyStage@ stage = cast<MyStage@>(inputStage);
		if (stage !is null) {
			stage.transformCompleted();
		}
		return inputStage;
	}
	
	// --------------------------------------------
	protected void setupWorld() {
		_log("setupWorld");
		World world(m_metagame);

		dictionary gridVisuals = {
			{'island1',			GridVisual(0,1,2,1)},
			{'island2',			GridVisual(0,2,2,1)},
			{'island3',			GridVisual(0,4,2,1)},
			{'island4',			GridVisual(0,3,2,1)},
			{'island5',			GridVisual(0,5,2,1)},
			{'island6',			GridVisual(0,6,2,1)},
			{'island7',			GridVisual(0,7,2,1)},
			{'island8',			GridVisual(4,1,2,1)},
			{'island9',			GridVisual(4,2,2,1)},
			{'island1_current',		GridVisual(2,1,2,1)},
			{'island2_current',		GridVisual(2,2,2,1)},
			{'island3_current',		GridVisual(2,4,2,1)},
			{'island4_current',		GridVisual(2,3,2,1)},
			{'island5_current',		GridVisual(2,5,2,1)},
			{'island6_current',		GridVisual(2,6,2,1)},
			{'island7_current',		GridVisual(2,7,2,1)},
			{'island8_current',		GridVisual(6,1,2,1)},
			{'island9_current',		GridVisual(6,2,2,1)},
			{'island1_done',		GridVisual(0,0)},
			{'island2_done',		GridVisual(1,0)},
			{'island3_done',		GridVisual(2,0)},
			{'island4_done',		GridVisual(3,0)},
			{'island5_done',		GridVisual(4,0)},
			{'island6_done', 		GridVisual(5,0)},
			{'island7_done',		GridVisual(6,0)},
			{'island8_done',		GridVisual(7,0)},
			{'island9_done',		GridVisual(4,3)}
		};

		dictionary positions = {
			{'island1', Vector2(150, 132)},
			{'island2', Vector2(375, 198)},
			{'island3', Vector2(140, 464)},
			{'island4', Vector2(368, 422)},
			{'island9', Vector2(412, 552)},
			{'island5', Vector2(130, 726)},
			{'island6', Vector2(314, 744)},
			{'island7', Vector2(284, 1146)},
			{'island8', Vector2(200, 900)}
		};

		Vector2 offset(0,0);
		float scale = 2.5f;

		world.init(gridVisuals, positions, offset, scale);

		m_myMapRotator.setWorld(world);
	}
	
	// --------------------------------------------
	protected void setupTransports() {
	}
	
	// --------------------------------------------
	protected void addTransport(string sourceMapName, string hitboxId, string targetMapName) {
		m_myMapRotator.addTransport(sourceMapName, hitboxId, targetMapName);
	}
	
	// --------------------------------------------
	protected void setupStartingMaps() {
	}

	// --------------------------------------------
	array<XmlElement@>@ getFactionResourceConfigChangeCommands(float completionPercentage, Stage@ stage) {
		array<XmlElement@> commands;

		// apply initial friendly faction resource modifications
		commands.insertLast(getFactionResourceChangeCommand(0, getFriendlyFactionResourceChanges()));

		merge(commands, stage.m_extraCommands);
		return commands;
	}

	// --------------------------------------------
	protected array<ResourceChange@> getFriendlyFactionResourceChanges() const {
		array<ResourceChange@> list;

		// TODO: check if we need any of these in Pacific, stuff that should be enabled or disabled for player faction in general

		// no suitcases carried by friendlies
		list.push_back(ResourceChange(Resource("suitcase.carry_item", "carry_item"), false));

		// no prisons
		list.push_back(ResourceChange(Resource("prison_building.vehicle", "vehicle"), false));
		list.push_back(ResourceChange(Resource("prison_door.vehicle", "vehicle"), false));

		return list;
	}

}
