%lang starknet

from starknet.cairo.commom.cairo_builtins import HashBuiltin
from starknet.cairo.commom.hash import hash2
from starknet.cairo.commom.alloc import alloc
from starknet.cairo.commom.math import (assert_le, assert_nn_le, unsigned_div_rem)
from starknet.cairo.commom.syscalls(get_caller_address, storage_read, storage_write)

//@dev the maximum amount of each token that belongs ot the AMM
const BALANCE_UPPER_BOUND = 2 ** 64;

const TOKEN_TYPE_A = 1;
const TOKEN_TYPE_B = 2;

// @dev Ensure user's balance are much smaller than the pool's balance
const POOL_UPPER_BOUND = 2 ** 30;
const ACCOUNT_BALANCE_BOUND = 1073741; // (2 ** 30 / 1000)

//STORAGE VARIABLES
//@dev a map from account and token type to corresponding balance
@storage_var
func account_bal(account_id: felt, token_type: felt) -> (balance: felt) {}

//@dev a map from token type to corr pool balance
@storage_var
func pool_balance(token_type: felt) -> (balance: felt) {}

// GETTER FUNCS
// @dev returns account balance for a given token
// @param account_id Account to be queried
// @param token_type Token to be queried

@view
func get_token_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account_id: felt, token_type: felt) -> (balance: felt) {
    return account_bal.read(account_id, token_type);
}


//@dev return the pool's balance
//@param token_type To get the pool's balance
@view
func get_token_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_type: felt) -> (balance: felt) {
    return pool_balance.read(token_type);
}

//  EXTERNALS
//@dev set pool balance for a given token
//@param token_type Token whose balance is to be set
//@param amount Amount to be set as balance

@external
func set_pool_token_bal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_type: felt, balance: felt
) {
    with_attr error_message("exceeds max allowed tokens") {
    assert_nn_le(balance, BALANCE_UPPER_BOUND - 1);
}
    pool_balance.write(token_type, balance);
    return ();
}

//@dev add demo token to the given account
//@param token_a_amount Amount of token a to be added
//@param token_b_amount Amount of token b to be added

@external
func add_demo_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    (token_a_amount: felt, token_b_amount: felt)
) {
    alloc_locals;
    let (account_id) = get_caller_address();

    modify_account_balance(account_id = account_id, token_type = TOKEN_TYPE_A, amount = token_a_amount);
    
    modify_account_balance(account_id = account_id, token_type = TOKEN_TYPE_B, amount = token_b_amount);

    return ();
}

//@dev initialize AMM
//@param token_a Amount of token a to be set in pool
// @param token_b Amount of token b to se set in pool

@external
func init_pool{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_a: felt, token_b:felt
) {
    with_attr error_message("exceeds max allowed tokens"){
    assert_nn_le(token_a, POOL_UPPER_BOUND - 1);
    assert_nn_le(token_b, POOL_UPPER_BOUND - 1);
    }

    set_pool_token_bal(token_type = TOKEN_TYPE_A, balance = token_a);
    set_pool_token_bal(token_type = TOKEN_TYPE_B, balance = token_b);

    return ();
}

//@dev Swap tokens between the given accounts and the pool
//@param token_from Token to be swapped
//@param amount_from Amount of token to be swapped

@external
func swap{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_from: felt, amount_from: felt
) -> (amount_to: felt) {
    alloc_locals;
    let (account_id) = get_caller_address();

    //verify token_from is TOKEN_TYPE_A or TOKEN_TYPE_B
    with_attr error_message("token not allowed in the pool") {
        assert (token_from - TOKEN_TYPE_A) * (token_from - TOKEN_TYPE_B) = 0;
    }

    //check requested amount is valid
    with_attr error_message("exceeds max allowed tokens"){
        assert_nn_le(amount_from, BALANCE_UPPER_BOUND - 1);
    }

    //CHECK USER HAS ENOUGH FUNDS
    let (account_from_balance) = get_token_balance(account_id=account_id, token_type=token_from);
    with_attr error_message("insufficient balance."){
        assert_le(amount_from, account_from_balance);
    }

    let (token_to) = get_opposite_token(token_type = token_from);
    let (amount_to) = do_swap(account_id=account_id, token_from=token_from, token_to=token_to, amount_from=amount_from);

    return (amount_to=amount_to);
}

// INTERNALS
//@dev internal func that updates account balance for a given token
//@param account_id Account whose balance is to be modified
//@param token_type Token type to be modified
//@param amount Amount to be added 

func modify_account_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*,
range_check_ptr}(
    account_id: felt, token_type: felt, amount: felt
    ) {
    let (current_balance) = account_bal.read(account_id, token_type);
    tempvar new_balance = current_balance + amount;

    with_attr error_message("exceeds max allowed tokens"){
        assert_nn_le(new_balance, BALANCE_UPPER_BOUND - 1);
    }

    account_bal.write(account_id=account_id, token_type=token_type, value=new_balance);
    return ();
    }

//@dev internal function that swaps tokens btw the given account and the pool
//@param account_id Account whose tokens are to be swapped
//@param token_from, token_to, amount_from

func do_swap{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*,
range_check_ptr}(
    account_id: felt, token_from:felt, token_to:felt, amount_from: felt
    ) -> (amount_to: felt) {
    alloc_locals;

    // get pool balance
    let (local amm_from_balance) = get_token_balance(token_type=token_from);
    let (local amm_to_balance) = get_token_balance(token_type=token_to);

    // calculate swap amount
    let(local amount_to, _) = unsigned_div_rem((amm_to_balance * amount_from), (amm_from_balance + amount_from));

    //update token_from balances
    modify_account_balance(account_id=account_id, token_type=token_from, amount = amount_from);
    set_pool_token_bal(token_type=token_from, balance=(amm_from_balance + amount_from));

    //update token_to balances
    modify_account_balance(account_id=account_id, token_type=token_to, amount=amount_to);
    set_pool_token_bal(token_type=token_to, balance=(amm_to_balance - amount_to));

    return (amount_to=amount_to);
}

//@dev internal function to get the oppoaite token type
//@param token_type Token whose opposite pair needs to be gotten

func get_opposite_token(token_type: felt) -> (t: felt) {
    if(token_type == TOKEN_TYPE_A){
        return (t = TOKEN_TYPE_B);
    } else {
        return (t = TOKEN_TYPE_A);
    }
}
