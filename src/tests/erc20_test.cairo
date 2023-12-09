#[cfg(tests)]
mod test {
    use crate::IBalanceDispatcher;
    use crate::Balance;
    #[test]
    fn my_test() {
        let dispatcher = deploy_contract();
        let owner = dispatcher.get_owner();
        assert('Joe' == dispatcher.get_owner(), 'Joe should be the owner.');
    }
    fn deploy_contract() -> IBalanceDispatcher {
        let mut calldata = ArrayTrait::new();
        let (address0, _) = deploy_syscall(
            Balance::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();
        let contract0 = IBalanceDispatcher { contract_address: address0 };
        contract0
    }
}