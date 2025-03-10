{
  description = "A flake for fully-featured Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachSystem [
      flake-utils.lib.system.x86_64-linux
      flake-utils.lib.system.x86_64-darwin
    ] (system:
      let

        pkgs = import nixpkgs {
          inherit system;
          config = {};
        };

        nvim = pkgs.neovim.override {
          configure = {
            customRC = import ./config { inherit pkgs; };
            packages.myVimPackage = with pkgs.vimPlugins; {
              start = [
                # Misc plugins 
	        vim-nix           # File type and system highlighting.
                vim-fugitive      # Git integration.
                ansible-vim       # Ansible syntax support.
                chadtree          # File explorer.
                telescope-nvim    # Fuzzy finder.
                telescope-file-browser-nvim  # File browser for Telescope.
                nvim-web-devicons # File type icons.
                avante-nvim       # AI-based suggestions.
                img-clip-nvim     # Image clipboard support.
                lualine-nvim      # Minimal status line
		nvim-lspconfig    # LSP configuration.

                # Linting and formatting
                none-ls-nvim

                # Auto-completion
		cmp-nvim-lsp    
		cmp-buffer
		cmp-path
		cmp-cmdline
		nvim-cmp         
                cmp-vsnip
                vim-vsnip

                # Tree-sitter
                nvim-treesitter   
                nvim-treesitter-parsers.query   
                nvim-treesitter-parsers.javascript   
                nvim-treesitter-parsers.typescript   
                nvim-treesitter-parsers.comment   
                nvim-treesitter-parsers.css   
                nvim-treesitter-parsers.html   
                nvim-treesitter-parsers.vue   

                # color schemes
                gruvbox  
                gruvbox-baby
                sonokai
              ];
              opt = [ ];
            };
          };
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            nvim
            pkgs.ripgrep
            pkgs.nodejs
            pkgs.nil                                 # LSP for Nix
            pkgs.nodePackages.typescript             # TypeScript compiler.
            pkgs.nodePackages.typescript-language-server  # LSP for TypeScript.
            pkgs.vue-language-server                  # Volar (Vue language server) for Vue/TS support.
            # Linters and formatters
            pkgs.nodePackages.eslint                 # JavaScript/TypeScript linter
            pkgs.nodePackages.prettier               # Code formatter
          ];
          shellHook = ''
            export PIPPO="v1.83"
            alias vi="nvim"
          '';
        };

        apps.nvim = {
          type = "app";
          program = "${nvim}/bin/nvim";
        };
      }
    );
}
