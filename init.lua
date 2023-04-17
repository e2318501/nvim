--
-- All configuration for Neovim
--

local setup = {}
local util = {}

function setup.main()
  setup.general()
  setup.lsp_ui()
  setup.commands()
  setup.plugins()
end

function setup.general()
  vim.api.nvim_set_option("title", true)
  vim.api.nvim_set_option("pumheight", 10)
  vim.api.nvim_set_option("pumblend", 10)
  vim.api.nvim_set_option("tabstop", 4)
  vim.api.nvim_set_option("softtabstop", 4)
  vim.api.nvim_set_option("shiftwidth", 4)
  vim.api.nvim_set_option("expandtab", true)
  vim.api.nvim_set_option("omnifunc", "syntaxcomplete#Complete")
  vim.api.nvim_set_option("selection", "old")
  vim.api.nvim_set_option("cmdheight", 0)
  vim.api.nvim_set_option("laststatus", 0)
  vim.api.nvim_set_option("splitbelow", true)
  vim.api.nvim_set_option("termguicolors", true)
  vim.api.nvim_set_option("showcmd", false)
  vim.api.nvim_set_option("ignorecase", true)
  vim.api.nvim_set_option("smartcase", true)
  vim.api.nvim_set_option("completeopt", "menu,menuone")
  vim.api.nvim_win_set_option(0, "number", false)
  vim.api.nvim_win_set_option(0, "cursorline", true)
  vim.api.nvim_win_set_option(0, "signcolumn", "no")
  vim.api.nvim_win_set_option(0, "winblend", 10)

  setup.formatoptions()
  setup.terminal()
  setup.shell()
  setup.indents()
end

function setup.formatoptions()
  vim.api.nvim_set_option("formatoptions", "cql")
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      vim.api.nvim_buf_set_option(0, "formatoptions", "cql")
    end,
  })
end

function setup.terminal()
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      vim.cmd("startinsert")
    end,
  })
end

function setup.shell()
  if util.is_windows() then
    local pwsh = "pwsh"
    local powershell = "powershell"
    if util.executable(pwsh) then
      vim.api.nvim_set_option("shell", pwsh)
    elseif util.executable(powershell) then
      vim.api.nvim_set_option("shell", powershell)
    end
  elseif util.is_linux() then
    local bash = "bash"
    if util.executable(bash) then
      vim.api.nvim_set_option("shell", bash)
    end
  end
end

function setup.indents()
  local indents = {
    {
      pattern = { "json", "yaml" },
      command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2",
    },
  }
  for _, i in pairs(indents) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = i.pattern,
      command = i.command,
    })
  end
end

function setup.lsp_ui()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.server_capabilities.hoverProvider then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
      end
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = args.buf })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = args.buf })
      vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = args.buf })
      vim.keymap.set("n", "gc", vim.lsp.buf.code_action, { buffer = args.buf })
      vim.keymap.set("n", "gl", vim.lsp.buf.document_symbol, { buffer = args.buf })
      vim.api.nvim_buf_create_user_command(
        args.buf,
        "Rename",
        function(opts)
          vim.lsp.buf.rename(opts.args)
        end,
        { nargs = 1 }
      )
      vim.api.nvim_buf_set_option(args.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end,
  })
end

function setup.commands()
  vim.api.nvim_create_user_command("T", "split | wincmd j | resize 15 | terminal <args>", { nargs = "*" })
  vim.api.nvim_create_user_command("Editrc", "edit $MYVIMRC", { nargs = 0 })
end

function setup.plugins()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.api.nvim_set_option("rtp", lazypath .. "," .. vim.api.nvim_get_option("rtp"))

  local plugins = {
    {
      "udalov/kotlin-vim",
      ft = "kotlin",
    },
    {
      "MTDL9/vim-log-highlighting",
      ft = "log",
    },

    {
      "lambdalisue/fern.vim",
      event = "UIEnter",
      config = setup.plugin_fern,
    },
    {
      "lambdalisue/fern-git-status.vim",
      event = "UIEnter",
    },
    {
      "sainnhe/everforest",
      event = "UIEnter",
      config = setup.plugin_everforest,
    },
    {
      "jiangmiao/auto-pairs",
      event = "UIEnter",
      config = setup.plugin_auto_pairs,
    },
    {
      "mfussenegger/nvim-jdtls",
      event = "UIEnter",
      config = setup.plugin_nvim_jdtls,
    },
    {
      "tsuoihito/vim-bufferlist",
      event = "UIEnter",
      config = setup.plugin_vim_bufferlist,
    },
    {
      "neovim/nvim-lspconfig",
      event = "UIEnter",
    },
    {
      "williamboman/mason.nvim",
      event = "UIEnter",
      config = setup.plugin_mason,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      event = "UIEnter",
      config = setup.plugin_mason_lspconfig,
    },
    {
      "tpope/vim-fugitive",
      event = "UIEnter",
    },
    {
      "RRethy/vim-illuminate",
      event = "UIEnter",
    },
    {
      "rbtnn/vim-ambiwidth",
      event = "UIEnter",
    },
    {
      "mattn/vim-maketable",
      event = "UIEnter",
    },
    {
      "thinca/vim-partedit",
      event = "UIEnter",
    },
    {
      "AndrewRadev/bufferize.vim",
      event = "UIEnter",
    },
    {
      "nvim-lua/plenary.nvim",
      event = "UIEnter",
    },
    {
      "nvim-telescope/telescope.nvim",
      event = "UIEnter",
      config = setup.plugin_telescope,
    },
    {
      "stevearc/aerial.nvim",
      event = "UIEnter",
      config = setup.plugin_aerial,
    },
    {
      "mfussenegger/nvim-dap",
      event = "UIEnter",
    },
    {
      "monkoose/matchparen.nvim",
      event = "UIEnter",
      config = setup.plugin_matchparen,
    },

    {
      "andweeb/presence.nvim",
      lazy = true,
    },
  }

  local config = {
    ui = {
      icons = {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "editorconfig",
          "gzip",
          "man",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "nvim",
          "rplugin",
          "shada",
          "spellfile",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  }

  require("lazy").setup(plugins, config)
end

function setup.plugin_fern()
  vim.keymap.set("n", "<F2>", "<cmd>Fern . -drawer -toggle -stay<CR>", { silent = true })
  vim.api.nvim_set_var("fern#default_hidden", true)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "fern",
    callback = function()
      vim.keymap.set("n", "%", "<Plug>(fern-action-new-file)", { buffer = true })
      vim.keymap.set("n", "d", "<Plug>(fern-action-new-dir)", { buffer = true })
    end,
  })
end

function setup.plugin_nvim_jdtls()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = setup.jdtls,
  })

  -- for lazy loading
  util.reload_filetype()
end

function setup.jdtls()
  if util.is_windows() then
    setup._jdtls(os.getenv("LOCALAPPDATA") .. "\\eclipse.jdt.ls")
  end
end

function setup._jdtls(jdtls_home)
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = jdtls_home .. "\\data\\" .. project_name

  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx1G",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-jar", jdtls_home .. "\\plugins\\org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
      "-configuration", jdtls_home .. "\\config_win",
      "-data", workspace_dir
    },
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
    settings = {
      java = {},
    },
    init_options = {
      bundles = {},
    },
  }

  require("jdtls").start_or_attach(config)
end

function setup.plugin_auto_pairs()
  vim.api.nvim_set_var("AutoPairsCenterLine", false)

  -- for lazy loading
  vim.fn["AutoPairsTryInit"]()
end

function setup.plugin_everforest()
  vim.cmd("colorscheme everforest")
end

function setup.plugin_vim_bufferlist()
  vim.keymap.set("n", "<Space>", "<cmd>call BufferList()<CR>")
end

function setup.plugin_mason()
  require("mason").setup()
end

function setup.plugin_mason_lspconfig()
  local mason_lspconfig = require("mason-lspconfig")

  mason_lspconfig.setup()
  mason_lspconfig.setup_handlers({
    function(server_name)
      local ignored_servers = { "jdtls" }
      if not util.contains(ignored_servers, server_name) then
        require("lspconfig")[server_name].setup({})
      end
    end,
    ["lua_ls"] = setup.lua_ls,
  })

  -- for lazy loading
  util.reload_filetype()
end

function setup.lua_ls()
  require("lspconfig")["lua_ls"].setup({
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
      },
    },
  })
end

function setup.plugin_telescope()
  require("telescope").setup({
    defaults = {
      winblend = 10,
    },
  })

  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<leader>tf", builtin.find_files)
  vim.keymap.set("n", "<leader>tg", builtin.git_files)
  vim.keymap.set("n", "<leader>tb", builtin.buffers)
  vim.keymap.set("n", "<leader>th", builtin.help_tags)
  vim.keymap.set("n", "<leader>tq", builtin.quickfix)
end

function setup.plugin_aerial()
  require("aerial").setup()
  vim.keymap.set("n", "<F3>", "<cmd>AerialToggle!<CR>")
end

function setup.plugin_matchparen()
  require("matchparen").setup()
end

function util.contains(list, x)
  for _, v in pairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

function util.is_windows()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

function util.is_linux()
  return vim.loop.os_uname().sysname == "Linux"
end

function util.executable(name)
  return vim.fn.executable(name) == 1
end

function util.reload_filetype()
  vim.api.nvim_buf_set_option(0, "filetype", vim.api.nvim_buf_get_option(0, "filetype"))
end

setup.main()

-- vim: ts=2 sts=2 sw=2
