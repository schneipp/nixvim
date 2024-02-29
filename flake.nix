{
  description = "Cyberdegenario's Fucked Up Dev Environment";
  inputs.nixvim.url = "github:nix-community/nixvim";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixvim,
    flake-utils,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    config = {
      colorschemes.gruvbox.enable = true;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: 
      let
        nixvim' = nixvim.legacyPackages."${system}";
        nvim = nixvim'.makeNixvim {
          keymaps = [
            {
              action = ":FloatermNew lazygit<CR>";
              key = "<leader>gg";
            }
            {
              action = "<cmd>Telescope live_grep<CR>";
              key = "<leader>ps";
            }
            {
              action = "<cmd>Telescope find_files<CR>";
              key = "<leader><leader>";
            }
            {
              action = "<cmd>Telescope find_files<CR>";
              key = "<leader>ff";
            }
            {
              action = ":Neotree focus toggle<CR>";
              key = "<leader>e";
            }
            {
              action = ":FloatermToggle<CR>";
              key = "<C-t>";
            }
            {
              mode = "n";
              action = "nzzzv";
              key = "n";
            }
            {
              mode = "n";
              action = "Nzzzv";
              key = "N";
            }
            {
              mode = "v";
              action = "<cmd>lua require('multicursor').start()<CR>";
              key = "<C-n>";
            }
            {
              mode = "v";
              action = "<cmd>lua require('multicursor').next()<CR>";
              key = "<C-n>";
            }
            {
              mode = "v";
              action = "<cmd>lua require('multicursor').prev()<CR>";
              key = "<C-p>";
            }
            #keep selection when indenting
            {
              mode = "v";
              action = "<gv";
              key = "<";
            }
            {
              mode = "v";
              action = ">gv";
              key = ">";
            }
            {
              mode = "v";
              action = ":m \'<-2<CR>gv=gv";
              key = "<S-k>";
            }
            {
              mode = "v";
              action = ":m \'<+1<CR>gv=gv";
              key = "<S-j>";
            }
          ];
          colorschemes.catppuccin.enable = true;
          globals.mapleader = " ";
          options = {
            number = true;         # Show line numbers
            relativenumber = true; # Show relative line numbers
            shiftwidth = 2;        # Tab width should be 2
          };
          # telescope 
          plugins.telescope = {
            enable = true;
          };
          plugins.floaterm = {
            enable = true;
            wintype = "float";
          };
          #copilot
          plugins.copilot-lua = {
            enable = true;
            serverOptsOverrides = {
            panel = {
                enabled = true;
                auto_refresh = true;
                keymap = {
                  jump_prev = "[[";
                  jump_next = "]]";
                  accept = "<CR>";
                  refresh = "gr";
                  open = "<M-CR>";
                };
                layout = {
                  position = "bottom"; 
                  ratio = 0.4;
                };
              };
              suggestion = {
                enabled = true;
                auto_trigger = true;
                debounce = 75;
                keymap = {
                  accept = "<C-l>";
                  accept_word = false;
                  accept_line = false;
                  next = "<M-]>";
                  prev = "<M-[>";
                  dismiss = "<C-]>";
                };
              };
            };
          };
          plugins.neo-tree = {
            enable = true;

          };
          plugins.luasnip = {
            enable = true;
          };
          #lualine
          plugins.lualine = {
            enable = true;
          };
          #multicursor
          plugins.multicursors = {
            enable = true;
          };
          #treesitter
          plugins.treesitter = {
            enable = true;
          };
          plugins.nvim-cmp = {
            enable = true;
            autoEnableSources = true;
            sources = [
              {name = "nvim_lsp";}
              {name = "path";}
              {name = "buffer";}
              {name = "luasnip";}
            ];

            mapping = {
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = {
                action = ''
                  function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.expandable() then
                      luasnip.expand()
                    elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    elseif check_backspace() then
                      fallback()
                    else
                      fallback()
                    end
                  end
                '';
                modes = [ "i" "s" ];
              };
            };
          };
          plugins.lsp-format = {
            enable = true;
          };
          plugins.lsp-lines = {
            enable = true;
          };
          plugins.harpoon = {
            enable = true;
            keymaps = {
              cmdToggleQuickMenu = "<leader>h";
              addFile = "<leader>ha";
              navNext = "<leader>j";
              navPrev = "<leader>k";
            };
          };
          plugins.lsp = {
            enable = true;

            servers = {
              tsserver.enable = true;
              html.enable = true;
              lua-ls = {
                enable = true;
                settings.telemetry.enable = false;
              };
              rust-analyzer = {
                installRustc = true;
                enable = true;
                installCargo = true;
              };
            };
          };
        };
      in {
        devShells = {
          default = pkgs.mkShell {
          buildInputs = [
            # here you can add all the packages you want to have in your dev environment
            nvim
            pkgs.jq
            pkgs.tmux
            pkgs.neofetch
            pkgs.ripgrep
            pkgs.fzf
            pkgs.git
            pkgs.gh
            pkgs.lazygit
          ];
          shellHook = ''
          echo "Welcome to the dev environment!"
          neofetch
          '';
        };
      };
      };
    };
}
