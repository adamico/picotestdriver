# picotestdriver todo:


## docs


## fixes
- [x] test_utils.lua: Replaced stub input simulation functions with state-based approach
  - Provides test_set_button_state/test_get_button_state for games with custom input wrappers
  - Includes example of how to make game code testable
  - Documents that PICO-8's btn() can't be directly overridden


## new features

- [ ] Visual test results display in PICO-8 UI
- [ ] Screenshot comparison for visual regression testing
- [ ] Test result export (JSON/CSV format)
- [ ] Performance regression detection
- [ ] GitHub Actions workflow examples
- [ ] Advanced mocking/stubbing utilities