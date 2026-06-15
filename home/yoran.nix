{ lib, pkgs, ... }:

{
  home.username = "yoran";
  home.homeDirectory = "/home/yoran";
  home.stateVersion = "25.11";

  xdg.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      vpn-up = ''nmcli --ask connection up id "ritase-royan-vpn"'';
      vpn-down = ''nmcli connection down id "ritase-royan-vpn"'';
      vpn-status = ''nmcli connection show --active'';
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
            criteria = "DP-2";
            status = "enable";
            mode = "1600x900";
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
