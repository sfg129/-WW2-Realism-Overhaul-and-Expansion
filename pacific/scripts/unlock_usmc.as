#include "resource.as"

array<Resource@>@ getUnlockItemListUsmc() {
	array<Resource@> list;
	
	
	//primary weapon unlocks
	
	list.push_back(Resource("browning_auto5_ext.weapon", "weapon")); //respawnable 25rp
	list.push_back(Resource("m1_garand_rifle_grenade_he.weapon", "weapon")); 
	list.push_back(Resource("m1941_johnson_lmg.weapon", "weapon"));
	list.push_back(Resource("m1928_thompson_large_drum.weapon", "weapon"));
	list.push_back(Resource("browning_auto5_cut_down.weapon", "weapon"));
	list.push_back(Resource("m1_garand_s.weapon", "weapon")); //respawnable 15rp
	list.push_back(Resource("stinger.weapon", "weapon"));
	list.push_back(Resource("m1941_johnson_rifle_s.weapon", "weapon"));
	//vest unlocks

	
	//utility unlocks

	list.push_back(Resource("wrench.weapon", "weapon"));   
	

	return list;
}
