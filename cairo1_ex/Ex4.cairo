#[contract]
mod Ex4 {

use starknet::get_caller_address;
use starknet::ContractAddress;
use starknet::ArrayTrait;
use starknet::OptionTrait;

struct Storage {

    user_slot: LegacyMap::<ContractAddress, u128>,
    value_map: LegacyMap::<u128, u128>,
    was_initialized: bool,
}

#[view] 
fn get_values_mapped(slot:u128) -> u128 {}
    return value_map::read(slot);
}