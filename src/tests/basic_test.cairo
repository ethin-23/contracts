#[cfg(test)]
mod tests {
    #[test]
    fn another() {
        let result = 2 + 2;
        assert(result == 6, 'Should fail');
    }
    #[test]
    fn yet_another() {
        let result = 3 * 2;
        assert(result == 6, 'Make this test pass');
    }
}
