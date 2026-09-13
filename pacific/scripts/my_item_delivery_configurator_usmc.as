#include "my_item_delivery_configurator.as"
#include "unlock_usmc.as"

// ------------------------------------------------------------------------------------------------
class MyItemDeliveryConfigurator_USMC : MyItemDeliveryConfigurator {
	// ------------------------------------------------------------------------------------------------
	MyItemDeliveryConfigurator_USMC(GameModeInvasion@ metagame) {
		super(metagame);
	}
	
	// --------------------------------------------
	array<Resource@>@ getUnlockItemList() const {
		return getUnlockItemListUsmc();
	}
	
	// --------------------------------------------
	array<Resource@>@ getUnlockItemList2() const {
		array<Resource@> list;
		
//		list.push_back(Resource("welrod.weapon", "weapon"));
//		list.push_back(Resource("sten_supp.weapon", "weapon"));
//		list.push_back(Resource("delisle.weapon", "weapon"));
			
		return list;
	}
	
	// --------------------------------------------
	array<Resource@>@ getDeliverablesList() const {
		array<Resource@> list;
		
		// list here what we want to track as delivering to armory, with intention of unlocking that same item
		
		// the upgrade weapons, l85a2, famas, sg552, are considered semi-rare, only unlockable through cargo truck & suitcases, see get_unlock_weapon_list
		// in 1.31 we removed the weapons as unlockables that are not dropped by the AI 
		
		// USMC weapons
		//list.push_back(Resource("m55_reising.weapon", "weapon"));
		//list.push_back(Resource("m1a1_thompson.weapon", "weapon"));
		//list.push_back(Resource("m1903_rifle.weapon", "weapon"));
		//list.push_back(Resource("m1903_rifle_b.weapon", "weapon"));
		//list.push_back(Resource("m1_garand.weapon", "weapon"));
		//list.push_back(Resource("m1_garand_b.weapon", "weapon"));
		//list.push_back(Resource("m1918_bar.weapon", "weapon"));
		//list.push_back(Resource("m1919_lmg.weapon", "weapon"));
		//list.push_back(Resource("m1903a4_s.weapon", "weapon"));
		
		//list.push_back(Resource("m1919_hmg_resource.weapon", "weapon"));
		//list.push_back(Resource("m1903_rifle_grenade_at.weapon", "weapon"));
		//list.push_back(Resource("m1_bazooka.weapon", "weapon"));
		//list.push_back(Resource("m1911.weapon", "weapon"));
		
		//list.push_back(Resource("mkii_grenade.projectile", "projectile"));
		//list.push_back(Resource("satchel.projectile", "projectile"));
		
		// IJA weapons
		list.push_back(Resource("type38_rifle.weapon", "weapon"));
		//list.push_back(Resource("type38_rifle_b.weapon", "weapon"));
		//list.push_back(Resource("type38_rifle_grenade_he.weapon", "weapon"));
		list.push_back(Resource("type99_rifle.weapon", "weapon"));
		//list.push_back(Resource("type99_rifle_b.weapon", "weapon"));
		list.push_back(Resource("type_i_rifle.weapon", "weapon"));
		list.push_back(Resource("type44_carbine.weapon", "weapon"));
		list.push_back(Resource("mp34.weapon", "weapon"));
		list.push_back(Resource("type100_smg.weapon", "weapon"));
		list.push_back(Resource("type100_44_smg.weapon", "weapon"));
		//list.push_back(Resource("type100_44_smg_b.weapon", "weapon"));
		list.push_back(Resource("type96_lmg.weapon", "weapon"));
		//list.push_back(Resource("type96_lmg_b.weapon", "weapon"));
		list.push_back(Resource("type99_lmg.weapon", "weapon"));
		//list.push_back(Resource("type99_lmg_b.weapon", "weapon"));
		list.push_back(Resource("type97_s.weapon", "weapon"));
		
		//list.push_back(Resource("type92_hmg_resource.weapon", "weapon"));
		//list.push_back(Resource("type38_rifle_grenade_at.weapon", "weapon"));
		//list.push_back(Resource("type4_rocket_launcher.weapon", "weapon"));
		//list.push_back(Resource("type14_nambu_pistol.weapon", "weapon"));     
		
		//list.push_back(Resource("type97_grenade.projectile", "projectile"));
		//list.push_back(Resource("type99_at_grenade.projectile", "projectile"));
		
		return list;
	}
}
