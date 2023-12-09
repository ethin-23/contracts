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
trait IERC20<T> {// Get from openzeppelin
}


#[starknet::interface]
trait ITxnJobs<T> {
    // Returns the current balance.
    fn get_jobs(self: @T) -> Span<Job>;
    // Increases the balance by the given amount.
    fn increase(ref self: T, a: u128);
}

#[starknet::contract]
mod Balance {
    use traits::Into;
    use super::Job;

    #[storage]
    struct Storage {
        value: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, value_: u128) {
        self.value.write(value_);
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

        fn increase(ref self: ContractState, a: u128) {
            self.value.write(self.value.read() + a);
        }
    }
}
