#[cfg(test)]
mod tests {
    #[test]
    #[available_gas(2000000)]
    #[should_panic]
    fn another() {
        let result = 2 + 2;
        assert(result == 6, 'Should fail');
    }
    #[test]
    #[available_gas(2000000)]
    fn yet_another() {
        let result = 3 * 2;
        assert(result == 6, 'Make this test pass');
    }
}
