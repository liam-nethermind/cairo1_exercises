
#[contract]

mod Ex1 {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[constructor]
    fn constructor(){

    }

    #[external]
    fn claim_points(){

        let sender_address = get_caller_address();
        
    }
}