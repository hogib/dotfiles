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
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'LaTeX buffer settings',
      group = vim.api.nvim_create_augroup('custom-latex', { clear = true }),
      pattern = { 'tex', 'plaintex', 'bib' },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true -- wrap at word boundaries
        vim.opt_local.spell = true
        vim.opt_local.spelllang = 'en_us'
        vim.opt_local.conceallevel = 2
      end,
    })
  end,
}
