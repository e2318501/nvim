---All of my Neovim configuration
---@author Nutchi <nutchi.net>


---A scope for local functions, like `s:` in Vim Script.
---I want to order functions by abstraction level, so forward-definition is needed.
local s = {}

---Data container for my own functions.
local vimrc_data = {}

---Setup all of the configuration.
---It is called after all declarations of other functions.
function s.main()
  s.setup_general()
  s.setup_lsp_ui()
  s.setup_utils()
  s.setup_plugins()
  s.setup_colorscheme()
end

---Configure general options.
function s.setup_general()
  vim.api.nvim_set_option("title", true)
  vim.api.nvim_set_option("pumheight", math.ceil(vim.api.nvim_get_option("lines") * 0.25))
  vim.api.nvim_set_option("pumblend", 10)
  vim.api.nvim_set_option("tabstop", 4)
  vim.api.nvim_set_option("softtabstop", 4)
  vim.api.nvim_set_option("shiftwidth", 4)
  vim.api.nvim_set_option("expandtab", true)
  vim.api.nvim_set_option("omnifunc", "syntaxcomplete#Complete")
  vim.api.nvim_set_option("selection", "old")
  vim.api.nvim_set_option("cmdheight", 1)
  vim.api.nvim_set_option("laststatus", 0)
  vim.api.nvim_set_option("ruler", false)
  vim.api.nvim_set_option("splitbelow", true)
  vim.api.nvim_set_option("termguicolors", true)
  vim.api.nvim_set_option("showcmd", false)
  vim.api.nvim_set_option("ignorecase", true)
  vim.api.nvim_set_option("smartcase", true)
  vim.api.nvim_set_option("completeopt", "menu,menuone")
  vim.api.nvim_set_option("diffopt", "internal,filler,closeoff,vertical,algorithm:histogram,indent-heuristic")
  vim.api.nvim_win_set_option(0, "number", true)
  vim.api.nvim_win_set_option(0, "cursorline", true)
  vim.api.nvim_win_set_option(0, "signcolumn", "yes:2")
  vim.api.nvim_win_set_option(0, "winblend", 0)

  s.setup_formatoptions()
  s.setup_terminal()
  s.setup_shell()
  s.setup_indent()
end

---Overwrite `'formatoptions'` on all filetype.
function s.setup_formatoptions()
  vim.api.nvim_set_option("formatoptions", "cql")
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      vim.api.nvim_buf_set_option(0, "formatoptions", "cql")
    end,
  })
end

---Configure terminal-mode settings.
function s.setup_terminal()
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      vim.api.nvim_win_set_option(0, "number", false)
      vim.cmd("startinsert")
    end,
  })
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
  vim.keymap.set("t", "<C-[>", "<C-\\><C-n>")
end

---Configure my favorite shell.
function s.setup_shell()
  if s.on_windows() then
    local pwsh = "pwsh"
    local powershell = "powershell"
    if s.executable(pwsh) then
      vim.api.nvim_set_option("shell", pwsh)
    elseif s.executable(powershell) then
      vim.api.nvim_set_option("shell", powershell)
    end
  elseif s.on_linux() then
    local bash = "bash"
    if s.executable(bash) then
      vim.api.nvim_set_option("shell", bash)
    end
  end
end

---Configure indent.
function s.setup_indent()
  local indents = {
    {
      ft = { "json", "yaml", "c", "sshconfig" },
      size = 2,
    },
  }

  for _, i in pairs(indents) do
    for _, ft in pairs(i.ft) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ft,
        callback = function()
          vim.api.nvim_buf_set_option(0, "tabstop", i.size)
          vim.api.nvim_buf_set_option(0, "softtabstop", i.size)
          vim.api.nvim_buf_set_option(0, "shiftwidth", i.size)
        end,
      })
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    command = "setlocal indentkeys-=0#",
  })
end

---Configure keymappings and commands for LSP.
function s.setup_lsp_ui()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.server_capabilities.hoverProvider then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
      end
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = args.buf })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = args.buf })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = args.buf })
      vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = args.buf })
      vim.keymap.set("n", "gc", vim.lsp.buf.code_action, { buffer = args.buf })
      vim.keymap.set("n", "gl", vim.diagnostic.setqflist, { buffer = args.buf })
      vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = args.buf })
      vim.keymap.set("n", "<C-k>", vim.diagnostic.open_float, { buffer = args.buf })

      vim.api.nvim_buf_set_option(args.buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end,
  })

  vim.diagnostic.config({
    virtual_text = {
      prefix = "*",
    },
    signs = false,
  })
end

---Define shortcuts and my own functions.
function s.setup_utils()
  vim.api.nvim_create_user_command("VimRC", "edit $MYVIMRC", { nargs = 0 })
  vim.api.nvim_create_user_command("LightMode", "set background=light", { nargs = 0 })
  vim.api.nvim_create_user_command("DarkMode", "set background=dark", { nargs = 0 })
  vim.api.nvim_create_user_command("CdHere", "cd %:h", { nargs = 0 })
  vim.keymap.set("n", "<F4>", s.open_floating_terminal)
end

---Load plugins.
function s.setup_plugins()
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
      config = s.setup_fern,
    },
    {
      "lambdalisue/fern-git-status.vim",
      event = "UIEnter",
      config = s.setup_fern_git_status,
      dependencies = {
        "lambdalisue/fern.vim",
      },
    },
    {
      "sainnhe/everforest",
      event = "UIEnter",
      config = s.setup_everforest,
    },
    {
      "windwp/nvim-autopairs",
      event = "UIEnter",
      config = s.setup_nvim_autopairs,
    },
    {
      "mfussenegger/nvim-jdtls",
      event = "UIEnter",
      config = s.setup_nvim_jdtls,
    },
    {
      "nutchinet/vim-bufferlist",
      event = "UIEnter",
      config = s.setup_vim_bufferlist,
    },
    {
      "neovim/nvim-lspconfig",
      event = "UIEnter",
    },
    {
      "williamboman/mason.nvim",
      event = "UIEnter",
      config = true,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      event = "UIEnter",
      config = s.setup_mason_lspconfig,
    },
    {
      "jose-elias-alvarez/null-ls.nvim",
      event = "UIEnter",
      config = true,
    },
    {
      "jay-babu/mason-null-ls.nvim",
      event = "UIEnter",
      config = s.setup_mason_null_ls,
    },
    {
      "tpope/vim-fugitive",
      event = "UIEnter",
    },
    {
      "RRethy/vim-illuminate",
      event = "UIEnter",
      config = s.setup_illuminate,
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
      config = s.setup_telescope,
    },
    {
      "stevearc/aerial.nvim",
      event = "UIEnter",
      config = s.setup_aerial,
    },
    {
      "mfussenegger/nvim-dap",
      event = "UIEnter",
    },
    {
      "monkoose/matchparen.nvim",
      event = "UIEnter",
      config = true,
    },
    {
      "tsuoihito/badapple.nvim",
      event = "UIEnter",
    },
    {
      "andweeb/presence.nvim",
      lazy = true,
    },
    {
      "hrsh7th/nvim-cmp",
      event = "UIEnter",
      config = s.setup_nvim_cmp,
    },
    {
      "hrsh7th/cmp-nvim-lsp",
      event = "UIEnter",
    },
    {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      event = "UIEnter",
    },
    {
      "hrsh7th/vim-vsnip",
      event = "UIEnter",
    },
    {
      "hrsh7th/cmp-path",
      event = "UIEnter",
    },
    {
      "hrsh7th/cmp-emoji",
      event = "UIEnter",
    },
    {
      "machakann/vim-sandwich",
      event = "UIEnter",
    },
    {
      "monaqa/dial.nvim",
      event = "UIEnter",
      config = s.setup_dial_nvim,
    },
    {
      "gbprod/substitute.nvim",
      event = "UIEnter",
      config = s.setup_substitute_nvim,
    },
    {
      "iamcco/markdown-preview.nvim",
      event = "UIEnter",
    },
    -- The view of scroll bar is broken on Alacritty, Windows 10.
    -- {
    --   "petertriho/nvim-scrollbar",
    --   event = "UIEnter",
    --   config = s.setup_nvim_scrollbar,
    --   dependencies = {
    --     "sainnhe/everforest",
    --   },
    -- },
    {
      "lewis6991/gitsigns.nvim",
      event = "UIEnter",
      config = true,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      event = "UIEnter",
    },
    {
      "famiu/bufdelete.nvim",
      event = "UIEnter",
    },
  }

  local config = {
    install = {
      colorscheme = { "everforest", "habamax" },
    },
    ui = {
      border = "none",
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

function s.setup_fern()
  vim.keymap.set("n", "<F2>", "<cmd>Fern . -drawer -toggle -stay<CR>", { silent = true })
  vim.api.nvim_set_var("fern#default_hidden", true)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "fern",
    callback = function()
      vim.keymap.set("n", "%", "<Plug>(fern-action-new-file)", { buffer = true })
      vim.keymap.set("n", "d", "<Plug>(fern-action-new-dir)", { buffer = true })
      vim.api.nvim_win_set_option(0, "number", false)
    end,
  })
end

function s.setup_fern_git_status()
  vim.fn["fern_git_status#init"]()
end

function s.setup_nvim_autopairs()
  local autopairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")

  autopairs.setup({
    map_c_h = true,
    map_c_w = true,
  })

  -- Add spaces between parentheses
  local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
  autopairs.add_rules({
    Rule(" ", " ")
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({
            brackets[1][1] .. brackets[1][2],
            brackets[2][1] .. brackets[2][2],
            brackets[3][1] .. brackets[3][2],
          }, pair)
        end)
  })
  for _, bracket in pairs(brackets) do
    autopairs.add_rules({
      Rule(bracket[1] .. " ", " " .. bracket[2])
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match(".%" .. bracket[2]) ~= nil
          end)
          :use_key(bracket[2])
    })
  end
end

function s.setup_nvim_jdtls()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = s.start_jdtls,
  })

  vim.cmd("doautocmd FileType")
end

function s.start_jdtls()
  if s.on_windows() then
    s.start_jdtls_windows()
  elseif s.on_linux() then
    s.start_jdtls_linux()
  end
end

function s.start_jdtls_windows()
  local java = vim.fn.expand("$ProgramFiles/Eclipse Adoptium/jdk-17.0.7.7-hotspot/bin/java")
  local jar = vim.fn.expand("$LOCALAPPDATA/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_*.jar")
  local configuration = vim.fn.expand("$LOCALAPPDATA/eclipse.jdt.ls/config_win")
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local data = vim.fn.expand("$LOCALAPPDATA/eclipse.jdt.ls/data/" .. project_name)
  local runtimes = {
    {
      name = "JavaSE-1.8",
      path = vim.fn.expand("$ProgramFiles/Eclipse Adoptium/jdk-8.0.372.7-hotspot/"),
    },
    {
      name = "JavaSE-17",
      path = vim.fn.expand("$ProgramFiles/Eclipse Adoptium/jdk-17.0.7.7-hotspot/"),
    },
  }
  s.start_jdtls_common(java, jar, configuration, data, runtimes)
end

function s.start_jdtls_linux()
  local java = "/usr/lib/jvm/java-17-openjdk-amd64/bin/java"
  local jar = vim.fn.expand("$HOME/.local/share/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_*.jar")
  local configuration = vim.fn.expand("$HOME/.local/share/eclipse.jdt.ls/config_linux")
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local data = vim.fn.expand("$HOME/.local/share/eclipse.jdt.ls/data/" .. project_name)
  local runtimes = {
    {
      name = "JavaSE-1.8",
      path = "/usr/lib/jvm/java-8-openjdk-amd64/",
    },
    {
      name = "JavaSE-17",
      path = "/usr/lib/jvm/java-17-openjdk-amd64/",
    },
  }
  s.start_jdtls_common(java, jar, configuration, data, runtimes)
end

---@param java string
---@param jar string
---@param configuration string
---@param runtimes table
function s.start_jdtls_common(java, jar, configuration, data, runtimes)
  if (s.executable(java) and s.file_exists(jar) and s.file_exists(configuration)) then
    local config = {
      cmd = {
        java,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1G",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", jar,
        "-configuration", configuration,
        "-data", data,
      },
      root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" }),
      settings = {
        ["java.format.settings.url"] = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
        ["java.format.settings.profile"] = "GoogleStyle",
        java = {
          signatureHelp = { enabled = true },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          configuration = {
            runtimes = runtimes
          },
        },
      },
      init_options = {
        bundles = {},
      },
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    }

    require("jdtls").start_or_attach(config)
  end
end

function s.setup_everforest()
  vim.api.nvim_set_var("everforest_background", "hard")
  vim.api.nvim_set_var("everforest_disable_italic_comment", 1)
  vim.api.nvim_set_var("everforest_diagnostic_virtual_text", "colored")
end

function s.setup_vim_bufferlist()
  vim.keymap.set("n", "<Space>", "<cmd>call BufferList()<CR>")
end

function s.setup_mason_lspconfig()
  local mason_lspconfig = require("mason-lspconfig")

  mason_lspconfig.setup()
  mason_lspconfig.setup_handlers({
    function(server_name)
      local ignored_servers = { "jdtls" }
      if not s.contains(ignored_servers, server_name) then
        require("lspconfig")[server_name].setup({
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })
      end
    end,
    ["lua_ls"] = s.setup_lua_ls,
  })

  vim.cmd("doautocmd FileType")
end

function s.setup_lua_ls()
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

function s.setup_mason_null_ls()
  require("mason-null-ls").setup({
    automatic_setup = true,
    handlers = {},
  })
end

function s.setup_illuminate()
  require("illuminate").configure({
    providers = {
      "lsp",
      "treesitter",
    },
  })
end

function s.setup_telescope()
  require("telescope").setup({
    defaults = {
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      results_title = false,
      prompt_title = false,
    },
  })

  vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
end

function s.setup_aerial()
  require("aerial").setup()
  vim.keymap.set("n", "<F3>", "<cmd>AerialToggle!<CR>")
end

function s.setup_nvim_cmp()
  local cmp = require("cmp")
  cmp.setup({
    sources = {
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "path" },
    },
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-l>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<C-y>"] = cmp.mapping.confirm({ select = true }),
      ["<C-b>"] = cmp.mapping.scroll_docs(-1),
      ["<C-f>"] = cmp.mapping.scroll_docs(1),
    }),
    window = {
      documentation = {
        max_width = vim.api.nvim_get_option("columns") * 0.25,
        max_height = vim.api.nvim_get_option("lines") * 0.25,
      },
    },
    enabled = function()
      local context = require("cmp.config.context")
      if vim.api.nvim_get_mode().mode == "c" then
        return true
      else
        return not context.in_treesitter_capture("comment")
            and not context.in_syntax_group("Comment")
      end
    end,
  })

  cmp.setup.filetype("markdown", {
    sources = {
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "path" },
      { name = "emoji" },
    },
  })

  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  cmp.event:on(
    "confirm_done",
    cmp_autopairs.on_confirm_done()
  )
end

function s.setup_dial_nvim()
  local augend = require("dial.augend")
  require("dial.config").augends:register_group {
    default = {
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.date.alias["%Y/%m/%d"],
      augend.constant.alias.bool,
      augend.constant.new { elements = { "True", "False" } },
      augend.constant.new { elements = { "private", "public" } },
    },
    visual = {
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
    },
  }

  vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal())
  vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal())
  vim.keymap.set("n", "g<C-a>", require("dial.map").inc_gnormal())
  vim.keymap.set("n", "g<C-x>", require("dial.map").dec_gnormal())
  vim.keymap.set("v", "<C-a>", require("dial.map").inc_visual("visual"))
  vim.keymap.set("v", "<C-x>", require("dial.map").dec_visual("visual"))
  vim.keymap.set("v", "g<C-a>", require("dial.map").inc_gvisual("visual"))
  vim.keymap.set("v", "g<C-x>", require("dial.map").dec_gvisual("visual"))
end

function s.setup_substitute_nvim()
  require("substitute").setup({})
  vim.keymap.set("n", "s", require('substitute').operator)
  vim.keymap.set("n", "ss", require('substitute').line)
  vim.keymap.set("n", "S", require('substitute').eol)
  vim.keymap.set("x", "s", require('substitute').visual)
end

function s.setup_nvim_scrollbar()
  require("scrollbar").setup({
    throttle_ms = 10,
    marks = {
      Cursor = {
        text = "",
      },
      Error = {
        highlight = "DiagnosticSignError",
      },
      Warn = {
        highlight = "DiagnosticSignWarn",
      },
      Info = {
        highlight = "DiagnosticSignInfo",
      },
      Hint = {
        highlight = "DiagnosticSignHint",
      },
    },
  })
end

---Do `:colorscheme`.
function s.setup_colorscheme()
  vim.cmd("colorscheme everforest")
  vim.api.nvim_set_option("background", "dark")
end

---Open terminal in a floating window.
function s.open_floating_terminal()
  local term_bufnr = s.get_term_bufnr()

  if term_bufnr ~= nil then
    s.open_floating_window(term_bufnr)
    vim.cmd("startinsert")
  else
    local new_term_bufnr = vim.api.nvim_create_buf(false, false)

    if (new_term_bufnr ~= 0) then
      --- @type integer
      vimrc_data.float_term_bufnr = new_term_bufnr
      s.open_floating_window(new_term_bufnr)
      vim.cmd("terminal")
      vim.keymap.set("n", "<Esc>", "<cmd>quit<CR>", { buffer = new_term_bufnr })
      vim.keymap.set({ "n", "v", "x", "s", "o", "i", "t" }, "<F4>", "<cmd>quit<CR>", { buffer = new_term_bufnr })
    end
  end
end

---Return the buffer number of the floating terminal, or nil if no terminal exists.
---@return integer|nil
function s.get_term_bufnr()
  for _, buf in pairs(vim.fn.getbufinfo()) do
    if buf.bufnr == vimrc_data.float_term_bufnr then
      return buf.bufnr
    end
  end
  return nil
end

---Open a floating window.
---@param bufnr integer
---@return integer
function s.open_floating_window(bufnr)
  local columns = vim.api.nvim_get_option("columns")
  local lines = vim.api.nvim_get_option("lines")
  local width = math.ceil(columns * 0.7)
  local height = math.ceil(lines * 0.7)
  local config = {
    relative = "editor",
    width = width,
    height = height,
    col = (columns - width) * 0.5,
    row = (lines - height) * 0.5,
    anchor = "NW",
    style = "minimal",
    border = "none",
  }

  return vim.api.nvim_open_win(bufnr, true, config)
end

---Return true if the list contains the element, otherwise false.
---@param list table
---@param x any
---@return boolean
function s.contains(list, x)
  for _, v in pairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

---Return true if running on Windows system, otherwise false.
---@return boolean
function s.on_windows()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

---Return true if running on Linux system, otherwise false.
---@return boolean
function s.on_linux()
  return vim.loop.os_uname().sysname == "Linux"
end

---Work same as `executable()` in Vim Script.
---@return boolean
function s.executable(name)
  return vim.fn.executable(name) == 1
end

---Return true if file or directory exists, otherwise false.
---@param path string
---@return boolean
function s.file_exists(path)
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

s.main()

-- vim: ts=2 sts=2 sw=2
