dictionary getUnlockFiremodes() {

	//don't forget to include the alternative firemode variants in unlock customizations if they change on some maps
	//if the weapon that replaces them doesn't have an alt mode, then let it point to a dummy weapon in unlock customizations
	//yeah, this isn't very elegant, but unless there are far more unlockables with firemodes, this will do

	return dictionary = {
		{"m12_trench_gun.weapon", "m12_trench_gun_b.weapon"},
		//{"lanchester_smg.weapon", "lanchester_smg_b.weapon"},	
		{"type38_rifle.weapon", "type38_rifle_b.weapon"},
		{"type99_rifle.weapon", "type99_rifle_b.weapon"},
		{"type_i_rifle.weapon", "type_i_rifle_b.weapon"},
		{"mp34.weapon", "mp34_b.weapon"},
		{"type100_smg.weapon", "type100_smg_b.weapon"},
		{"type100_44_smg.weapon", "type100_44_smg_b.weapon"},
		{"type96_lmg.weapon", "type96_lmg_b.weapon"},		
		{"type99_lmg.weapon", "type99_lmg_b.weapon"},
		{"m1903_rifle.weapon", "m1903_rifle_b.weapon"},
		{"m1_garand.weapon", "m1_garand_b.weapon"},
		{"smle_no4_mki.weapon", "smle_no4_mki_b.weapon"},			
		{"sten_mkv.weapon", "sten_mkv_b.weapon"},
		{"kar98k.weapon", "kar98k_b.weapon"},
		{"type44_carbine.weapon", "type44_carbine_b.weapon"},
		{"type100_folding.weapon", "type100_folding_b.weapon"},
		{"browning_auto5_ext.weapon", "browning_auto5_ext_4.weapon"},
		{"m2_carbine.weapon", "m2_carbine_b.weapon"},
		{"type_ko_rifle.weapon", "type_ko_rifle_b.weapon"},
		{"type4_garand.weapon", "type4_garand_b.weapon"},
		{"m1_garand_s.weapon", "m1_garand_is.weapon"},
{"type99_rifle_s.weapon", "type99_rifle_is.weapon"},
{"mn9130_is.weapon", "mn9130_s.weapon"},
{"stg44_s.weapon", "stg44_is.weapon"},
		{"mp34_o.weapon", "mp34_o_b.weapon"}
	};

	//return dictionary();
}
