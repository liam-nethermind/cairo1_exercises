#[contract]

mod Ex7 {



#[external]
fn compairValues(_a : u128, _b: u128)  {

        assert(_a != 0, "Zero value");
        assert(_a != _b, "Values should not be equal");
        assert (_b <= 40, "Must be smaller than 40");

    }

}