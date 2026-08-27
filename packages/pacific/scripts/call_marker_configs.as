// Shared by campaign and quick match. Calls listed here must use
// notify_metagame="1" so CallMarkerTracker receives their call events.
// New-call ranges use representative horizontal instance_spread + common_spread;
// atlas indices follow each call's hud_icon mapping in the comms marker atlas.
array<CallMarkerConfig@> getCallMarkerConfigs() {
	array<CallMarkerConfig@> configs = {
		// Mortar and rocket barrages. light_mortar.call is intentionally excluded.
		CallMarkerConfig("mortar.call", 6, 0.5, 45.0),
		CallMarkerConfig("mortar1.call", 7, 0.5, 45.0),
		CallMarkerConfig("mortar2.call", 7, 0.5, 45.0),
		CallMarkerConfig("mortar3.call", 7, 0.5, 40.0),
		CallMarkerConfig("mortar4.call", 7, 0.5, 40.0),
		CallMarkerConfig("mortar5.call", 6, 0.5, 16.0),

		// Artillery barrages.
		CallMarkerConfig("artillery.call", 8, 1.0, 75.0),
		CallMarkerConfig("artillery1.call", 9, 1.0, 80.0),
		CallMarkerConfig("artillery2.call", 8, 1.0, 75.0),
		CallMarkerConfig("artillery3.call", 9, 1.0, 80.0),
		CallMarkerConfig("artillery4.call", 8, 1.0, 30.0),

		// airstrike2.call through airstrike11.call are handled by StrafingRun and create their own markers.
		CallMarkerConfig("airstrike.call", 10, 0.5, 25.0),
		CallMarkerConfig("airstrike1.call", 11, 0.5, 12.0),
		CallMarkerConfig("airstrike12.call", 11, 0.5, 2.0)
	};

	return configs;
}
