#[contract]

mod Ex8 {

    use starknet::ContractAddrss;

    struct Storage {
        user_value: LegacyMap::<ContractAddress, u128>,

        user_value2: LegacyMap:: <ContractAddress, u128), u128> ,
    }


    
    #[view]
    fn read_storage_1(_acc: ContractAddress ) -> u128{
        return user_value::read(_acc);
    }
    
    #[view]
    fn read_storage_2(account:ContractAddress, slot:u128) -> u128{
        user_value2::read(account, slot)
    }

    // Recursive function
    // Internal/ Private functions
    fn set_user_values_internal(_acc: ContractAddress, mut idx: u128, mut values: Array::<u128> ) {
        if !values.isEmpty() {
            user_value2::write( (_acc, idx), values.pop_front().unwrap() );
            idx = idx + 1_u128;
        }
    }



}