{ inputs, lib, pkgs, ... }:

{
  imports = [ inputs.nvf.homeManagerModules.default ];

  home.username = "yoran";
  home.homeDirectory = "/home/yoran";
  home.stateVersion = "25.11";

  xdg.enable = true;
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings.vim = {
      viAlias = false;
      vimAlias = true;
      lineNumberMode = "relNumber";
      clipboard.enable = true;
      theme.enable = true;
      treesitter.enable = true;
      lsp.enable = true;
      globals.mapleader = " ";
      dashboard.alpha.enable = true;
      binds.whichKey.enable = true;
      comments.comment-nvim.enable = true;
      visuals.indent-blankline.enable = true;
      notify.nvim-notify.enable = true;
      filetree.neo-tree = {
        enable = true;
        setupOpts = {
          window = {
            position = "left";
            width = 32;
          };
          filesystem = {
            follow_current_file.enabled = true;
            hijack_netrw_behavior = "open_default";
          };
        };
      };
      fzf-lua.enable = true;
      autocomplete.blink-cmp.enable = true;
      autopairs.nvim-autopairs.enable = true;
      git.gitsigns.enable = true;
      statusline.lualine.enable = true;
      tabline.nvimBufferline.enable = true;
      terminal.toggleterm.enable = true;
      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Neotree filesystem reveal left toggle<CR>";
          desc = "Explorer";
        }
        {
          mode = "n";
          key = "<leader>tt";
          action = "<cmd>ToggleTerm<CR>";
          desc = "Terminal";
        }
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>FzfLua files<CR>";
          desc = "Find files";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>FzfLua live_grep<CR>";
          desc = "Live grep";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>FzfLua buffers<CR>";
          desc = "Buffers";
        }
        {
          mode = "n";
          key = "<leader>fh";
          action = "<cmd>FzfLua helptags<CR>";
          desc = "Help tags";
        }
      ];
      languages.nix = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      vpn-up = ''sudo "$HOME/.local/bin/ritase-vpn" up'';
      vpn-down = ''sudo "$HOME/.local/bin/ritase-vpn" down'';
      vpn-status = ''"$HOME/.local/bin/ritase-vpn" status'';
      vpn-up-nm = ''nmcli --ask connection up id "ritase-royan-vpn"'';
      vpn-down-nm = ''nmcli connection down id "ritase-royan-vpn"'';
    };
  };
  home.file = {
    ".local/bin/ritase-vpn" = {
      source = ../dotfiles/noctalia/scripts/ritase-vpn;
      executable = true;
    };
  };
  programs.ssh = {
    enable = true;
    matchBlocks = {
      github-personal = {
        hostname = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519_personal" ];
        identitiesOnly = true;
      };

      github-work = {
        hostname = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519_work" ];
        identitiesOnly = true;
      };

      lambda-dev = {
        hostname = "172.16.2.21";
        user = "lambda";
        identityFile = [ "~/.ssh/lambda-staging" ];
        identitiesOnly = true;
      };

      lambda-staging = {
        hostname = "172.16.2.21";
        user = "lambda";
        identityFile = [ "~/.ssh/lambda-staging" ];
        identitiesOnly = true;
      };

      lambda-prod = {
        hostname = "10.0.3.33";
        user = "lambda";
        identityFile = [ "~/.ssh/lambda-prod" ];
        identitiesOnly = true;
      };
    };
  };

  xdg.configFile = {
    "alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;
    "alacritty/theme-dark.toml".source = ../dotfiles/alacritty/theme-dark.toml;
    "alacritty/theme-light.toml".source = ../dotfiles/alacritty/theme-light.toml;
    "niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    "noctalia/config.toml".source = ../dotfiles/noctalia/config.toml;
    "noctalia/nix-snowflake-colours.svg".source = ../dotfiles/noctalia/nix-snowflake-colours.svg;
    "noctalia/nix-snowflake-white.svg".source = ../dotfiles/noctalia/nix-snowflake-white.svg;
    "noctalia/scripts/sync-alacritty-theme.sh" = {
      source = ../dotfiles/noctalia/scripts/sync-alacritty-theme.sh;
      executable = true;
    };
    "opencode/opencode.jsonc".source = ../dotfiles/opencode/opencode.jsonc;
    "opencode/skills/grill-me/SKILL.md".source = ../dotfiles/opencode/skills/grill-me/SKILL.md;
    "zed/settings.json".source = ../dotfiles/zed/settings.json;
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "*";
            status = "enable";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
    ];
  };

  home.activation.alacrittyThemeCurrent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.config/alacritty/theme-current.toml" ]; then
      ${pkgs.coreutils}/bin/install -m 0644 \
        "$HOME/.config/alacritty/theme-dark.toml" \
        "$HOME/.config/alacritty/theme-current.toml"
    fi
  '';
}
