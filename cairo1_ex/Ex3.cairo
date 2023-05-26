#[contract] 

mod Ex3 {
use starknet::get_caller_address;
use starknet::ContractAddress;


use starknet_cairo_101::utils::ex00_base::Ex00Base::validate_exercise;
use starknet_cairo_101::utils::ex00_base::Ex00Base::ex_initializer;
use starknet_cairo_101::utils::ex00_base::Ex00Base::distribute_points;
use starknet_cairo_101::utils::ex00_base::Ex00Base::update_class_hash_by_admin;

struct Storage {

    // Mapping in cairo.
    user_counter: LegacyMap::<ContractAddress, u128>,
    // To read it, user_counter::read(address)
    // To Write it, user_counter::read(address, 23_u128)
}

    #[view]
    fn get_counter_data(_account: ContractAddress) -> u128 {
        let user_counter_data = user_counter::read(_account);
        user_counter_data 
    }

    #[external]
    fn increment_counter() {

        let userAddress = get_caller_address();
        let user_counter_data = user_counter::read(userAddress);
        user_counter::write(userAddress, user_counter_data + 2_u128);
    }

}