#[cfg(test)]
mod test {
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
    #[available_gas(2000000000)]
    fn joe_test() {
        let dispatcher = deploy_contract();
        let _owner = dispatcher.get_owner();
        assert('Joe' == dispatcher.get_owner(), 'Joe should be the owner.');
    }
    fn deploy_contract() -> ITxnJobsDispatcher {
        let mut calldata = ArrayTrait::new();
        let address = contract_address_const::<0x42>();
        calldata.append(0);
        calldata.append(10000);
        calldata.append(contract_address_to_felt252(address));

        'err1'.print();
        let address0: ContractAddress =
            match deploy_syscall(
                balance::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
            ) {
            Result::Ok((addr, _)) => {
                'ok'.print();
                addr.print();
                addr
            },
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
