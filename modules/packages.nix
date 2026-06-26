{ inputs, pkgs, ... }:

let
  obsidianUpstream = pkgs.obsidian.overrideAttrs (_: {
    version = "1.12.7";
    src = pkgs.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian-1.12.7.tar.gz";
      hash = "sha256-/L4IsRHZwf2wm5wIlSsG4cgpxiFj66JYTEtOyFm+B50=";
    };
  });

  opencode = pkgs.stdenv.mkDerivation {
    pname = "opencode";
    version = "1.16.2";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/opencode-linux-x64/-/opencode-linux-x64-1.16.2.tgz";
      hash = "sha512-O+EKhZ0xGrmxP0v1UuW62FbMborzrYnQ3rKy/ulYWfz9TGhUxu7gSWceBcASXx00T6HM94ob8atE8MnfEzZ0Qg==";
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
    alacritty
    btop
    cmatrix
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
    gruvbox-gtk-theme
    gruvbox-dark-icons-gtk
    wl-clipboard
    chromium
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium
    youtube-music
    inputs.zed.packages.${pkgs.stdenv.hostPlatform.system}.default
    obsidianUpstream
    vesktop
    dbeaver-bin
    fastfetch
    nodejs
    opencode
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
