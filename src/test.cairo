use starknet::{contract_address_const, contract_address_to_felt252};
use contracts::token::ITxnJobs;
use contracts::token::balance;
use starknet::syscalls::{deploy_syscall, SyscallResult};
use starknet::class_hash::Felt252TryIntoClassHash;
// use core::result::ResultTrait;
use contracts::token::{ITxnJobsDispatcher, ITxnJobsDispatcherTrait};
use starknet::ContractAddress;
use debug::PrintTrait;
use openzeppelin::token::erc20::interface::{
    IERC20MetadataDispatcher, IERC20MetadataDispatcherTrait, IERC20Dispatcher, IERC20DispatcherTrait
};

#[test]
#[available_gas(2000000000)]
fn joe_test() {
    let contract = deploy_erc20_meta();
    let sym = contract.name();
    sym.print();
    assert('moi-token' == sym, 'Joe should be the owner.');
}
fn deploy_erc20_meta() -> IERC20MetadataDispatcher {
    IERC20MetadataDispatcher { contract_address: deploy_contract().contract_address }
}
fn deploy_contract() -> ITxnJobsDispatcher {
    let mut calldata = ArrayTrait::new();
    let address = contract_address_const::<0x42>();
    calldata.append('moi-token');
    calldata.append('moi');
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
