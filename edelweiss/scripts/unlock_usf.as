#include "resource.as"

array<Resource@>@ getUnlockItemListUsf() {
	array<Resource@> list;
	
	//primary weapon unlocks
	list.push_back(Resource("browning_auto5_ext.weapon", "weapon"));
	list.push_back(Resource("winchester_automatic_rifle.weapon", "weapon"));

	list.push_back(Resource("m1_garand_rifle_grenade_he.weapon", "weapon")); 
	list.push_back(Resource("m2_carbine.weapon", "weapon")); 
	list.push_back(Resource("m2_hyde.weapon", "weapon"));
	list.push_back(Resource("browning_auto5_cut_down.weapon", "weapon"));
	list.push_back(Resource("m1941_johnson_lmg.weapon", "weapon"));

	//list.push_back(Resource("", "carry_item"));
	//list.push_back(Resource("", "projectile"));   
	list.push_back(Resource("wrench.weapon", "weapon"));   
/*

	
*/
	//elite heavy MG unlocks

		
	return list;
}
