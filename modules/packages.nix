{ inputs, pkgs, ... }:

let
  codexUpstream = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    version = "0.144.5";

    src = pkgs.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v0.144.5/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-tr6hO+30kyMvZxdxTEXng3iMaVztzzfDRPc6/Jex7J8=";
    };

    dontConfigure = true;
    dontBuild = true;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      install -m 0755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
      runHook postInstall
    '';
  };

  herdrUpstream = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr";
    version = "0.7.4";

    src = pkgs.fetchurl {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v0.7.4/herdr-linux-x86_64";
      hash = "sha256-vA/ALUulAPnKwjU6Q+Z/4DZ4Xsym61U3jgUPrDwQMFk=";
    };

    dontConfigure = true;
    dontBuild = true;
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      install -m 0755 "$src" "$out/bin/herdr"
      runHook postInstall
    '';
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

  opencode = pkgs.stdenv.mkDerivation {
    pname = "opencode";
    version = "1.17.7";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/opencode-linux-x64/-/opencode-linux-x64-1.17.7.tgz";
      hash = "sha512-UIxkdA/8281EHbHYVr5PSD+eVoMdlyfkmXiZp3u9duttsMHdf1F6lw0XjYmDRBCPp8zQM1D1RLCABuRA/kUX+Q==";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/opencode
      cp -r ./* $out/share/opencode/

      mkdir -p $out/bin
      ln -s $out/share/opencode/bin/opencode $out/bin/opencode
    '';
  };
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
    codexUpstream
    herdrUpstream
    druk
    inputs.openspec.packages.${pkgs.stdenv.hostPlatform.system}.default
    opencode
    inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.omp
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.aven
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agentsview
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.gno
    obs-studio
    tldrawOffline
    tldrawDesktopEntry
    paperDesktop
    paperDesktopEntry
    pavucontrol
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
