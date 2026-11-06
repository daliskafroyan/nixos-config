{ inputs, lib, pkgs, username, hostName ? null, ... }:

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
  imports = hostImports ++ [ inputs.nvf.homeManagerModules.default ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/paper" = [ "paper-desktop.desktop" ];
      "image/avif" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/heic" = [ "org.gnome.Loupe.desktop" ];
      "image/heif" = [ "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
    };
  };
  home.packages = with pkgs; [

    mpvpaper
    gitui
    loupe
    lxqt.lxqt-policykit
    xfce.thunar-volman
    xfce.tumbler
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;
      opts = {
        number = true;
        relativenumber = true;
      };
      theme = {
        enable = true;
        name = "gruvbox";
        style = "dark";
      };
      visuals.nvim-web-devicons.enable = true;
      filetree.nvimTree = {
        enable = true;
        setupOpts = {
          update_focused_file.enable = true;
          git.enable = true;
        };
      };
      terminal.toggleterm = {
        enable = true;
      };
      lazy.plugins.toggleterm-nvim = {
        keys = [
          {
            key = "<leader>gg";
            mode = "n";
            desc = "Open GitUI";
          }
        ];
        after = ''
          local terminal = require 'toggleterm.terminal'
          local gitui = terminal.Terminal:new({
            cmd = '${lib.getExe pkgs.gitui}',
            direction = 'float',
            hidden = true,
            on_open = function(term)
              vim.cmd('startinsert!')
            end,
          })

          vim.keymap.set('n', '<leader>gg', function() gitui:toggle() end, {
            silent = true,
            noremap = true,
            desc = 'Open GitUI',
          })
        '';
      };
      # nvf currently requires every legacy keymap group to be explicitly
      # initialized, even when no mappings are configured.
      maps = lib.genAttrs [
        "normal"
        "insert"
        "select"
        "visual"
        "terminal"
        "normalVisualOp"
        "visualOnly"
        "operator"
        "insertCommand"
        "lang"
        "command"
      ] (_: { });
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
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
      "ticket-worktree" = ''"$HOME/system-configuration/scripts/ticket-worktree"'';
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
    /* Previous inline preset retained temporarily for reference.
    settings = builtins.fromTOML ''
      format = """
      [](color_orange)\
      $os\
      $username\
      [](bg:color_yellow fg:color_orange)\
      $directory\
      [](fg:color_yellow bg:color_aqua)\
      $git_branch\
      $git_status\
      [](fg:color_aqua bg:color_blue)\
      $c\
      $cpp\
      $rust\
      $golang\
      $nodejs\
      $bun\
      $php\
      $java\
      $kotlin\
      $haskell\
      $python\
      [](fg:color_blue bg:color_bg3)\
      $docker_context\
      $conda\
      $pixi\
      [](fg:color_bg3 bg:color_bg1)\
      $time\
      [ ](fg:color_bg1)\
      $line_break$character"""

      palette = 'gruvbox_dark'

      [palettes.gruvbox_dark]
      color_fg0 = '#fbf1c7'
      color_bg1 = '#3c3836'
      color_bg3 = '#665c54'
      color_blue = '#458588'
      color_aqua = '#689d6a'
      color_green = '#98971a'
      color_orange = '#d65d0e'
      color_purple = '#b16286'
      color_red = '#cc241d'
      color_yellow = '#d79921'

      [os]
      disabled = false
      style = "bg:color_orange fg:color_fg0"

      [os.symbols]
      Windows = "󰍲"
      Ubuntu = "󰕈"
      SUSE = ""
      Raspbian = "󰐿"
      Mint = "󰣭"
      Macos = "󰀵"
      Manjaro = ""
      Linux = "󰌽"
      Gentoo = "󰣨"
      Fedora = "󰣛"
      Alpine = ""
      Amazon = ""
      Android = ""
      AOSC = ""
      Arch = "󰣇"
      Artix = "󰣇"
      EndeavourOS = ""
      CentOS = ""
      Debian = "󰣚"
      Redhat = "󱄛"
      RedHatEnterprise = "󱄛"
      Pop = ""

      [username]
      show_always = true
      style_user = "bg:color_orange fg:color_fg0"
      style_root = "bg:color_orange fg:color_fg0"
      format = '[ $user ]($style)'

      [directory]
      style = "fg:color_fg0 bg:color_yellow"
      format = "[ $path ]($style)"
      truncation_length = 3
      truncation_symbol = "…/"

      [directory.substitutions]
      "Documents" = "󰈙 "
      "Downloads" = " "
      "Music" = "󰝚 "
      "Pictures" = " "
      "Developer" = "󰲋 "

      [git_branch]
      symbol = ""
      style = "bg:color_aqua"
      format = '[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)'

      [git_status]
      style = "bg:color_aqua"
      format = '[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)'

      [nodejs]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [bun]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [c]
      symbol = " "
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [cpp]
      symbol = " "
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [rust]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [golang]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [php]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [java]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [kotlin]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [haskell]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [python]
      symbol = ""
      style = "bg:color_blue"
      format = '[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)'

      [docker_context]
      symbol = ""
      style = "bg:color_bg3"
      format = '[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)'

      [conda]
      style = "bg:color_bg3"
      format = '[[ $symbol( $environment) ](fg:#83a598 bg:color_bg3)]($style)'

      [pixi]
      style = "bg:color_bg3"
      format = '[[ $symbol( $version)( $environment) ](fg:color_fg0 bg:color_bg3)]($style)'

      [time]
      disabled = false
      time_format = "%R"
      style = "bg:color_bg1"
      format = '[[  $time ](fg:color_fg0 bg:color_bg1)]($style)'

      [line_break]
      disabled = false

      [character]
      disabled = false
      success_symbol = '[](bold fg:color_green)'
      error_symbol = '[](bold fg:color_red)'
      vimcmd_symbol = '[](bold fg:color_green)'
      vimcmd_replace_one_symbol = '[](bold fg:color_purple)'
      vimcmd_replace_symbol = '[](bold fg:color_purple)'
      vimcmd_visual_symbol = '[](bold fg:color_yellow)'
    '';
    */
    settings = builtins.fromTOML (builtins.readFile ../dotfiles/starship.toml);
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
        Exec=/home/${username}/.local/bin/dbeaver %U
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
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        compression = false;
        addKeysToAgent = "no";
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

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

      gaikiken = {
        # Tailscale stays reachable when the server moves to another network.
        hostname = "100.124.68.74";
        user = "yoran";
        identityFile = [ "~/.ssh/id_ed25519_gaikiken" ];
        identitiesOnly = true;
      };
    };
  };

  xdg.configFile = {
    "ghostty/config".source = ../dotfiles/ghostty/config;
    "niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    "noctalia/config.toml".source = ../dotfiles/noctalia/config.toml;
    "noctalia/nix-snowflake-colours.svg".source = ../dotfiles/noctalia/nix-snowflake-colours.svg;
    "noctalia/nix-snowflake-white.svg".source = ../dotfiles/noctalia/nix-snowflake-white.svg;
    "noctalia/scripts/sync-system-theme.sh" = {
      text = builtins.replaceStrings [ "@glib@" "@gsettings-desktop-schemas@" ] [ "${lib.getBin pkgs.glib}" "${pkgs.gsettings-desktop-schemas}" ] (builtins.readFile ../dotfiles/noctalia/scripts/sync-system-theme.sh);
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
      prefix = "ctrl+b"
      new_tab = ["prefix+c", "ctrl+alt+n"]
      close_tab = ["prefix+shift+x", "ctrl+alt+q"]
      rename_tab = ["prefix+shift+t", "ctrl+alt+r"]
      close_workspace = ["prefix+shift+d", "ctrl+alt+shift+q"]
      workspace_picker = ["prefix+w", "ctrl+alt+w"]
      previous_tab = ["prefix+p", "ctrl+alt+["]
      next_tab = ["prefix+n", "ctrl+alt+]"]
      focus_pane_left = ["prefix+h", "ctrl+alt+h"]
      focus_pane_down = ["prefix+j", "ctrl+alt+j"]
      focus_pane_up = ["prefix+k", "ctrl+alt+k"]
      focus_pane_right = ["prefix+l", "ctrl+alt+l"]
      split_vertical = ["prefix+v", "ctrl+alt+d"]
      split_horizontal = ["prefix+minus", "ctrl+alt+shift+d"]
      zoom = ["prefix+z", "ctrl+alt+z"]
      toggle_sidebar = ["prefix+b", "ctrl+alt+b"]
      close_pane = ["prefix+x", "ctrl+alt+x"]

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

  # Reuse Noctalia's existing Wayland lock screen for logind lock and sleep
  # events. systemd-lock-handler bridges these targets from the active session.
  systemd.user.services.noctalia-lock = {
    Unit = {
      Description = "Lock the graphical session through Noctalia";
      Before = [ "lock.target" "sleep.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia msg session lock";
    };
    Install.WantedBy = [ "lock.target" "sleep.target" ];
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


  home.activation.zedThemeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -L "$HOME/.config/zed/settings.json" ] || [ ! -e "$HOME/.config/zed/settings.json" ]; then
      $DRY_RUN_CMD rm -f "$HOME/.config/zed/settings.json"
      $DRY_RUN_CMD cp "$HOME/.config/zed/settings.template.json" "$HOME/.config/zed/settings.json"
    fi

    if [ -z "$DRY_RUN_CMD" ]; then
      ${pkgs.python3}/bin/python3 - <<'PY'
import json
import os
import tempfile
from pathlib import Path

path = Path.home() / ".config/zed/settings.json"
text = path.read_text()
# Existing Zed settings permit leading // documentation comments. The
# migration rewrites strict JSON while preserving every settings key.
json_text = "\n".join(
    line for line in text.splitlines() if not line.lstrip().startswith("//")
)
settings = json.loads(json_text)

settings.setdefault("theme", {}).update({
    "mode": "system",
    "light": "Gruvbox Light Soft",
    "dark": "Gruvbox Dark Soft",
})
settings.setdefault("icon_theme", {}).update({
    "mode": "system",
    "light": "Zed (Default)",
    "dark": "Zed (Default)",
})

with tempfile.NamedTemporaryFile(
    mode="w", dir=path.parent, prefix="settings.json.", delete=False
) as temporary:
    json.dump(settings, temporary, indent=2)
    temporary.write("\n")
    temporary_path = temporary.name

os.replace(temporary_path, path)
PY
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
