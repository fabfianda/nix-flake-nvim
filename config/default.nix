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

lspconfig.volar.setup {  
    -- add filetypes for typescript, javascript and vue
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
       typescript = {
          -- replace with your global TypeScript library path
         tsdk = '${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib'
    }
   },
  }                                   
-- you must remove ts_ls setup

lspconfig.nil_ls.setup {}

EOF

'';
in rc
