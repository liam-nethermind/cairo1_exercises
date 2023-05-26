use starknet::ContractAddress;
use array::ArrayTrait;

//###################
// IERC721 INTERFACE
//###################

#[abi]
trait IERC721 {
    fn name() -> felt252;
    fn symbol() -> felt252;
    fn balance_of(account: ContractAddress) -> u256;
    fn owner_of(token_id: u256) -> ContractAddress;
    fn get_approved(token_id: u256) -> ContractAddress;
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool;
    fn total_supply() -> u256;
    fn token_uri(token_id: u256) -> Array::<felt252>;
    fn owner() -> ContractAddress;
    fn set_base_uri(uri: Array::<felt252>);
    fn set_approval_for_all(operator: ContractAddress, approved: bool);
    fn approve(to: ContractAddress, token_id: u256);
    fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256);
    fn burn(token_id: u256);
    fn mint();
}
