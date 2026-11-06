{ inputs, pkgs, ... }:

let
  # Statically linked, so the release binary runs as-is. Its self-update
  # (`hc update`) cannot replace a store path: bump version and hash here.
  herdrCore = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "herdr-core";
    version = "0.1.14";

    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/core/${version}/herdr-core-linux-x86_64.tar.gz";
      hash = "sha256-6dur3q0M4M495RtvVMyVSe/tu0Gy+ESLaTKrDRRCND4=";
    };

    dontConfigure = true;
    dontBuild = true;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm0755 herdr-core "$out/bin/herdr-core"
      ln -s herdr-core "$out/bin/hc"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Run programs and coding agents in terminals that stay alive";
      homepage = "https://herdr.dev";
      mainProgram = "hc";
      platforms = [ "x86_64-linux" ];
    };
  };

  # GPUI desktop client for herdr-core. It links xcb/xkbcommon and dlopens
  # Vulkan, EGL and Wayland, so those go on its runpath. Update like herdrCore.
  herdrApp = pkgs.stdenv.mkDerivation rec {
    pname = "herdr-app";
    version = "0.1.9";

    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/app/${version}/herdr-app-linux-x86_64.tar.gz";
      hash = "sha256-2m97QPbEFsW03vjbz4t2Z30Cvk9LRdBqTWWHZoUOC0U=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.copyDesktopItems ];
    buildInputs = with pkgs; [ libxcb libxkbcommon stdenv.cc.cc.lib ];
    runtimeDependencies = with pkgs; [ libGL vulkan-loader wayland ];

    dontConfigure = true;
    dontBuild = true;

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "herdr-app";
        desktopName = "Herdr";
        comment = "Terminals and coding agents that keep running";
        exec = "herdr-app";
        icon = "herdr-app";
        categories = [ "Development" ];
        startupWMClass = "herdr-app";
      })
    ];

    installPhase = ''
      runHook preInstall
      install -Dm0755 herdr-app "$out/bin/herdr-app"
      install -Dm0644 herdr-app.svg "$out/share/icons/hicolor/scalable/apps/herdr-app.svg"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Desktop app for terminals and coding agents running in herdr-core";
      homepage = "https://herdr.dev";
      mainProgram = "herdr-app";
      platforms = [ "x86_64-linux" ];
    };
  };

  drukBinary = pkgs.stdenvNoCC.mkDerivation {
    pname = "druk";
    version = "1.10.0";

    src = pkgs.fetchurl {
      url = "https://github.com/letstri/druk/releases/download/v1.10.0/druk-linux-x64.tar.gz";
      hash = "sha256-rTwq1OiSWZdX8/HCKcBk4eWA4TjnBsd5yBr5uO5V6aU=";
    };

    dontConfigure = true;
    dontBuild = true;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm0755 druk "$out/libexec/druk"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Terminal code editor with file tree, tabs, search, and git integration";
      homepage = "https://github.com/letstri/druk";
      license = licenses.mit;
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
    };
  };

  # Druk is a Bun single-file executable: patching its ELF would remove the
  # embedded editor payload and leave only the Bun runtime.  Run the unmodified
  # binary in the FHS compatibility environment instead.
  druk = pkgs.writeShellApplication {
    name = "druk";
    runtimeInputs = [ pkgs.steam-run ];
    text = ''
      exec steam-run ${drukBinary}/libexec/druk "$@"
    '';
  };

  tldrawOffline = pkgs.appimageTools.wrapType2 rec {
    pname = "tldraw-offline";
    version = "1.11.0";

    src = pkgs.fetchurl {
      url = "https://github.com/tldraw/tldraw-offline/releases/download/v1.11.0/tldraw-offline-linux-x86_64.AppImage";
      hash = "sha256-CUkGdHYz22gOYV5X+yAdB4yWi1Ii5zHJ53qgdnNEDgU=";
    };

    meta = with pkgs.lib; {
      description = "Offline tldraw desktop application for local whiteboards and diagrams";
      homepage = "https://offline.tldraw.com/";
      license = licenses.unfree;
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      mainProgram = "tldraw-offline";
    };
  };

  # `wrapType2` exposes the AppImage executable but does not install a
  # launcher entry, so provide one explicitly for desktop menus.
  tldrawDesktopEntry = pkgs.makeDesktopItem {
    name = "tldraw-offline";
    desktopName = "tldraw";
    comment = "Offline whiteboard and diagram editor";
    exec = "tldraw-offline %U";
    categories = [ "Office" "Graphics" ];
    terminal = false;
    startupNotify = true;
  };

  paperDesktop = pkgs.appimageTools.wrapType2 rec {
    pname = "paper-desktop";
    version = "0.5.2";

    src = pkgs.fetchurl {
      url = "https://download.paper.design/linux/appImage";
      hash = "sha256-195ZhaNYUiIk/r/M4zaUZIPvjCQ1oTvCuck+7uV5Zq4=";
    };

    meta = with pkgs.lib; {
      description = "Paper Desktop design tool";
      homepage = "https://paper.design";
      license = licenses.unfree;
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "paper-desktop";
    };
  };

  paperDesktopEntry = pkgs.makeDesktopItem {
    name = "paper-desktop";
    desktopName = "Paper";
    comment = "Paper Desktop design tool";
    exec = "paper-desktop %U";
    categories = [ "Graphics" "Development" ];
    mimeTypes = [ "x-scheme-handler/paper" ];
    terminal = false;
    startupNotify = true;
  };

  # GTK 3 rejects `border-spacing`; the Gruvbox theme includes it in its
  # dropdown styling, producing a warning every time a GTK 3 application starts.
  gruvboxGtkTheme = pkgs.gruvbox-gtk-theme.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      find . -path '*/gtk-3.0/gtk.css' -type f \
        -exec sed -i '/^[[:space:]]*border-spacing: 6px;[[:space:]]*$/d' {} +
    '';
  });

  obsidianUpstream = pkgs.obsidian.overrideAttrs (_: {
    version = "1.12.7";
    src = pkgs.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian-1.12.7.tar.gz";
      hash = "sha256-/L4IsRHZwf2wm5wIlSsG4cgpxiFj66JYTEtOyFm+B50=";
    };
  });
in
{
  environment.systemPackages = with pkgs; [
    age
    ghostty
    authenticator
    btop
    bubblewrap
    cmatrix
    gamescope
    gh
    git
    unzip
    networkmanagerapplet
    openvpn
    sops
    ssh-to-age
    xfce.thunar
    xfce.thunar-archive-plugin
    xarchiver
    gruvboxGtkTheme
    gruvbox-dark-icons-gtk
    adwaita-icon-theme
    waydroid-helper
    wl-clipboard
    xwayland-satellite
    chromium
    gnome-disk-utility
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium
    youtube-music
    inputs.zed.packages.${pkgs.stdenv.hostPlatform.system}.default
    obsidianUpstream
    vesktop
    dbeaver-bin
    mongodb-compass
    fastfetch
    nodejs
    druk
    herdrCore
    herdrApp
    # Review tool used by the bercail Herdr layout; not in 25.11.
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tuicr
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.openspec.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.aven
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-agent-acp
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agentsview
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.gno
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
    obs-studio
    tldrawOffline
    tldrawDesktopEntry
    paperDesktop
    paperDesktopEntry
    pavucontrol
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
