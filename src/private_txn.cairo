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
trait ITxnJobs<T> {
    // Returns the current balance.
    fn get_transfer_jobs(self: @T) -> Span<Job>;
    // Increases the balance by the given amount.
    fn create_transfer_job(ref self: T, amount: u128, recipient: (u128, u128, u64));
}

#[starknet::contract]
mod balance {
    use openzeppelin::token::erc20::interface::IERC20;
    use traits::Into;
    use super::{Job, JobStatus,};
    use starknet::{ContractAddress, ClassHash, syscalls, get_caller_address};
    use openzeppelin::token::erc20::ERC20Component;
    // use starknet::block_timestamp;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;

    type ContractAddressEnc = (u128, u128, u64);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        jobs: LegacyMap<u64, Job>,
        total_jobs: u64,
        processed_jobs: u64,
        admin: ContractAddress,
        balances: LegacyMap<ContractAddressEnc, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        supply: u256,
        admin: ContractAddress
    ) {
        self.erc20.ERC20_name.write(name);
        self.erc20.ERC20_symbol.write(symbol);
        self.admin.write(admin);
        self.total_jobs.write(0);
        self.processed_jobs.write(0);
    }

    fn replace_class(ref self: ContractState, class_hash: ClassHash) {
        assert(get_caller_address() == self.admin.read(), 'only admin');
        syscalls::replace_class_syscall(class_hash);
    }

    #[abi(embed_v0)]
    impl TxnJobs of super::ITxnJobs<ContractState> {
        fn get_transfer_jobs(self: @ContractState) -> Span<Job> {
            let mut jobs = ArrayTrait::new();
            let total_jobs: u64 = self.total_jobs.read();
            let processed_jobs: u64 = self.processed_jobs.read();
            let mut i = processed_jobs;
            loop {
                if i == total_jobs {
                    break;
                } else {
                    let job = self.jobs.read(i);
                    if job.status == JobStatus::Pending {
                        jobs.append(job);
                    }
                    i += 1;
                }
            };
            jobs.span()
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
