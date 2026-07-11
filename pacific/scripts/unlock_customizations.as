dictionary getUnlockCustomizations() {

	// testing unlock customization
	// - normally m1928a1_thompson.weapon unlocks
	// - in edelweiss2 mg34.weapon unlocks instead
	return dictionary = {
		{"island6", dictionary = {
			{"type_ko_rifle.weapon", "type4_garand.weapon"}
			//,{"c.weapon", "d.weapon"}
		}},
		{"island7", dictionary = {
			{"type_ko_rifle.weapon", "type4_garand.weapon"}
			//,{"c.weapon", "d.weapon"}
		}},
		{"island8", dictionary = {
			{"type_ko_rifle.weapon", "type4_garand.weapon"}
			//,{"c.weapon", "d.weapon"}
		}}
	};

	//return dictionary();
}
