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
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/paper" = [ "paper-desktop.desktop" ];
    };
  };
  home.packages = with pkgs; [

    mpvpaper
    lazygit
    lxqt.lxqt-policykit
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
      tree-sitter
    ];
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox";
      editor = {
        mouse = true;
        cursorline = true;
        bufferline = "multiple";
        color-modes = true;
        true-color = true;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        indent-guides = {
          render = true;
        };

        soft-wrap = {
          enable = true;
        };
      };
    };
    extraPackages = with pkgs; [
      nil
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

  programs.starship = {
    enable = true;
    settings = {
      format = "($nix_shell$fill$git_metrics$line_break)$cmd_duration$character";
      right_format = "$directory$git_branch$git_status$package$python$nodejs$time";
      add_newline = true;
      continuation_prompt = "[▸▹ ](dimmed white)";

      fill = {
        symbol = " ";
      };

      git_metrics = {
        disabled = false;
        format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
        added_style = "italic dimmed green";
        deleted_style = "italic dimmed red";
      };

      character = {
        format = "$symbol ";
        success_symbol = "[◎](bold italic bright-yellow)";
        error_symbol = "[○](italic purple)";
      };

      directory = {
        home_symbol = "⌂";
        truncation_length = 2;
        truncation_symbol = "□ ";
        read_only = " ◈";
        use_os_path_sep = true;
        style = "italic blue";
        format = "[$path]($style)[$read_only]($read_only_style)";
      };

      git_branch = {
        format = " [$branch(:$remote_branch)]($style)";
        symbol = "[△](bold italic bright-blue)";
        style = "italic bright-blue";
        truncation_length = 11;
        ignore_branches = [ "main" "master" ];
        only_attached = true;
      };

      git_status = {
        style = "bold italic bright-blue";
        format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
        ahead = "[▴│[$count](bold white)│](italic green)";
        behind = "[▿│[$count](bold white)│](italic red)";
        modified = "[●◦](italic yellow)";
        untracked = "[◌◦](italic bright-yellow)";
        staged = "[▪┤[$count](bold white)│](italic bright-cyan)";
        deleted = "[✕](italic red)";
      };

      cmd_duration = {
        format = "[◄ $duration ](italic white)";
      };

      time = {
        disabled = false;
        format = "[ $time]($style)";
        time_format = "%R";
        style = "italic dimmed white";
      };

      nix_shell = {
        symbol = "✶";
        format = "[$symbol nix⎪$state⎪]($style) [$name](italic dimmed white)";
        style = "bold italic dimmed blue";
      };
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
    ".local/bin/codex-resume" = {
      text = ''
        #!/usr/bin/env bash
        # Resume the most recent Codex conversation for the current project.
        exec codex resume --last "$@"
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
    "herdr/config.toml".text = ''
      onboarding = false

      [theme]
      name = "gruvbox"

      [ui]
      agent_panel_sort = "priority"

      [keys]
      new_tab = "ctrl+super+n"
      close_tab = "ctrl+super+q"

      [session]
      # Re-open each supported agent (including Codex) in its exact recorded
      # conversation when Herdr restores panes after a server or system restart.
      resume_agents_on_restore = true

      [experimental]
      # Keep the visible terminal output too, not only Codex's saved transcript.
      pane_history = true
    '';
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

  systemd.user.services.lxqt-policykit-agent = {
    Unit = {
      Description = "PolicyKit authentication agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
      Restart = "on-failure";
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
