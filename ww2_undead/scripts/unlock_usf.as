#include "resource.as"

array<Resource@>@ getUnlockItemListUsf() {
	array<Resource@> list;
	
	//primary weapon unlocks
	list.push_back(Resource("browning_auto5_ext.weapon", "weapon"));
	list.push_back(Resource("m1919_lmg_assault.weapon", "weapon")); 
	list.push_back(Resource("m1_garand_launcher.weapon", "weapon")); 
	list.push_back(Resource("m2_carbine.weapon", "weapon")); 
	list.push_back(Resource("m1941_johnson_lmg.weapon", "weapon")); 

	list.push_back(Resource("m2_hyde.weapon", "weapon"));
	list.push_back(Resource("winchester_automatic_rifle.weapon", "weapon"));
	list.push_back(Resource("m1941_johnson_rifle.weapon", "weapon"));
	//vest unlocks
	//list.push_back(Resource("", "carry_item"));
	//list.push_back(Resource("", "carry_item"));
	//list.push_back(Resource("", "projectile"));   
	list.push_back(Resource("wrench.weapon", "weapon"));   
/*
	list.push_back(Resource("mk3_grenade.projectile", "projectile"));   

	
*/
	//elite heavy MG unlocks

		
	return list;
}
