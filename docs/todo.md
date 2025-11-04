# picotestdriver todo:

## High Priority

- remove the default timeout set in the ptc command, this interferes with tests that set their own timeouts via test_calculate_timeout. instead, if no timeout is set in the test, the test framework should use an infinite timeout (or a very high default value) to avoid unintended test failures due to timeouts. this will allow tests to have full control over their timeout settings without being overridden by the command-line default.

- [ ] add a test function which avoid repeating if statements like this:
  ```lua
     if frame == 10 then
      test_log("Testing UI display elements...", "info")
      p.lives = 3
      game_state = "playing"
      score = 0
   end
  ```
  maybe something like:
    ```lua

    function test_at_frame(frame_number, message, log_level, test_block)
      if test_get_frame_count() == frame_number then
        test_log(message, log_level)
        test_block()
      end
    end
    
    -- usage
    test_at_frame(frame_number, "Testing UI display elements...", "info", function()
      p.lives = 3
      game_state = "playing"
      score = 0
    end)
    ```

- update README with:
  -  information about the limit of including external files in test cartridges. remind of pico8 limits:
    - max 8192 tokens per cartridge
    - max 65536 bytes of code/data
    - max 15616 compressed bytes
  - include hints about optimizing test writing for larger projects using multiple .p8 files for specific modules or components, and how to structure tests accordingly. using common setup/teardown functions to reduce redundancy across tests. use obsi tests cartridges as examples, without going into too much detail because obsi is not released yet.
  - info about running pico8 in headless mode for automated testing environments. (pico -x test_cartridge.p8)

## Mid Priority
## Low Priority