{ config, pkgs, inputs, ... }:

let
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

  ioskeleyMono = pkgs.stdenvNoCC.mkDerivation {
    pname = "ioskeley-mono";
    version = "2.0.0";

    src = pkgs.fetchzip {
      url = "https://github.com/ahatem/IoskeleyMono/releases/download/v2.0.0/IoskeleyMono.zip";
      hash = "sha256-EJDlA18XZPq7vhtpw/74n5s1NmTy0/DLu2oYB7OuvbA=";
      stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src/Normal/Unhinted/*.ttf $out/share/fonts/truetype/
    '';
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  services.xserver.enable = true;
  programs.niri.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "niri";
  xdg.portal.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.yoran = {
    isNormalUser = true;
    description = "yoran";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  environment.sessionVariables = {
    GTK_THEME = "Gruvbox-Dark";
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    ioskeleyMono
    ibm-plex
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "IBM Plex Serif" "Noto Serif CJK JP" ];
    sansSerif = [ "IBM Plex Sans" "Noto Sans CJK JP" ];
    monospace = [ "Ioskeley Mono" "Symbols Nerd Font Mono" "Noto Sans Mono CJK JP" ];
    emoji = [ "Noto Color Emoji" ];
  };

  environment.systemPackages = with pkgs; [
    alacritty
    foot
    gh
    git
    xfce.thunar
    gruvbox-gtk-theme
    gruvbox-dark-icons-gtk
    wl-clipboard
    chromium
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium
    youtube-music
    zed-editor
    vesktop
    fastfetch
    nodejs
    opencode
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Gruvbox-Dark
    gtk-icon-theme-name=oomox-gruvbox-dark
    gtk-application-prefer-dark-theme=1
  '';

  environment.etc."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Gruvbox-Dark
    gtk-icon-theme-name=oomox-gruvbox-dark
    gtk-application-prefer-dark-theme=1
  '';

  system.stateVersion = "25.11";
}
