-- Helper function to advance to the next subtest
function next_subtest()
  local requested_subtest = test_get_subtest()

  -- If running a specific subtest, stop after it completes
  if requested_subtest ~= "default" and requested_subtest ~= "all" then
    test_log("Subtest '" .. requested_subtest .. "' complete!", "info")
    test_complete("Subtest complete")
    return
  end

  -- Otherwise, advance to next subtest
  current_subtest += 1
  subtest_start_frame = test_frame

  if current_subtest <= #subtests then
    test_log("Advancing to subtest: " .. subtests[current_subtest].name, "info")
    init_game()
  else
    test_log("All subtests complete!", "info")
    
    -- Export test results in multiple formats (uses cart_name prefix)
    test_export_json()  -- Creates test_demo_results.json
    test_export_csv()   -- Creates test_demo_results.csv
    test_export_markdown()  -- Creates test_demo_results.md
    
    test_complete("All subtests complete")
  end
end

-- Test functions (movement, collision, input, boundary, assertions, timing, etc.)
-- (content moved from demo helper; keep tests short in this file)
-- The larger test function implementations are kept in `test_helper.lua` at repo root
