#[derive(Serde, Copy, Drop, starknet::Store, Hash, PartialEq)]
enum JobStatus {
    Pending,
    Failed,
    Success,
}

#[derive(Serde, Copy, Drop, starknet::Store, Hash)]
struct Job {
    amount: u128,
    recipient: (u128, u128, u64),
    timestamp: u64,
    status: JobStatus
}

#[starknet::interface]
trait IERC20<T> { // Get from openzeppelin
}


#[starknet::interface]
trait ITxnJobs<T> {
    // Returns the current balance.
    fn get_transfer_jobs(self: @T) -> Span<Job>;
    // Increases the balance by the given amount.
    fn increase(ref self: T, a: u128);
    // Just a test, remove afterwards
    fn get_owner(self: @T) -> felt252;
    // Just a test, remove afterwards
    fn get_total_supply(self: @T) -> u256;
    fn create_transfer_job(ref self: T, amount: u128, recipient: (u128, u128, u64));
}

#[starknet::contract]
mod balance {
    use openzeppelin::token::erc20::interface::IERC20;
    use traits::Into;
    use super::{Job, JobStatus,};
    use starknet::ContractAddress;
    use openzeppelin::token::erc20::ERC20Component;
    // use starknet::block_timestamp;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        jobs: LegacyMap<u64, Job>,
        total_jobs: u64,
        processed_jobs: u64,
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
        self.total_jobs.write(0);
        self.processed_jobs.write(0);
    }


    impl ERC20 of super::IERC20<ContractState> {}

    #[abi(embed_v0)]
    impl TxnJobs of super::ITxnJobs<ContractState> {
        fn get_transfer_jobs(self: @ContractState) -> Span<Job> {
            let mut jobs = ArrayTrait::new();
            let total_jobs: u64 = self.total_jobs.read();
            let processed_jobs: u64 = self.processed_jobs.read();
            let mut i = total_jobs - processed_jobs;
            loop {
                if i == 0 {
                    break;
                } else {
                    let job = self.jobs.read(i);
                    if job.status == JobStatus::Pending {
                        jobs.append(job);
                    }
                    i -= 1;
                }
            // TODO

            // self.processed_jobs += 1;
            };
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
        fn create_transfer_job(
            ref self: ContractState, amount: u128, recipient: (u128, u128, u64)
        ) {
            let job = Job { amount, recipient, timestamp: 0, status: JobStatus::Pending };
            let total_jobs: u64 = self.total_jobs.read();
            self.total_jobs.write(total_jobs + 1);
            self.jobs.write(total_jobs, job);
        // Add job to array
        }
    }
}
