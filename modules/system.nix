{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://zed.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
    ];
  };

  services.xserver.enable = true;
  programs.niri.enable = true;
  programs.steam.enable = true;
  programs.xwayland.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "niri";
  xdg.portal.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
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
