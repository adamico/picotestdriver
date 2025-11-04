# Copilot Instructions for Pico Test Driver (PICO-8 automated game testing framework)

## Project Overview
Pico Test Driver is a comprehensive automated testing framework for PICO-8 cartridges, enabling developers to create, run, and debug tests with detailed output and command-line integration. The framework works within PICO-8's strict constraints: 8192 token limit, limited Lua standard library, no exception handling, and global scope by default.

These instructions help AI assistants understand the framework's patterns and constraints. While AI can accelerate development, remember that PICO-8's unique environment requires human expertise to ensure compatibility with its limitations and design philosophy.

## Key Files
- **`test_framework.lua`** - Core framework managing test phases, frame counting, logging, and initialization
- **`test_utils.lua`** - Testing utilities including assertions, performance measurement, input simulation, and result collection
- **`ptd`** - Bash script for command-line test execution with timeout and parameter passing
- **`test_cart.p8`** - Example cartridge demonstrating framework integration and test patterns
- **`init.lua`** - Example game initialization logic
- **`update.lua`** - Example game update logic
- **`draw.lua`** - Example game drawing logic

## Architecture & Patterns

### PICO-8 Constraint Adaptations
- **No exceptions**: Use return values and `test_log()` for error indication
- **Global scope**: All functions are global; use descriptive naming to avoid conflicts
- **Limited stdlib**: No `pcall`, `table.concat`, `table.unpack` - framework adapts accordingly
- **Single parameter**: Command-line args passed via `stat(6)` as one string

### Function Override Pattern
For testing modified behavior, manually override functions (PICO-8 limitation prevents automatic restoration):

```lua
-- Manual override with documented restoration
original_update = update_player
update_player = function()
    test_log("Debug: player update called", "debug")
    return original_update()
end
-- Remember to restore: update_player = original_update
```

## Developer Workflows

### Basic Integration (5 minutes)
1. **Include framework files** at top of `__lua__` section:
   ```lua
   #include test_framework.lua
   #include test_utils.lua
   ```

2. **Initialize in `_init()`**:
   ```lua
   function _init()
       init_game()
       test_init({
           phases = {"movement", "collision", "combat"},
           default_phase = "all",
           timeout_frames = 1800,  -- 30 seconds at 60fps
           debug_level = "info"
       })
   end
   ```

3. **Update `_update60()`** for test execution:
   ```lua
   function _update60()
       test_update_frame()

       local phase = test_get_phase()
       if phase == "movement" then
           test_movement()
       elseif phase == "all" then
           update_game()  -- Normal game loop
       end
   end
   ```

4. **Run tests** via command line:

## ptd CLI (accurate summary)

- Overview: `ptd` is the repository CLI (see `ptd` at repo root). Key commands are `test`, `generate`, `help`, `version`.

    - `ptd test` details:
    - Flags: `-c|--cart <file>` (cartridge), `-d|--demo` (use demo cart), `-l|--list` (legacy compatibility), `--verbose`, `-h|--help`, `-v|--version`.
    - Positionals: `SUBTEST` (name) and optional numeric `TIMEOUT` (seconds). Defaults: `test_cart.p8`, `30` seconds.
    - Listing subtests: prefer the dedicated `ptd list -c <file>` command to enumerate subtests. Listing is implemented to work without a local PICO‑8 binary. A legacy `--list` flag on `ptd test` is kept for compatibility.
    - Requirements: `pico8` must be in `PATH`; the script uses the `timeout` command to limit runtime. It builds a command like `pico8 -run <cart>` and forwards `-p <subtest>:<timeout>` or `-p timeout:<timeout>`.
    - Useful exit codes: `0` success, `1` invalid args, `2` pico8 missing, `3` cartridge not found, `124` timeout.

- `ptd generate` details:
    - Options: `-d|--dir DIR`, `-n|--name NAME`, `-s|--subtests LIST` (comma-separated), `-t|--timeout SECONDS`, `--framework-path PATH`.
    - Output: `{name}.p8` (includes `#include` to framework and the generated `.lua`) and `{name}.lua` with subtest boilerplate. Default `subtests` is `movement,collision,input,boundary` and default framework path is `../lib/picotestdriver/test_framework.lua`.

- Files to inspect when changing CLI behavior: `ptd` (root), `lib/test_functions.sh`, `run_test.sh` / `run_test_testable.sh`, and the `test/` unit tests that exercise `ptd` (`test/*.sh`). Use those tests to validate CLI changes.

- Editing rules for agents: when adjusting generation templates, keep generated `.p8` compact to avoid PICO‑8 token limits; when changing `--list` logic, update unit tests in `test/` accordingly.

# Copilot Instructions — Pico Test Driver (concise)

Purpose: give AI coding agents the minimal, actionable knowledge to be productive in this repo.

- Big picture: this repo is a PICO-8 test framework. Key runtime is PICO-8's 60 FPS game loop; tests are frame-aware and organized into named phases.

- Important constraints: PICO-8 has an 8192 token limit, no exceptions, limited stdlib, and global scope. Prefer small functions, concise names, and explicit restoration when overriding globals.

- Conventions you must follow: test functions named `test_feature_name()`, setup functions `setup_*()`, call `test_complete()` when done, and use `test_assert*` helpers for checks.

- Editing rules for AI agents: avoid long-form changes that increase token usage in cartridges; when overriding global functions, add a documented restore and brief comment. Do not assume availability of Lua stdlib helpers like `pcall` or `table.unpack`.

- Terminal command rules for auto-approval in this workspace: check the current working directory first; avoid single-line `cd /path && cmd` patterns — use a single `cd /path` then run commands, or use a subshell `(cd /path && cmd)` for one-offs.

- Versioning & commits: repo uses Conventional Commits; follow `feat/fix/docs/test/refactor/chore/ci` conventions. Use scripts in `scripts/` for changelog automation if present.

If anything here is unclear or you want the file to be longer/shorter or translated, tell me which sections to expand or remove and I will iterate.


### Assertion Patterns
