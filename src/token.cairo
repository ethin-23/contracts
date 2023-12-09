use starknet::{ClassHash, ContractAddress};
// type ContractAddressEnc = (u256, u256, u128);
type ContractAddressEnc = ContractAddress;
use openzeppelin::token::erc20::interface;

#[derive(Serde, Copy, Drop, starknet::Store, Hash, PartialEq)]
enum JobStatus {
    Pending,
    Failed,
    Success,
}

#[derive(Serde, Copy, Drop, starknet::Store, Hash)]
struct Job {
    amount: u128,
    sender: ContractAddressEnc,
    recipient: ContractAddressEnc,
    timestamp: u64,
    status: JobStatus,
}

#[starknet::interface]
trait ITxnJobs<T> {
    fn mint(ref self: T, addr: ContractAddress, amt: u256);
    fn he_vars(ref self: T, n: u256, g: u256);
    fn balance_of(self: @T, addr: ContractAddress) -> u256;
    fn replace_class(ref self: T, class_hash: ClassHash); // Returns the current balance.
    fn get_transfer_jobs(self: @T) -> Span<Job>;
    fn process_jobs(ref self: T, job_ids: Array<u64>);
    // Increases the balance by the given amount.
    fn create_transfer_job(ref self: T, amount: u128, recipient: ContractAddressEnc);
}

#[starknet::contract]
mod balance {
    use openzeppelin::token::erc20::interface;
    use openzeppelin::token::erc20::interface::{IERC20, IERC20Metadata};
    use traits::Into;
    use super::{Job, JobStatus, ContractAddressEnc};
    use starknet::{ContractAddress, ClassHash, syscalls, get_caller_address};
    use openzeppelin::token::erc20::ERC20Component;

    // use starknet::block_timestamp;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[external(v0)]
    impl ERC20MetadataImpl of IERC20Metadata<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.erc20.name()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self.erc20.symbol()
        }
        fn decimals(self: @ContractState) -> u8 {
            4
        }
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        jobs: LegacyMap<u64, Job>,
        total_jobs: u64,
        processed_jobs: u64,
        admin: ContractAddress,
        balances: LegacyMap<ContractAddressEnc, u256>,
        he_vars: (u256, u256),
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, name: felt252, symbol: felt252, admin: ContractAddress
    ) {
        self.erc20.ERC20_name.write(name);
        self.erc20.ERC20_symbol.write(symbol);
        self.admin.write(admin);
        self.total_jobs.write(0);
        self.processed_jobs.write(0);
    }

    #[abi(embed_v0)]
    impl TxnJobs of super::ITxnJobs<ContractState> {
        fn he_vars(ref self: ContractState, n: u256, g: u256) {
            self.he_vars.write((n, g));
        }

        fn mint(ref self: ContractState, addr: ContractAddress, amt: u256) {
            assert(get_caller_address() == self.admin.read(), 'only admin');
            let (n, g) = self.he_vars.read();
            // @TODO
            addr;
        }

        fn replace_class(ref self: ContractState, class_hash: ClassHash) {
            assert(get_caller_address() == self.admin.read(), 'only admin');
            syscalls::replace_class_syscall(class_hash);
        }
        fn get_transfer_jobs(self: @ContractState) -> Span<Job> {
            let mut jobs = ArrayTrait::new();
            let total_jobs: u64 = self.total_jobs.read();
            let processed_jobs: u64 = self.processed_jobs.read();
            let mut i = processed_jobs;
            loop {
                if i == total_jobs {
                    break;
                }
                let job = self.jobs.read(i);
                if job.status == JobStatus::Pending {
                    jobs.append(job);
                }
                i += 1;
            };
            jobs.span()
        }

        fn balance_of(self: @ContractState, addr: ContractAddress) -> u256 {
            self.balances.read(addr)
        }

        fn process_jobs(ref self: ContractState, job_ids: Array<u64>) {
            let mut i = 0;
            loop {
                if i == job_ids.len() {
                    break;
                }
                let job_id = *job_ids.at(i);
                let job = self.jobs.read(job_id);
                process_job(ref self, job_id, job);
                i += 1;
            };
        }
        fn create_transfer_job(
            ref self: ContractState, amount: u128, recipient: ContractAddressEnc
        ) {
            let job = Job {
                amount,
                sender: get_caller_address(),
                recipient,
                timestamp: 0,
                status: JobStatus::Pending
            };
            let total_jobs: u64 = self.total_jobs.read();
            self.total_jobs.write(total_jobs + 1);
            self.jobs.write(total_jobs, job);
        }
    }

    fn to_256(low: u128) -> u256 {
        u256 { low, high: 0 }
    }

    fn process_job(ref self: ContractState, job_id: u64, mut job: Job) {
        if job.status == JobStatus::Pending {
            let amount = job.amount;

            let mut sender_bal = self.balances.read(job.sender);
            let mut recepient_bal = self.balances.read(job.recipient);

            let (n, g) = self.he_vars.read();
            let n2 = n * n;

            // Paillier subtraction
            sender_bal = sender_bal / to_256(amount) % n2;
            self.balances.write(job.sender, sender_bal);

            // Paillier addition
            recepient_bal = recepient_bal * to_256(amount) % n2;
            self.balances.write(job.recipient, recepient_bal);

            // Update the job status
            job.status = JobStatus::Success;
            self.jobs.write(job_id, job);
        // @TODO
        }
    }
}
