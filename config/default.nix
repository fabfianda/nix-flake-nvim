# config/default.nix
{ pkgs }:
let rc = ''

" --- Defaults --- "
set noswapfile
set number
set relativenumber
set termguicolors

" --- Auto color scheme --- "
autocmd VimEnter * colorscheme sonokai

" --- Mappings --- "
let mapleader = "<SPACE>"

nnoremap <SPACE><SPACE><SPACE> :noh <CR>
nnoremap <SPACE>t <cmd>CHADopen<cr>
nnoremap <SPACE>l <cmd>Telescope live_grep<cr>
nnoremap <SPACE>f <cmd>Telescope find_files<cr>
nnoremap <SPACE>b <cmd>Telescope buffers<cr>

" --- Copy to clipboard --- "
vnoremap y  "+y
nnoremap Y  "+yg_
nnoremap y  "+y
nnoremap yy "+yy

" --- Paste from clipboard --- "
nnoremap <leader>p  "+p
nnoremap <leader>P  "+P

" --- LUA based config  --- "
lua << EOF

-- ------------------- --
-- Lualine
require("lualine").setup()

-- ------------------- --
-- Tree-sitter
require("nvim-treesitter.configs").setup({
  -- List of parsers
  ensure_installed = {
      "query",
      "javascript",
      "typescript",
      "comment",
      "html",
      "css",
      "vue",
  },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  
  -- Automatically install missing parsers when entering buffer
  auto_install = false,
  
  -- List of parsers to ignore installing (for "all")
  ignore_install = {},
  
  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  parser_install_dir = "/tmp",
  
  highlight = {
  	-- `false` will disable the whole extension
  	enable = true,
  
  	-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
  	-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
  	-- the name of the parser)
  	-- list of language that will be disabled
  	disable = {},
  
  	-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
  	-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
  	-- Using this option may slow down your editor, and you may see some duplicate highlights.
  	-- Instead of true it can also be a list of languages
  	additional_vim_regex_highlighting = true,
  },
  indent = {
	enable = true,
  },

})

-- ------------------- --
-- Avante 
local avante = require("avante")
avante.setup({
  provider = "openai",  -- or your chosen AI provider
  openai = {
    endpoint = "https://api.openai.com/v1",
    model = "gpt-4",   -- Change based on your usage
    timeout = 30000,   -- Timeout in milliseconds
    temperature = 0.7, -- Adjust as needed
    max_tokens = 2048  -- Adjust based on API limits
  },
  behaviour = {
    enable_suggestions = true,
    enable_inline_suggestions = true
  }
})

-- ------------------- --
-- nvim-cmp
local cmp = require("cmp")

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },

  -- Key mapping configuration
  mapping = cmp.mapping.preset.insert({
    -- Scroll documentation up/down
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    
    -- Confirm selection
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Optional: Tab to confirm
    
    -- Navigate completion menu
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    
    -- Toggle completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
    
    -- Exit completion menu
    ['<C-e>'] = cmp.mapping.abort(),
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- ------------------- --
-- LSP config
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- ------------------- --
-- Volar (Vue3)
lspconfig.volar.setup {  
    capabilities = capabilities,
    init_options = {
       typescript = {
          -- replace with your global TypeScript library path
         tsdk = '${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib'
       },
       vue = {
         hybridMode = false,
       }
   },
   settings = {
      typescript = {
        inlayHints = {
          enumMemberValues = {
            enabled = true,
          },
          functionLikeReturnTypes = {
            enabled = true,
          },
          propertyDeclarationTypes = {
            enabled = true,
          },
          parameterTypes = {
            enabled = true,
            suppressWhenArgumentMatchesName = true,
          },
          variableTypes = {
            enabled = true,
          },
        },
      },
   },
}                                   

-- ------------------- --
-- TypeScript
lspconfig.ts_ls.setup {
    capabilities = capabilities,
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          location = '${pkgs.vue-language-server}/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin',
          languages = { 'javascript', 'typescript', 'vue' },
        },
      },
    },
    filetypes = { 'javascript', 'typescript', 'vue' },
    settings = {
      typescript = {
        tsserver = {
          useSyntaxServer = false,
        },
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
}

-- ------------------- --
-- Nil 
lspconfig.nil_ls.setup {
    capabilities = capabilities,
}

-- ------------------- --
-- None-ls 
local none_ls = require("null-ls")

-- Import the sources module
local formatting = none_ls.builtins.formatting
local diagnostics = none_ls.builtins.diagnostics
local code_actions = none_ls.builtins.code_actions

none_ls.setup({
  debug = false,
  sources = {
    -- Formatting
    formatting.prettier.with({
      extra_filetypes = { "toml", "json" },
      extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
    }),
    
    -- Diagnostics
    diagnostics.eslint,
    diagnostics.shellcheck,
    diagnostics.markdownlint,
    
    -- Code Actions
    code_actions.eslint,
    code_actions.shellcheck,
  },
})

-- ------------------- --
-- Keymaps for linting and formatting

function formatAndBlockCursor ()
  local curpos = vim.api.nvim_win_get_cursor(0)  -- Save cursor position
  vim.lsp.buf.format()                           -- Format buffer
  vim.api.nvim_win_set_cursor(0, curpos)         -- Restore cursor position
end  

vim.keymap.set("n", "<SPACE><SPACE>", formatAndBlockCursor, { noremap = true, silent = true })


EOF

'';
in rc
