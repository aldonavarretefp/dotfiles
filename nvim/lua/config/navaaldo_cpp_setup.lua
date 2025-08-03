-- ============================================================================
-- 1. Function to create C++ project files and set up Neovim layout
--    This function creates .cpp, .in, and .out files based on a base name
--    and then arranges them in a Neovim split layout:
--    - Left pane: .cpp file
--    - Top-right pane: .in file (for input)
--    - Bottom-right pane: .out file (for output)
-- ============================================================================
function _G.create_cpp_project(base_name)
  -- Define file paths
  local cpp_file = base_name .. ".cpp"
  local in_file = base_name .. ".in"
  local out_file = base_name .. ".out"

  -- Helper function to create a file if it doesn't exist
  local function create_file_if_not_exists(filepath)
    local f = io.open(filepath, "a") -- "a" mode creates file if it doesn't exist
    if f then
      f:close()
      return true
    else
      vim.notify("Error: Could not create " .. filepath, vim.log.levels.ERROR)
      return false
    end
  end

  -- Create all three files
  if not create_file_if_not_exists(cpp_file) then
    return
  end
  if not create_file_if_not_exists(in_file) then
    return
  end
  if not create_file_if_not_exists(out_file) then
    return
  end

  -- Set up Neovim window layout
  -- 1. Open the .cpp file in the current buffer
  vim.cmd("edit " .. cpp_file)

  -- 2. Create a vertical split for the .in and .out files on the right
  vim.cmd("vsplit " .. in_file)

  -- 3. In the newly created right pane, create a horizontal split for the .out file
  --    This will make .in the top-right and .out the bottom-right
  vim.cmd("split " .. out_file)

  -- 4. Move focus back to the .cpp file (leftmost pane)
  vim.cmd("wincmd h")

  vim.notify("Project files created and layout set for: " .. base_name, vim.log.levels.INFO)
end

-- Keymap to trigger the file creation and layout setup
-- Press <Leader>nc (e.g., Space + n + c) to activate
vim.keymap.set("n", "<leader>nc", function()
  local base_name = vim.fn.input("Enter base filename (e.g., 'problem_a'): ")
  if base_name ~= "" then
    _G.create_cpp_project(base_name)
  end
end, { desc = "Create C++ project files and setup layout" })

-- ============================================================================
-- 2. Neovim shortcut to compile and run C++ code
--    This function compiles the current .cpp file and then runs it,
--    piping input from the .in file and redirecting output to the .out file.
--    The compilation and execution happen in a floating terminal window.
-- ============================================================================
function _G.run_cpp_code()
  local current_file = vim.fn.expand("%:p") -- Get full path of current file
  -- Ensure we are in a C++ file context for this command
  if vim.fn.fnamemodify(current_file, ":e") ~= "cpp" then
    vim.notify("Not in a .cpp file. Please navigate to your C++ source file.", vim.log.levels.WARN)
    return
  end

  local base_name = vim.fn.fnamemodify(current_file, ":r") -- Get filename without extension
  local cpp_file = base_name .. ".cpp"
  local in_file = base_name .. ".in"
  local out_file = base_name .. ".out"
  local exec_file = "a.out" -- Default executable name

  -- Save the current file before compiling
  vim.cmd("w")

  -- Construct the full command: compile then run
  -- -std=c++17: Use C++17 standard
  -- -Wall -Wextra: Enable all common warnings and extra warnings
  -- -O2: Optimization level 2
  -- &&: Execute run command only if compilation is successful
  local full_cmd = string.format(
    'g++ -std=c++17 -Wall -Wextra -O2 %s -o %s && ./%s < %s > %s && echo "\\n--- Execution Complete ---"',
    cpp_file,
    exec_file,
    exec_file,
    in_file,
    out_file
  )

  -- Open a new floating terminal window to display output
  local term_buf = vim.api.nvim_create_buf(false, true) -- Create a new scratch buffer
  vim.api.nvim_buf_set_option(term_buf, "buftype", "terminal")
  vim.api.nvim_buf_set_option(term_buf, "bufhidden", "wipe") -- Close on exit

  vim.api.nvim_open_win(term_buf, true, {
    relative = "editor",
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    border = "rounded",
    focusable = true,
    title = "C++ Build & Run Output",
    title_pos = "center",
  })

  -- Execute the command in the terminal buffer
  vim.fn.termopen(full_cmd)
end

-- Keymap to run the C++ code
-- Press <Leader>r (e.g., Space + r) to activate
vim.keymap.set("n", "<leader>r", ":lua _G.run_cpp_code()<CR>", { desc = "Compile and Run C++ Code" })

-- ============================================================================
-- 3. C++ Template Snippet using LuaSnip
--    This requires the 'LuaSnip' plugin.
--    Type 'cpptemplate' and press your snippet expansion key (e.g., Tab)
--    to insert the template.
-- ============================================================================
-- Check if luasnip is available
local luasnip_ok, ls = pcall(require, "luasnip")
if not luasnip_ok then
  vim.notify("LuaSnip plugin not found. C++ template snippet will not work.", vim.log.levels.WARN)
  return
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {
  s("cpptemplate", {
    t({
      "#include <iostream>",
      "#include <vector>",
      "#include <string>",
      "#include <algorithm>",
      "#include <map>",
      "#include <set>",
      "",
      "// You can add more common headers here, e.g., <cmath>, <queue>, <stack>",
      "",
      "using namespace std;",
      "",
      "void solve() {",
      "    ",
    }),
    i(1), -- This is where your cursor will be after expanding the snippet
    t({
      "}",
      "",
      "int main() {",
      "    ios_base::sync_with_stdio(false);",
      "    cin.tie(NULL);",
      "    solve();",
      "    return 0;",
      "}",
    }),
  }, { description = "Basic C++ competitive programming template" }),
})

vim.notify("C++ setup loaded successfully!", vim.log.levels.INFO)
