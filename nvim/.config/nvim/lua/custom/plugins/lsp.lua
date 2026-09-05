return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      require 'lspconfig'

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local ok_blink, blink = pcall(require, 'blink.cmp')
      if ok_blink then capabilities = blink.get_lsp_capabilities(capabilities) end

      -- Multithreading. available_parallelism() instead of forking `nproc`:
      -- no subprocess at startup, and it cannot return nil. The old version
      -- did `tonumber(vim.fn.system{'nproc'})` and then `if 0 ~= nproc`, which
      -- is TRUE when nproc is nil, so a failed call hit `nil - 1` and threw --
      -- aborting this whole config function, i.e. no LSP at all.
      local nproc = vim.uv.available_parallelism()
      local jnproc = '--j=' .. math.max(1, nproc - 1)

      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
            jnproc,
          },
          init_options = {},
        },
        gopls = {},
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard',
                diagnosticMode = 'openFilesOnly',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        bashls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
        mesonlsp = {},
        ts_ls = {},
        just = {},
      }

      require('mason-tool-installer').setup {
        -- Not on every startup. The default (run_on_start = true,
        -- start_delay = 0) checks all of these at the exact moment the first
        -- LSP is trying to attach, and the check needs mason's registry, which
        -- is refreshed from GitHub when stale -- so how long it takes depends
        -- on the network. Run `:MasonToolsUpdate` when you want it instead.
        run_on_start = false,
        ensure_installed = {
          'gopls',
          'just',
          'bash-language-server',
          'basedpyright',
          'lua-language-server',
          'typescript-language-server',
          'stylua',
          'black',
          'isort',
          'goimports',
          'shfmt',
          'clang-format',
          'prettierd',
          'prettier',
          'mesonlsp',
        },
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
        -- v2 defaults this to true, which calls vim.lsp.enable() on EVERY
        -- server mason has installed -- not just the ones configured above.
        -- That was starting jedi_language_server alongside basedpyright on
        -- every Python buffer, and stylua alongside lua_ls on every Lua one.
        -- The loop below already enables exactly what `servers` lists.
        automatic_enable = false,
      }

      for name, config in pairs(servers) do
        config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})

        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == 'c' or ft == 'cpp' then return nil end

        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black', stop_after_first = true },
        go = { 'gofmt', 'goimports', stop_after_first = true },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        meson = { 'meson_format' },
        markdown = { 'prettier' },
        markdown_inline = { 'prettier' },
      },
      formatters = {
        ['clang-format'] = {
          prepend_args = { '--style=file', '--fallback-style=LLVM' },
        },
        ['meson_format'] = {
          command = 'meson',
          args = { 'format', '-' },
          stdin = true,
        },
      },
    },
  },

  {
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
      },
    },
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        ghost_text = {
          enabled = true,
        },
        trigger = {
          show_in_snippet = false,
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      snippets = {
        preset = 'luasnip',
      },
      signature = {
        enabled = true,
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
  },
}
