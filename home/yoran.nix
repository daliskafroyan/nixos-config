{ lib, pkgs, ... }:

{
  home.username = "yoran";
  home.homeDirectory = "/home/yoran";
  home.stateVersion = "25.11";

  xdg.enable = true;
  xdg.configFile = {
    "alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;
    "alacritty/theme-dark.toml".source = ../dotfiles/alacritty/theme-dark.toml;
    "alacritty/theme-light.toml".source = ../dotfiles/alacritty/theme-light.toml;
    "foot/foot.ini".source = ../dotfiles/foot/foot.ini;
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
