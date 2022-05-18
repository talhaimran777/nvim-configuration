local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

local M = {}

M.autopairs = function()
   local present1, autopairs = pcall(require, "nvim-autopairs")
   local present2, cmp = pcall(require, "cmp")

   if not present1 and present2 then
      return
   end

   autopairs.setup {
      fast_wrap = {},
      disable_filetype = { "TelescopePrompt", "vim" },
   }

   local cmp_autopairs = require "nvim-autopairs.completion.cmp"

   cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

M.better_escape = function()
   local present, escape = pcall(require, "better_escape")

   if not present then
      return
   end

   local options = {
      mapping = { "jk" }, -- a table with mappings to use
      timeout = vim.o.timeoutlen,
      clear_empty_lines = false, -- clear line after escaping if there is only whitespace
      keys = "<Esc>",
   }

   options = nvchad.load_override(options, "max397574/better-escape.nvim")
   escape.setup(options)
end

M.blankline = function()
   local present, blankline = pcall(require, "indent_blankline")

   if not present then
      return
   end

   local options = {
      indentLine_enabled = 1,
      char = "▏",
      filetype_exclude = {
         "help",
         "terminal",
         "alpha",
         "packer",
         "lspinfo",
         "TelescopePrompt",
         "TelescopeResults",
         "nvchad_cheatsheet",
         "lsp-installer",
         "",
      },
      buftype_exclude = { "terminal" },
      show_trailing_blankline_indent = false,
      show_first_indent_level = false,
   }

   options = nvchad.load_override(options, "lukas-reineke/indent-blankline.nvim")
   blankline.setup(options)
end

M.colorizer = function()
   local present, colorizer = pcall(require, "colorizer")

   if not present then
      return
   end

   local options = {
      filetypes = {
         "*",
      },
      user_default_options = {
         RGB = true, -- #RGB hex codes
         RRGGBB = true, -- #RRGGBB hex codes
         names = false, -- "Name" codes like Blue
         RRGGBBAA = false, -- #RRGGBBAA hex codes
         rgb_fn = false, -- CSS rgb() and rgba() functions
         hsl_fn = false, -- CSS hsl() and hsla() functions
         css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
         css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn

         -- Available modes: foreground, background
         mode = "background", -- Set the display mode.
      },
   }

   options = nvchad.load_override(options, "NvChad/nvim-colorizer.lua")

   colorizer.setup(options["filetypes"], options["user_default_options"])
   vim.cmd "ColorizerReloadAllBuffers"
end

M.comment = function()
   local present, nvim_comment = pcall(require, "Comment")

   if not present then
      return
   end

   nvim_comment.setup()
end

M.luasnip = function()
   local present, luasnip = pcall(require, "luasnip")

   if not present then
      return
   end

   luasnip.config.set_config {
      history = true,
      updateevents = "TextChanged,TextChangedI",
   }

   require("luasnip.loaders.from_vscode").lazy_load()
end

M.signature = function()
   local present, lsp_signature = pcall(require, "lsp_signature")

   if not present then
      return
   end

   local options = {
      bind = true,
      doc_lines = 0,
      floating_window = true,
      fix_pos = true,
      hint_enable = true,
      hint_prefix = " ",
      hint_scheme = "String",
      hi_parameter = "Search",
      max_height = 22,
      max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
      handler_opts = {
         border = "single", -- double, single, shadow, none
      },
      zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
      padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
   }

   options = nvchad.load_override(options, "ray-x/lsp_signature.nvim")
   lsp_signature.setup(options)
end

M.lsp_handlers = function()
   local function lspSymbol(name, icon)
      local hl = "DiagnosticSign" .. name
      vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
   end

   lspSymbol("Error", "")
   lspSymbol("Info", "")
   lspSymbol("Hint", "")
   lspSymbol("Warn", "")

   vim.diagnostic.config {
      virtual_text = {
         prefix = "",
      },
      signs = true,
      underline = true,
      update_in_insert = false,
   }

   vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "single",
   })
   vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "single",
   })

   -- suppress error messages from lang servers
   vim.notify = function(msg, log_level)
      if msg:match "exit code" then
         return
      end
      if log_level == vim.log.levels.ERROR then
         vim.api.nvim_err_writeln(msg)
      else
         vim.api.nvim_echo({ { msg } }, true, {})
      end
   end
end

M.gitsigns = function()
   local present, gitsigns = pcall(require, "gitsigns")

   if not present then
      return
   end

   gitsigns.setup {
      signs = {
         add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
         change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
         delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
         topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
         changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
      },
      on_attach = function(bufnr)
         local gs = package.loaded.gitsigns
     
         local function map(mode, l, r, opts)
           opts = opts or {}
           opts.buffer = bufnr
           vim.keymap.set(mode, l, r, opts)
         end
     
         -- Navigation
         map('n', ']d', function()
           if vim.wo.diff then return ']d' end
           vim.schedule(function() gs.next_hunk() end)
           return '<Ignore>'
         end, {expr=true})
     
         map('n', '[d', function()
           if vim.wo.diff then return '[d' end
           vim.schedule(function() gs.prev_hunk() end)
           return '<Ignore>'
         end, {expr=true})
     
         -- Actions
         map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
         map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
         map('n', '<leader>hS', gs.stage_buffer)
         map('n', '<leader>hu', gs.undo_stage_hunk)
         map('n', '<leader>hR', gs.reset_buffer)
         map('n', '<leader>hp', gs.preview_hunk)
         map('n', '<leader>hb', function() gs.blame_line{full=true} end)
         map('n', '<leader>tb', gs.toggle_current_line_blame)
         map('n', '<leader>hd', gs.diffthis)
         map('n', '<leader>hD', function() gs.diffthis('~') end)
         map('n', '<leader>td', gs.toggle_deleted)
     
         -- Text object
         map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end
   }
end

return M
