-- Game state
local player = {
  x = 64,
  y = 64,
  dx = 0,
  dy = 0,
  speed = 1,
  color = 7
}

local enemies = {}
local bullets = {}

-- Test state
local test_frame = 0
local current_subtest = 1
local subtest_start_frame = 0

-- Subtest definitions
local subtests = {
  { name = "movement",         duration = 120 },
  { name = "collision",        duration = 120 },
  { name = "input",            duration = 120 },
  { name = "boundary",         duration = 120 },
  { name = "assertions",       duration = 120 },
  { name = "timing",           duration = 180 },
  { name = "edge_cases",       duration = 120 },
  { name = "test_utils",       duration = 240 },
  { name = "timeout_calc",     duration = 120 },
}

function _init()
  test_log("=== PICOTESTDRIVER DEMO ===", "info")

  -- Pass subtests with durations to test_init
  -- Timeout will be auto-calculated based on total duration + buffer
  test_init({
    subtests = subtests,  -- Pass full subtest table with durations
    timeout_buffer = 180, -- 3 second safety buffer (default, can be omitted)
    debug_level = "info",
    log_file = "test_demo.log",  -- Save all logs to this file
    cart_name = "test_demo"  -- Prefix for export files
  })

  init_game()
  test_frame = 0

  -- Find which subtest to start with based on command line
  local requested_subtest = test_get_subtest()
  current_subtest = 1

  if requested_subtest ~= "default" and requested_subtest ~= "all" then
    -- Find the requested subtest
    local found = false
    for i = 1, #subtests do
      if subtests[i].name == requested_subtest then
        current_subtest = i
        found = true
        break
      end
    end

    if not found then
      test_log("Requested subtest '" .. requested_subtest .. "' not found, running all", "warn")
      current_subtest = 1
    end
  end

  subtest_start_frame = 0

  test_log("Starting subtest: " .. subtests[current_subtest].name, "info")
end

function init_game()
  player.x = 64
  player.y = 64
  player.dx = 0
  player.dy = 0
  enemies = {}
  bullets = {}
end
