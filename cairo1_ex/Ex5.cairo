#[contract]
mod Ex5 {

struct Storage {
        user_slots: LegacyMap::<ContractAddress, u128>,
        user_values_public: LegacyMap::<ContractAddress, u128>,
        values_mapped_secret: LegacyMap::<u128, u128>,
        was_initialized: bool,
        next_slot: u128, // + 1
    }

}