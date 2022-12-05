lvim.format_on_save = false
lvim.lsp.diagnostics.virtual_text = false
lvim.builtin.terminal.active = true
lvim.builtin.which_key.active = true

-- Set powershell as a shell
-- Enable powershell as your default shell
vim.opt.shell = "/opt/microsoft/powershell/7/pwsh -NoLogo"
vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
		let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		set shellquote= shellxquote=

    augroup powershell
        autocmd!
        autocmd FileType ps1 setlocal errorformat=%EAt\ line:%l\ char:%c,
            \%-C+%.%#,
            \%Z%m,
            \%-G\\s%#
        if has('win32')
            autocmd FileType ps1 set makeprg=pwsh\ -command\ \"&{
                \trap{$_.tostring();continue}&{
                \$c=gc\ '%';$c=[string]::join([environment]::newline,$c);
                \[void]$executioncontext.invokecommand.newscriptblock($c)
                \}
            \}\"
        else
            autocmd FileType ps1 set makeprg=pwsh\ -command\ \"&{
                \trap{\\$_.tostring\();continue}&{
                \\\$c=gc\ '%';\\$c=[string]::join([environment]::newline,\\$c);
                \[void]\\$executioncontext.invokecommand.newscriptblock(\\$c)
                \}
            \}\"
        endif
    augroup END
  ]]

-- Syntax highlightin
-- https://www.lunarvim.org/docs/languages/powershell#install-syntax-highlighting
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.powershell = {
  install_info = {
    url = "https://github.com/jrsconfitto/tree-sitter-powershell",
    files = {"src/parser.c"}
  },
  filetype = "ps1",
  used_by = { "psm1", "psd1", "pssc", "psxml", "cdxml" }
}

-- pwershell_es
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#powershell_es
require'lspconfig'.powershell_es.setup{
  bundle_path = '/opt/microsoft/PowerShellEditorServices/PowerShellEditorServices/',
  shell = 'pwsh'
}

-- All the treesitter parsers you want to install. If you want all of them, just
lvim.builtin.treesitter.ensure_installed = {
-- replace everything with "all".
}

-- -- Set a formatter.
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "black", filetypes = { "python" } },
-- }

-- -- Set a linter.
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
-- }

-- TODO: debugpy installed by default
-- Setup dap for python
lvim.builtin.dap.active = true
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
pcall(function() require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python") end)

-- Supported test frameworks are unittest, pytest and django. By default it
-- tries to detect the runner by probing for pytest.ini and manage.py, if
-- neither are present it defaults to unittest.
pcall(function() require("dap-python").test_runner = "pytest" end)

-- Magma Setup

-- Image options. Other options:
-- 1. none:     Don't show images.
-- 2. ueberzug: use Ueberzug to display images.
-- 3. kitty:    use the Kitty protocol to display images.
vim.g.magma_image_provider = "kitty"

-- If this is set to true, then whenever you have an active cell its output
-- window will be automatically shown.
vim.g.magma_automatically_open_output = true

-- If this is true, then text output in the output window will be wrapped.
vim.g.magma_wrap_output = false

-- If this is true, then the output window will have rounded borders.
vim.g.magma_output_window_borders = false

-- The highlight group to be used for highlighting cells.
vim.g.magma_cell_highlight_group = "CursorLine"

-- Where to save/load with :MagmaSave and :MagmaLoad.
-- The generated file is placed in this directory, with the filename itself
-- being the buffer's name, with % replaced by %% and / replaced by %, and
-- postfixed with the extension .json.
vim.g.magma_save_path = vim.fn.stdpath "data" .. "/magma"

-- dap-powershell
local dap = require('dap')
dap.adapters.ps1 = {
    type = 'executable';
    name = 'powershell-debug';
    command = "/usr/local/bin/start-dap-powershell.sh"
}

dap.configurations.ps1 = {
  {
    type = 'ps1';
    request = 'launch';
    name = "Launch powershell file";
    program = "${file}";
    powershellPath = function()
      return '/bin/pwsh'
    end;
  }
}

dap.configurations.powershell_es = {
  {
    type = 'generic_remote',
    name = 'Generic remote',
    request = 'attach',
    pathMappings = {{
      -- Update this as needed
      localRoot = vim.fn.getcwd();
      remoteRoot = "/";
    }}
  };
}

-- Mappings
lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('dap-python').test_method()<cr>", "Test Method" }
lvim.builtin.which_key.mappings["df"] = { "<cmd>lua require('dap-python').test_class()<cr>", "Test Class" }
lvim.builtin.which_key.vmappings["d"] = {
  name = "Debug",
  s = { "<cmd>lua require('dap-python').debug_selection()<cr>", "Debug Selection" },
}

lvim.builtin.which_key.mappings["j"] = {
  name = "Jupyter",
  i = { "<Cmd>MagmaInit<CR>", "Init Magma" },
  d = { "<Cmd>MagmaDeinit<CR>", "Deinit Magma" },
  e = { "<Cmd>MagmaEvaluateLine<CR>", "Evaluate Line" },
  r = { "<Cmd>MagmaReevaluateCell<CR>", "Re evaluate cell" },
  D = { "<Cmd>MagmaDelete<CR>", "Delete cell" },
  s = { "<Cmd>MagmaShowOutput<CR>", "Show Output" },
  R = { "<Cmd>MagmaRestart!<CR>", "Restart Magma" },
  S = { "<Cmd>MagmaSave<CR>", "Save" },
}

lvim.builtin.which_key.vmappings["j"] = {
  name = "Jupyter",
  e = { "<esc><cmd>MagmaEvaluateVisual<cr>", "Evaluate Highlighted Line" },
}

lvim.builtin.which_key.mappings["P"] = {
  name = "Python",
  i = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Pick Env" },
  d = { "<cmd>lua require('swenv.api').get_current_venv()<cr>", "Show Env" },
}

-- Additional Plugins
lvim.plugins = {
  -- You can switch between vritual environmnts.
  "Pocco81/DAPInstall.nvim",
  "pprovost/vim-ps1",
  "JayDoubleu/vim-pwsh-formatter",
  "AckslD/swenv.nvim",
  "mfussenegger/nvim-dap-python",
  {
    -- You can generate docstrings automatically.
    "danymat/neogen",
    config = function()
      require("neogen").setup {
        enabled = true,
        languages = {
          python = {
            template = {
              annotation_convention = "numpydoc",
            },
          },
        },
      }
    end,
  },
  -- You can run blocks of code like jupyter notebook.
  { "dccsillag/magma-nvim", run = ":UpdateRemotePlugins" },
}

