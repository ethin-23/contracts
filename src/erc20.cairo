#[derive(Serde, Copy, Drop, starknet::Store)]
enum JobStatus {
    Pending,
    Failed,
    Success,
}

#[derive(Serde, Copy, Drop, starknet::Store)]
struct Job {
    amount: u128,
    recepient: (u128, u128, u64),
    timestamp: u64,
    status: JobStatus
}

#[starknet::interface]
trait IERC20<T> { // Get from openzeppelin
}


#[starknet::interface]
trait ITxnJobs<T> {
    // Returns the current balance.
    fn get_jobs(self: @T) -> Span<Job>;
    // Increases the balance by the given amount.
    fn increase(ref self: T, a: u128);
    // Just a test, remove afterwards
    fn get_owner(self: @T) -> felt252;
    // Just a test, remove afterwards
    fn get_total_supply(self: @T) -> u256;
}

#[starknet::contract]
mod balance {
    use openzeppelin::token::erc20::interface::IERC20;
    use traits::Into;
    use super::Job;
    use starknet::ContractAddress;
    use openzeppelin::token::erc20::ERC20Component;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, supply: u256, recipient: ContractAddress) {
        let name = 'PrivateToken';
        let symbol = 'PRIV';

        self.erc20.initializer(name, symbol);
        self.erc20._mint(recipient, supply);
    }

    fn add_job() {}

    impl ERC20 of super::IERC20<ContractState> {}

    #[abi(embed_v0)]
    impl TxnJobs of super::ITxnJobs<ContractState> {
        fn get_jobs(self: @ContractState) -> Span<Job> {
            let mut jobs = array![];

            // Gets jobs and add to array

            jobs.span()
        }

        fn increase(ref self: ContractState, mut a: u128) {
            a += 1;
        }
        fn get_owner(self: @ContractState) -> felt252 {
            return 'Joe';
        }
        fn get_total_supply(self: @ContractState) -> u256 {
            return self.erc20.total_supply();
        }
    }
}
