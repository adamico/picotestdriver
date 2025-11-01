# picotestdriver todo:


## docs

- [x] main README file: 
  - [x] **"Test cartridge not found"** section is outdated
  - [x] ### Debug Tips section is outdated


## fixes
- [x] test_framework.lua and test_utils.lua: remove hardcoded references to the library version or find a way to read the VERSION file, but I don't think we can do this in pico8. assess the pros and cons of using a second source of truth in .lua files which could be also updated by the generate_changelog.sh script
- [ ] test_utils.lua:
  - [ ] the input simulation functions (test_press, test_release, test_hold) will never be used in their current implementation nor overridden in a pico8 test cartridge. Brainstorm an easy way of keeping these functions (maybe adding a callback as arguments) or remove them and all the references in the readme.md. If we removed these functions we need to improve the docs to help user write similar functions to test user input etc. (use our obsi project test.lua file as a reference)
  - [x] test_log_memory_usage function can use the stat(0) pico8 command (see pico8 manual https://www.lexaloffle.com/dl/docs/pico-8_manual.html#STAT)
  - [x] remove emoticons because they are interpreted as specific ascii code which return katakana symbols


## improvements
- [ ] add color to the ptd command output
- [x] test_utils.lua: add a test_log_cpu_usage function using stat(1) (see https://www.lexaloffle.com/dl/docs/pico-8_manual.html#STAT), document this addition in the main README file


## new features

- [ ] Visual test results display in PICO-8 UI
- [ ] Screenshot comparison for visual regression testing
- [ ] Test result export (JSON/CSV format)
- [ ] Performance regression detection
- [ ] GitHub Actions workflow examples
- [ ] Advanced mocking/stubbing utilities