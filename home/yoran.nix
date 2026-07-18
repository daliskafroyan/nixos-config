{ inputs, lib, pkgs, hostName ? null, ... }:

let
  encryptedWallpaperDir = ../assets/wallpapers;
  hostImports =
    if hostName != null then
      let
        hostModulePath = ./yoran/hosts + "/${hostName}.nix";
      in
      lib.optional (builtins.pathExists hostModulePath) hostModulePath
    else
      [ ];
in
{
  imports = hostImports;

  home.username = "yoran";
  home.homeDirectory = "/home/yoran";
  home.stateVersion = "25.11";

  xdg.enable = true;
  home.packages = with pkgs; [
    mpvpaper
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      clang
      curl
      fd
      git
      gnutar
      ripgrep
      lazygit
      tree-sitter
    ];
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      "sys-switch" = ''"$HOME/system-configuration/scripts/switch"'';
      vpn-up = ''sudo "$HOME/.local/bin/ritase-vpn" up'';
      vpn-down = ''sudo "$HOME/.local/bin/ritase-vpn" down'';
      vpn-status = ''"$HOME/.local/bin/ritase-vpn" status'';
      vpn-up-nm = ''nmcli --ask connection up id "ritase-royan-vpn"'';
      vpn-down-nm = ''nmcli connection down id "ritase-royan-vpn"'';
      vpn-scolarsia-up = ''sudo "$HOME/.local/bin/scolarsia-vpn" up'';
      vpn-scolarsia-down = ''sudo "$HOME/.local/bin/scolarsia-vpn" down'';
      vpn-scolarsia-status = ''"$HOME/.local/bin/scolarsia-vpn" status'';
    };
  };
  home.file = {
    ".local/bin/ritase-vpn" = {
      source = ../dotfiles/noctalia/scripts/ritase-vpn;
      executable = true;
    };
    ".local/bin/dbeaver" = {
      text = ''
        #!/usr/bin/env bash
        exec env NO_AT_BRIDGE=1 GTK_THEME=Adwaita:light ${pkgs.dbeaver-bin}/bin/dbeaver "$@"
      '';
      executable = true;
    };
    ".local/bin/scolarsia-vpn" = {
      source = ../dotfiles/noctalia/scripts/scolarsia-vpn;
      executable = true;
    };
    ".local/share/applications/dbeaver.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Terminal=false
        Name=dbeaver-ce
        GenericName=Universal Database Manager
        Comment=Universal Database Manager and SQL Client.
        Exec=/home/yoran/.local/bin/dbeaver %U
        Icon=dbeaver
        Categories=IDE;Development
        StartupWMClass=DBeaver
        StartupNotify=true
        Keywords=Database;SQL;IDE;JDBC;ODBC;MySQL;PostgreSQL;Oracle;DB2;MariaDB
        MimeType=application/sql
      '';
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
    "nvim".source = ../dotfiles/nvim;
    "niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    "noctalia/config.toml".source = ../dotfiles/noctalia/config.toml;
    "noctalia/nix-snowflake-colours.svg".source = ../dotfiles/noctalia/nix-snowflake-colours.svg;
    "noctalia/nix-snowflake-white.svg".source = ../dotfiles/noctalia/nix-snowflake-white.svg;
    "noctalia/scripts/sync-system-theme.sh" = {
      text = builtins.replaceStrings [ "@glib@" "@gsettings-desktop-schemas@" ] [ "${lib.getBin pkgs.glib}" "${pkgs.gsettings-desktop-schemas}" ] (builtins.readFile ../dotfiles/noctalia/scripts/sync-system-theme.sh);
      executable = true;
    };
    "noctalia/scripts/sync-alacritty-theme.sh" = {
      source = ../dotfiles/noctalia/scripts/sync-alacritty-theme.sh;
      executable = true;
    };
    "opencode/opencode.jsonc".source = ../dotfiles/opencode/opencode.jsonc;
    "opencode/skills/grill-me/SKILL.md".source = ../dotfiles/opencode/skills/grill-me/SKILL.md;
    "zed/settings.template.json".source = ../dotfiles/zed/settings.json;
  };

  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia shell";
      PartOf = [ "graphical-session.target" ];
      After = [ "niri.service" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.bash}/bin/bash -lc 'rm -f \"$XDG_RUNTIME_DIR\"/noctalia-*.lock'";
      ExecStart = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.activation.alacrittyThemeCurrent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.config/alacritty/theme-current.toml" ]; then
      ${pkgs.coreutils}/bin/install -m 0644 \
        "$HOME/.config/alacritty/theme-dark.toml" \
        "$HOME/.config/alacritty/theme-current.toml"
    fi
  '';
  home.activation.zedThemeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L "$HOME/.config/zed/settings.json" ] || [ ! -e "$HOME/.config/zed/settings.json" ]; then
      $DRY_RUN_CMD rm -f "$HOME/.config/zed/settings.json"
      $DRY_RUN_CMD cp "$HOME/.config/zed/settings.template.json" "$HOME/.config/zed/settings.json"
    fi
  '';


  home.activation.wallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    if builtins.pathExists encryptedWallpaperDir then
      ''
        if [ -f "$HOME/.ssh/id_ed25519_personal" ]; then
          wallpaper_dir="$HOME/.local/share/wallpapers"

          ${pkgs.coreutils}/bin/mkdir -p "$wallpaper_dir"

          for encrypted_file in ${encryptedWallpaperDir}/*.mp4.age; do
            if [ ! -e "$encrypted_file" ]; then
              continue
            fi

            base_name="$(${pkgs.coreutils}/bin/basename "$encrypted_file" .age)"
            target_file="$wallpaper_dir/$base_name"
            temp_file="$target_file.tmp"

            ${pkgs.age}/bin/age -d \
              -i "$HOME/.ssh/id_ed25519_personal" \
              -o "$temp_file" \
              "$encrypted_file"
            ${pkgs.coreutils}/bin/mv "$temp_file" "$target_file"
          done

          if [ ! -e "$wallpaper_dir/current.mp4" ] && [ -f "$wallpaper_dir/1.mp4" ]; then
            ${pkgs.coreutils}/bin/ln -sfn "$wallpaper_dir/1.mp4" "$wallpaper_dir/current.mp4"
          fi
        fi
      ''
    else
      ""
  );
}
