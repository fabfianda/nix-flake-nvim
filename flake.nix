{
  description = "A flake for fully-featured Neovim";

  # Define the inputs for this flake, primarily Nixpkgs and flake-utils.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master"; # Use the master branch of Nixpkgs.
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes.
  };

  # Define the outputs of this flake.
  outputs = { nixpkgs, flake-utils, ... }:
  # Use flake-utils to generate outputs for specified systems.
  flake-utils.lib.eachSystem [
      flake-utils.lib.system.x86_64-linux # Linux x86_64
      flake-utils.lib.system.x86_64-darwin # macOS x86_64
    ] (system:
      let
        # Import Nixpkgs for the current system.
        pkgs = import nixpkgs {
          inherit system;
          config = {}; # No specific Nixpkgs configuration overrides.
        };

        # Define a specific version of aider-chat with browser support enabled.
        aider-chat-with-browser = pkgs.aider-chat.passthru.withOptional { withBrowser = true; };

        # Override the default Neovim package with custom configuration.
        nvim = pkgs.neovim.override {
          configure = {
            # Load custom Neovim configuration from ./config/default.nix (implicitly via ./config/init.lua -> ./config/index.nix)
            customRC = import ./config { inherit pkgs; };
            # Define Vim packages to be installed.
            packages.myVimPackage = with pkgs.vimPlugins; {
              # Plugins that are loaded on startup.
              start = [
                # Misc plugins
	        vim-nix           # Nix file type and syntax highlighting.
                vim-fugitive      # Git integration wrapper.
                ansible-vim       # Ansible syntax support.
                chadtree          # File explorer.
                telescope-nvim    # Fuzzy finder.
                telescope-file-browser-nvim  # File browser for Telescope.
                nvim-web-devicons # File type icons.
                img-clip-nvim     # Image clipboard support.
                lualine-nvim      # Minimal status line.
		nvim-lspconfig    # Language Server Protocol configuration helper.

                # Linting and formatting integration
                none-ls-nvim      # Use linters/formatters as LSP sources.

                # Auto-completion framework (nvim-cmp) and sources
		cmp-nvim-lsp      # LSP completion source.
		cmp-buffer        # Buffer text completion source.
		cmp-path          # File path completion source.
		cmp-cmdline       # Command line completion source.
		nvim-cmp          # The completion framework itself.
                cmp-vsnip         # Snippet completion source.
                vim-vsnip         # Snippet engine.

                # Tree-sitter for enhanced syntax highlighting and code analysis
                nvim-treesitter   # Core Tree-sitter integration.
                # Specific language parsers for Tree-sitter
                nvim-treesitter-parsers.query
                nvim-treesitter-parsers.javascript
                nvim-treesitter-parsers.typescript
                nvim-treesitter-parsers.comment
                nvim-treesitter-parsers.css
                nvim-treesitter-parsers.html
                nvim-treesitter-parsers.vue

                # Git diff tools
                vim-signify          # Enhanced diff signs in the gutter.
                diffview-nvim        # Better diff viewing interface.

                # Color schemes
                gruvbox
                gruvbox-baby
                sonokai
              ];
              # Plugins that are loaded optionally/on demand (currently none).
              opt = [ ];
            };
          };
        };
      in {
        # Define the development shell environment.
        devShell = pkgs.mkShell {
          # Packages available in the development shell.
          buildInputs = [
            # Core development tools
            nvim                         # The configured Neovim editor.
            aider-chat-with-browser      # Aider AI coding assistant with browser support.
            pkgs.ripgrep                 # Fast code searching tool (used by Telescope).
            pkgs.nodejs                  # Node.js runtime (required by some LSPs and tools).

            # Language Server Protocol (LSP) servers
            pkgs.nil                     # LSP for Nix language.
            pkgs.nodePackages.typescript-language-server # LSP for TypeScript/JavaScript.
            pkgs.vue-language-server     # Volar: LSP for Vue.js (includes TypeScript support within Vue files).

            # Linters and formatters (integrated via none-ls)
            pkgs.nodePackages.eslint     # JavaScript/TypeScript linter.
            pkgs.nodePackages.prettier   # Code formatter (JS, TS, CSS, HTML, Vue, etc.).

            # Required for Tree-sitter parsers (implicitly included via nvim config, but good practice to list)
            pkgs.nodePackages.typescript # TypeScript compiler (needed by TS LSP and potentially other tools).
          ];
          # Shell commands executed when entering the development shell.
          shellHook = ''
            export FLAKE_VERSION="v1.93" # Example environment variable.
            alias vi="nvim"              # Alias 'vi' to run the configured 'nvim'.
          '';
        };

        # Define a runnable application for Neovim.
        apps.nvim = {
          type = "app";
          program = "${nvim}/bin/nvim"; # Path to the Neovim executable from the overridden package.
        };
      }
    );
}
