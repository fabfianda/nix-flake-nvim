{
  description = "A flake for fully-featured Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {};
        };

        nvim = pkgs.neovim.override {
          configure = {
            customRC = builtins.readFile ./flake.vim-config.rc;
            packages.myVimPackage = with pkgs.vimPlugins; {
              start = [
	        vim-nix           # File type and system highlighting.
                vim-fugitive      # Git integration.
                gruvbox           # Color scheme.
                ansible-vim       # Ansible syntax support.
                chadtree          # File explorer.
                telescope-nvim    # Fuzzy finder.
                telescope-file-browser-nvim  # File browser for Telescope.
                nvim-web-devicons # File type icons.
                avante-nvim       # AI-based suggestions.
                img-clip-nvim     # Image clipboard support.
		nvim-lspconfig    # LSP configuration.
		nvim-cmp          # LSP auto-completion.
		cmp-nvim-lsp      # LSP source for nvim-cmp.
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
            pkgs.nil                                 # LSP for Ni.x
            pkgs.nodePackages.typescript             # TypeScript compiler.
            pkgs.nodePackages.typescript-language-server  # LSP for TypeScript.
            pkgs.vue-language-server                  # Volar (Vue language server) for Vue/TS support.
          ];
          shellHook = ''
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
