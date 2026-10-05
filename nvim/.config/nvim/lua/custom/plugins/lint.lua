-- Linting
--
-- Only standalone linters live here. Languages whose LSP already lints are
-- left out to avoid duplicate diagnostics:
--   rust    -> clippy via rust-analyzer (see rust.lua)
--   sh/bash -> shellcheck via bashls (picked up automatically when installed)
--   c/cpp   -> clang-tidy via clangd (cppcheck below adds its own checks)

---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePost' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      c = { 'cppcheck' },
      cpp = { 'cppcheck' },
      python = { 'ruff' },
      go = { 'golangcilint' },
      zsh = { 'zsh' },
      tex = { 'chktex' },
      markdown = { 'markdownlint' },
      ruby = { 'ruby', 'rubocop' },
    }

    local function get_linter(name)
      local linter = lint.linters[name]
      return type(linter) == 'function' and linter() or linter
    end

    -- Full arg list instead of appending to the default one: the default
    -- contains a function returning nil (no ./build dir), and the resulting
    -- hole makes the arg list length unreliable, so --template gets dropped.
    lint.linters.cppcheck.args = {
      '--enable=warning,style,performance,information',
      function() return vim.bo.filetype == 'cpp' and '--language=c++' or '--language=c' end,
      '--inline-suppr',
      '--quiet',
      -- "information" level noise
      '--suppress=missingIncludeSystem',
      '--suppress=unmatchedSuppression',
      '--suppress=checkersReport',
      '--template={file}:{line}:{column}: [{id}] {severity}: {message}',
    }

    -- The default passes /dev/stdin, which zsh can't open when stdin is a
    -- socket (as libuv sets it up). Lint the file on disk instead.
    lint.linters.zsh = vim.tbl_extend('force', get_linter 'zsh', {
      stdin = false,
      args = { '--no-exec', '--no-rcs', '--no-globalrcs' },
    })

    -- Lint the current buffer. Linters whose binary is missing are skipped
    -- instead of erroring on every buffer. Linters that read the file from
    -- disk (stdin = false: cppcheck, golangci-lint) only run when the buffer
    -- matches the disk, otherwise they'd report on stale content.
    local function try_lint(event)
      if not vim.bo.modifiable then return end
      local on_disk = event.event ~= 'InsertLeave' and not vim.bo.modified

      local names = vim.tbl_filter(function(name)
        local linter = get_linter(name)
        local cmd = type(linter.cmd) == 'function' and linter.cmd() or linter.cmd
        return vim.fn.executable(cmd) == 1 and (linter.stdin or on_disk)
      end, lint.linters_by_ft[vim.bo.filetype] or {})

      if #names > 0 then lint.try_lint(names) end
    end

    -- FileType rather than BufReadPost: the filetype isn't known yet on BufReadPost
    vim.api.nvim_create_autocmd({ 'FileType', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      callback = try_lint,
    })
  end,
}
