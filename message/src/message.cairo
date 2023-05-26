#[contract]
//This contract represents a message contract that 
// allows users to write and read messages. 

mod Message {
    //It imports the get_caller_address and ContractAddress type from the starknet crate.
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[event]
    fn Message_Event(caller: ContractAddress, value: felt252) {}


    //holds the state of the contract
    struct Storage {
        msg: felt252
    }

    //constructor function initializes the msg field with 'Hello, World'.
    #[constructor]
    fn constructor() {
        msg::write('Hello, World');
    }

    #[external]
    fn write_msg(value: felt252) {
        let caller = get_caller_address();
        msg::write(value);

        Message_Event(caller, value);
    }

    #[view]
    fn read_msg() -> felt252 {
        msg::read()
    }
}
