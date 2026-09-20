#include "resource.as"

array<Resource@>@ getUnlockItemListIja() {
	array<Resource@> list;
			
	//primary weapon unlocks
	
	list.push_back(Resource("type2_model_b_machinepistol.weapon", "weapon")); //respawnable 25rp
	list.push_back(Resource("type_hei_automatic_rifle.weapon", "weapon")); //respawnable 25rp
	list.push_back(Resource("type93_flamethrower.weapon", "weapon")); //non-respawnable
	list.push_back(Resource("te4_lmg.weapon", "weapon"));
	list.push_back(Resource("ho104_hmg_assault.weapon", "weapon")); //non-respawnable
	list.push_back(Resource("type2_machinepistol.weapon", "weapon")); //non-respawnable		


	list.push_back(Resource("type_ko_rifle.weapon", "weapon")); //non-respawnable
	list.push_back(Resource("type99_lmg_s.weapon", "weapon"));
	
	//secondary weapon unlocks

	
	//vest unlocks

	
	//utility unlocks


	list.push_back(Resource("wrench.weapon", "weapon"));   

		
	return list;
}