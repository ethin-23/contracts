#[cfg(test)]
mod tests {
    use starknet::{contract_address_const, contract_address_to_felt252};
    use array::SpanTrait;
    use contracts::erc20::ITxnJobs;
    use contracts::erc20::balance;
    use starknet::syscalls::{deploy_syscall, SyscallResult};
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;
    use core::result::ResultTrait;
    use contracts::erc20::ITxnJobsDispatcher;
    use contracts::erc20::ITxnJobsDispatcherTrait;
    use starknet::ContractAddress;
    use debug::PrintTrait;
    use traits::Into;

    #[test]
    #[available_gas(2000000)]
    fn create_transfer_job_test() {
        let dispatcher = deploy_contract();
        dispatcher.create_transfer_job
        
        assert(, '');
    }
    fn deploy_contract() -> ITxnJobsDispatcher {
        let mut calldata = ArrayTrait::new();
        let address = contract_address_const::<0x42>();
        calldata.append(10000);
        calldata.append(0);
        calldata.append(contract_address_to_felt252(address));
        let address0: ContractAddress =
            match deploy_syscall(
                balance::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
            ) {
            Result::Ok((addr, _)) => { addr },
            Result::Err(e) => {
                'error'.print();
                e.print();
                let address = contract_address_const::<0x42>();
                address
            }
        };

        let contract0 = ITxnJobsDispatcher { contract_address: address0 };
        contract0
    }
}
