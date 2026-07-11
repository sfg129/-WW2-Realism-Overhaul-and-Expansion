#include "metagame.as"
#include "vector2.as"

// ----------------------------------------------------------------------------
class GridVisual {
	int m_x;
	int m_y;
	int m_xSize;
	int m_ySize;

	// ----------------------------------------------------------------------------
	GridVisual() {
		m_x = 0;
		m_y = 0;
		m_xSize = 0;
		m_ySize = 0;
	}

	// ----------------------------------------------------------------------------
	GridVisual(int x, int y, int xSize = 1, int ySize = 1) {
		m_x = x;
		m_y = y;
		m_xSize = xSize;
		m_ySize = ySize;
	}
}

// ----------------------------------------------------------------------------
class Marker {
	Vector2 m_size;
	string m_rect;
};

// ----------------------------------------------------------------------------
class World {
	protected Metagame@ m_metagame;
	protected dictionary m_visuals;
	protected dictionary m_positions;

	// --------------------------------------------
	World(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	void init(const dictionary@ gridVisuals, const dictionary@ positions, const Vector2@ offset, float scale) {
		int textureSize = 2048;
		int gridSize = 8;
		int cellSize = textureSize / gridSize;

		for (uint i = 0; i < gridVisuals.getKeys().size(); ++i) {
			string key = gridVisuals.getKeys()[i];
			GridVisual gv;
			gridVisuals.get(key, gv);

			float rectX = float(gv.m_x * cellSize) / float(textureSize);
			float rectY = float(gv.m_y * cellSize) / float(textureSize);
			float rectX2 = rectX + float(gv.m_xSize * cellSize) / float(textureSize);
			float rectY2 = rectY + float(gv.m_ySize * cellSize) / float(textureSize);
			string rect = rectX + " " + rectY + " " + rectX2 + " " + rectY2;
			Vector2 size(gv.m_xSize * cellSize, gv.m_ySize * cellSize);
			Marker marker;
			marker.m_size = size.scale(scale);
			marker.m_rect = rect;
			//_log("adding visual " + key + ", rect=" + marker.m_rect + ", size=" + marker.m_size.toString());
			m_visuals[key] = marker;
		}

		for (uint i = 0; i < positions.getKeys().size(); ++i) {
			string key = positions.getKeys()[i];
			Vector2 position;
			positions.get(key, position);
			position = position.scale(scale).add(offset);
			m_positions[key] = position;
		}
	}

	// ----------------------------------------------------------------------------
	protected Vector2 getPosition(string key) {
		Vector2 position;
		m_positions.get(key, position);
		return position;
	}

	// ----------------------------------------------------------------------------
	protected Marker getMarker(string key) {
		Marker marker;
		m_visuals.get(key, marker);
		return marker;
	}

	// ----------------------------------------------------------------------------
	protected void clearVisuals(const array<int>@ visualIds) {
		string command = "<command class='set_world_situation'>";
		for (uint i = 0; i < visualIds.size(); ++i) {
			int value = visualIds[i];
			string p = "<visual id='" + value + "' layer='1' enabled='false' />";
			command += p;
		}
		command +="</command>";

		m_metagame.getComms().send(command);
	}

	// ----------------------------------------------------------------------------
	protected string getVisualTag(int id, int layer, Vector2 position, const Marker@ marker, string color = "1 1 1 1") {
		return "<visual id='" + id + "' layer='" + layer + "' position='" + position.toString() + "' size='" + marker.m_size.toString() + "' texture_rect='" + marker.m_rect + "' color='" + color + "' />";
	}

	// ----------------------------------------------------------------------------
	protected string getVisualCommand(string visualTag) {
		return "<command class='set_world_situation'>" + visualTag + "</command>";
	}

	// ----------------------------------------------------------------------------
	void setup(const array<FactionConfig@>@ factionConfigs, const array<Stage@>@ stages, const array<int>@ stagesCompleted, int currentStageIndex) {
		// set markers
		refresh(stages, stagesCompleted, currentStageIndex);
	}

	// ----------------------------------------------------------------------------
	void refresh(const array<Stage@>@ stages, const array<int>@ stagesCompleted, int currentStageIndex) {
		int startVisualId = 100;
		int visualId = startVisualId;
		string command = "<command class='set_world_situation'>";
		for (uint i = 0; i < stages.size(); ++i) {
			Stage@ stage = stages[i];
			string key = stage.m_mapInfo.m_id;
			if (m_positions.exists(key)) {
				Vector2 position = getPosition(key);
				// stage images
				{
					string tag = getVisualTag(visualId, 0, position, getMarker(key));
					command += tag;
					visualId++;
				}
			}
		}
		{
			// current stage
			Stage@ stage = stages[currentStageIndex];
			string key = stage.m_mapInfo.m_id;
			string tag = getVisualTag(visualId, 1, getPosition(key), getMarker(key + "_current"));
			command += tag;
			visualId++;
		}
		for (uint i = 0; i < stages.size(); ++i) {
			Stage@ stage = stages[i];
			string key = stage.m_mapInfo.m_id;
			if (m_positions.exists(key)) {
				Vector2 position = getPosition(key);
				// completed stages
				if (stagesCompleted.find(i) >= 0) {
					string tag = getVisualTag(visualId, 1, position, getMarker(key + "_done"));
					command += tag;
					visualId++;
				}
			}
		}

		command += "</command>";

		if (visualId != startVisualId) {
			// something changed, make it happen
			m_metagame.getComms().send(command);
		}
	}

	// ----------------------------------------------------------------------------
	void setAdvance(string currentMapId, string nextMapId) {
	}

	// ----------------------------------------------------------------------------
	void setAvailableTransports(array<string>@ transports) {
	}
}
