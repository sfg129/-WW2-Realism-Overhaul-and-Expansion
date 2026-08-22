// Shared by campaign and quick match. Calls listed here must use
// notify_metagame="1" so CallMarkerTracker receives their call events.
// New-call ranges use representative horizontal instance_spread + common_spread;
// atlas indices follow each call's hud_icon mapping in the comms marker atlas.
array<CallMarkerConfig@> getCallMarkerConfigs() {
	array<CallMarkerConfig@> configs = {
		// Mortar and rocket barrages. light_mortar.call is intentionally excluded.
		CallMarkerConfig("mortar.call", 6, 0.5, 45.0),
		CallMarkerConfig("mortar1.call", 7, 0.5, 45.0),
		CallMarkerConfig("mortar2.call", 14, 0.5, 55.0),
		CallMarkerConfig("mortar3.call", 14, 0.5, 40.0),
		CallMarkerConfig("mortar4.call", 14, 0.5, 40.0),
		CallMarkerConfig("mortar5.call", 6, 0.5, 16.0),

		// Artillery barrages.
		CallMarkerConfig("artillery.call", 8, 1.0, 75.0),
		CallMarkerConfig("artillery1.call", 9, 1.0, 80.0),
		CallMarkerConfig("artillery2.call", 8, 1.0, 75.0),
		CallMarkerConfig("artillery3.call", 9, 1.0, 80.0),
		CallMarkerConfig("artillery4.call", 8, 1.0, 30.0),

		// airstrike2.call is handled by StrafingRun and creates its own marker.
		CallMarkerConfig("airstrike.call", 10, 0.5, 25.0),
		CallMarkerConfig("airstrike1.call", 11, 0.5, 12.0),
		CallMarkerConfig("airstrike3.call", 3, 0.5, 10.0),
		CallMarkerConfig("airstrike4.call", 3, 0.5, 10.0),
		CallMarkerConfig("airstrike5.call", 3, 0.5, 3.0),
		CallMarkerConfig("airstrike6.call", 3, 0.5, 4.0),
		CallMarkerConfig("airstrike7.call", 3, 0.5, 5.0),
		CallMarkerConfig("airstrike8.call", 3, 0.5, 4.0),
		CallMarkerConfig("airstrike9.call", 3, 0.5, 5.0),
		CallMarkerConfig("airstrike10.call", 3, 0.5, 10.0),
		CallMarkerConfig("airstrike11.call", 3, 0.5, 10.0),
		CallMarkerConfig("airstrike12.call", 11, 0.5, 2.0)
	};

	return configs;
}
