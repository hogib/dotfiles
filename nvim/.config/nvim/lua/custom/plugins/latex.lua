-- LaTeX
--   vimtex -> compiling (latexmk), PDF viewer with SyncTeX, motions/text objects
--             (<localleader>ll compile, <localleader>lv view, <localleader>le errors)
--   texlab -> LSP: completion, references, rename, hover (see lsp.lua)
--   chktex -> linting (see lint.lua), tex-fmt -> formatting (see lsp.lua)

---@module 'lazy'
---@type LazySpec
return {
  'lervag/vimtex',
  lazy = false, -- VimTeX must not be lazy loaded
  init = function()
    -- The 'zathura' method needs xdotool to reuse the viewer window, which
    -- only works on X11; 'zathura_simple' works on Wayland too.
    vim.g.vimtex_view_method = vim.fn.executable 'xdotool' == 1 and 'zathura' or 'zathura_simple'

    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = 'build',
      options = { '-verbose', '-file-line-error', '-synctex=1', '-interaction=nonstopmode' },
    }

    -- Don't steal focus with the quickfix window on every compile;
    -- <localleader>le opens it when you want it.
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_quickfix_ignore_filters = { 'Underfull', 'Overfull' }

    -- texlab handles completion and these are better done by texlab/conform
    vim.g.vimtex_complete_enabled = 0
    vim.g.vimtex_format_enabled = 0
  end,
  config = function()
    local autosave = vim.api.nvim_create_augroup('custom-latex-autosave', { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'LaTeX buffer settings',
      group = vim.api.nvim_create_augroup('custom-latex', { clear = true }),
      pattern = { 'tex', 'plaintex', 'bib' },
      callback = function(event)
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true -- wrap at word boundaries
        vim.opt_local.spell = true
        -- en_gb to match ltex_plus (lsp.lua); tr.utf-8.spl lives in ~/.local/share/nvim/site/spell
        vim.opt_local.spelllang = 'en_gb,tr'
        vim.opt_local.conceallevel = 2

        -- Save on leaving insert mode, so latexmk's continuous mode
        -- (<localleader>ll) recompiles and zathura reloads, Overleaf-style.
        -- noautocmd skips conform's format-on-save, so tex-fmt doesn't rewrap
        -- lines on every <Esc>; a manual :w still formats.
        -- Cleared first so a re-fired FileType doesn't stack duplicates.
        vim.api.nvim_clear_autocmds { group = autosave, buffer = event.buf }
        vim.api.nvim_create_autocmd('InsertLeave', {
          desc = 'Save LaTeX buffer to trigger a rebuild',
          group = autosave,
          buffer = event.buf,
          callback = function()
            if vim.bo[event.buf].buftype == '' and vim.api.nvim_buf_get_name(event.buf) ~= '' then
              vim.cmd 'silent! noautocmd update'
            end
          end,
        })
      end,
    })
  end,
}
