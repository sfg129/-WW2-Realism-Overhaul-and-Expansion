#include "resource.as"

array<Resource@>@ getUnlockItemListUsf() {
	array<Resource@> list;
	
	//primary weapon unlocks
	list.push_back(Resource("m1928a1_thompson.weapon", "weapon")); //respawnable 25rp
	//list.push_back(Resource("m1903_rifle_grenade_he.weapon", "weapon")); //respawnable 25rp, transforms to smle_rifle_grenade_he for UKF
	list.push_back(Resource("m1928_thompson.weapon", "weapon")); //non-respawnable, transforms to lanchester_smg for UKF
	list.push_back(Resource("m2_carbine.weapon", "weapon")); //non-respawnable, transforms to vickers_minibipod for UKF
	list.push_back(Resource("m1_garand_s.weapon", "weapon")); //non-respawnable, transforms to enfield_p14_s for UKF
	list.push_back(Resource("m9a1_bazooka.weapon", "weapon")); //non-respawnable, transforms to boys_at_rifle for UKF
	
	//secondary weapon unlocks
	list.push_back(Resource("m1a1_carbine.weapon", "weapon"));	//respawnable 15rp, transforms to browning_hp_carbine for UKF
	list.push_back(Resource("m3_greasegun_folded.weapon", "weapon"));	//respawnable 20rp, transforms to austen_mki_folded for UKF
	list.push_back(Resource("m1917_revolver.weapon", "weapon")); //respawnable 25rp, transforms to enfield_mkii_revolver for UKF
	
	//vest unlocks
	list.push_back(Resource("vest_assault_webbing.carry_item", "carry_item"));
	list.push_back(Resource("camouflage_suit.carry_item", "carry_item"));
	
	//utility unlocks
	list.push_back(Resource("morphine.weapon", "weapon"));
	list.push_back(Resource("mk3_grenade.projectile", "projectile"));   
	//list.push_back(Resource("binoculars.weapon", "weapon"));   
	//list.push_back(Resource("democharge.projectile", "projectile"));   
	//list.push_back(Resource("wrench.weapon", "weapon"));   
/*
	// testing unlock customization
	// - normally m1928a1_thompson.weapon unlocks
	// - in edelweiss2 mg34.weapon unlocks instead
	list.push_back(Resource("m1928a1_thompson.weapon", "weapon")); 
	
*/
	//elite heavy MG unlocks
	//list.push_back(Resource("m2hb_hmg_resource.weapon", "weapon"));   
		
	return list;
}