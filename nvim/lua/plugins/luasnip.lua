-- Example for lazy.nvim
return {
  "L3MON4D3/LuaSnip",
  -- lazy-load on filetype
  ft = { "cpp", "c" },
  build = "make install_jsregexp", -- If you need regex support
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
    -- You might have other luasnip setup here, e.g., keymaps for jumping
    -- For example, to jump to next/previous snippet node:
    -- vim.keymap.set({"i", "s"}, "<Tab>", function() ls.jump(1) end, {silent = true})
    -- vim.keymap.set({"i", "s"}, "<S-Tab>", function() ls.jump(-1) end, {silent = true})
  end,
}
