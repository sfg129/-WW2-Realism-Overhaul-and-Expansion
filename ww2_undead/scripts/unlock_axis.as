#include "resource.as"

array<Resource@>@ getUnlockItemListAxis() {
	array<Resource@> list;
	

	//primary weapon unlocks
	list.push_back(Resource("beretta_m38.weapon", "weapon")); //respawnable 25rp
	list.push_back(Resource("ppsh41.weapon", "weapon")); //respawnable 25rp
	list.push_back(Resource("flammenwerfer_41.weapon", "weapon")); //non-respawnable
	list.push_back(Resource("mg26t.weapon", "weapon")); //non-respawnable
	list.push_back(Resource("kar98k_small_optic.weapon", "weapon")); //non-respawnable
	list.push_back(Resource("stg44_s.weapon", "weapon"));

	 //non-respawnable
	//mg34
	
	//secondary weapon unlocks
	list.push_back(Resource("danuvia_43m.weapon", "weapon")); //respawnable 15rp
	list.push_back(Resource("m712.weapon", "weapon")); //respawnable 20rp
list.push_back(Resource("stg44_n.weapon", "weapon")); //respawnable 25rp
	
	//vest unlocks

	
	//utility unlocks
	//list.push_back(Resource("", "weapon"));
	list.push_back(Resource("mk3_grenade.projectile", "projectile"));   

	list.push_back(Resource("wrench.weapon", "weapon"));   
	
	//elite heavy MG unlocks
	//list.push_back(Resource("", "weapon"));   
	
	return list;
}