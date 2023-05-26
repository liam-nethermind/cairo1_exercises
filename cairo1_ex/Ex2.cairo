#[contract]

mod Ex2 {
    // Core library imports for writing smart contracts 
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    // Storage is declared as struct.
    struct Storage {
        secret_val :: u128,   
    }

    #[view]
    fn my_secret_value() -> u128 {
        secret_val::read()
    }

    #[external]

    fn claimPoints(user_input: u128) {
        let user_address = get_caller_address();
        assert(user_address == user_input), "Both address must be the same ";
    }
}