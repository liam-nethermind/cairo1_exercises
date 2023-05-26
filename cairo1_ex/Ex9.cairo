#[contract]

mod Ex9 {
    use starknet::get_caller_address;
    use array::ArrayTrait;

    #[external]
    fn claim_point(arr:Array::<u128>) {

        assert(!arr.is_empty(), "Array is empty");
        assert(arr.len()>= 3, "Leng shound greater!");
        let mut sum:u128 = 0_128;
        let total = get_sum_internal(sum, arr);
    }

    // internal prvate fin
    fn get_sum_internal(mut sum:u128, mut values:Array::<u128>) -> u128 {

        if !values.is_empty() {
            sum = sum + values.pop_front().unwrap();
            return get_sum_internal(dum, values);
        }
    }
}