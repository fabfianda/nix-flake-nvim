# config/default.nix
{ pkgs }:
let rc = ''

set noswapfile
" --- Auto color scheme --- "
autocmd VimEnter * colorscheme gruvbox

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

-- Avante 
require('avante').setup({
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

local lspconfig = require("lspconfig")

-- Volar (Vue3)
lspconfig.volar.setup {  
    init_options = {
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
