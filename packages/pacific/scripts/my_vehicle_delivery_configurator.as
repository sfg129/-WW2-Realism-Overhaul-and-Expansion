#include "vehicle_delivery_configurator_invasion.as"

// ------------------------------------------------------------------------------------------------
class MyVehicleDeliveryConfigurator : VehicleDeliveryConfiguratorInvasion {
	// ------------------------------------------------------------------------------------------------
	MyVehicleDeliveryConfigurator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	protected array<Resource@>@ getUnlockItemList() const {
		array<Resource@> list;

		list.push_back(Resource("m12_trench_gun.weapon", "weapon"));
		list.push_back(Resource("m1941_johnson_rifle.weapon", "weapon"));
		list.push_back(Resource("m1941_johnson_lmg.weapon", "weapon"));
		
		list.push_back(Resource("type4_rocket_launcher.weapon", "weapon"));
		list.push_back(Resource("type4_garand.weapon", "weapon"));
		list.push_back(Resource("type11_lmg.weapon", "weapon"));

		return list;
	}
}

