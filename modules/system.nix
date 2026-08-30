{ pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://zed.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  services.xserver.enable = true;
  programs.niri = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.niri;
  };
  programs.steam.enable = true;
  programs.xwayland.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "niri";
  xdg.portal.enable = true;
  security.polkit.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
  # Private access to gaikiken and its Jellyfin instance from any network.
  services.tailscale.enable = true;
  services.syncthing = {
    enable = true;
    user = "yoran";
    dataDir = "/home/yoran/Documents";
    configDir = "/home/yoran/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
  };
  hardware.bluetooth.enable = true;
  zramSwap.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.udisks2.enable = true;
  # Gives Thunar the GVFS D-Bus/GIO backends needed for SFTP locations.
  services.gvfs.enable = true;

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.yoran = {
    isNormalUser = true;
    description = "yoran";
    extraGroups = [ "networkmanager" "wheel" "docker" "disk" ];
    packages = with pkgs; [ ];
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

  environment.sessionVariables = {
    GTK_THEME = "Gruvbox-Dark";
    NIXOS_OZONE_WL = "1";
  };
}
