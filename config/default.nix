# config/default.nix
{ pkgs }:
let rc = ''

set noswapfile
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

-- Tree-sitter
require("nvim-treesitter.configs").setup({
  -- List of parsers
  ensure_installed = {
      "vue",
      "javascript"
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

-- LSP config
local lspconfig = require("lspconfig")


-- Volar (Vue3)
lspconfig.volar.setup {  
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

-- TypeScript
lspconfig.ts_ls.setup {
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          location = '${pkgs.vue-language-server}/lib/node_modules/@vue/language-server',
          languages = { 'vue' },
        },
      },
    },
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

-- Nil 
lspconfig.nil_ls.setup {
}

EOF

'';
in rc
