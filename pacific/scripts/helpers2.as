#include "helpers.as"

// ----------------------------------------------------
void setVisualTimer(Metagame@ metagame, float time) {
	XmlElement command("command");
	command.setStringAttribute("class", "set_game_timer");
	command.setIntAttribute("faction_id", 0); // use faction id to pick color for timer
	command.setIntAttribute("pause", 0); 
	command.setFloatAttribute("time", time); 
	metagame.getComms().send(command);
}

// ----------------------------------------------------
void clearVisualTimer(Metagame@ metagame) {
	XmlElement command("command");
	command.setStringAttribute("class", "set_game_timer");
	command.setIntAttribute("faction_id", -1);
	command.setIntAttribute("pause", 1); 
	command.setFloatAttribute("time", -1.0f); 
	metagame.getComms().send(command);
}
