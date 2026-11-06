{ pkgs, inputs, username, ... }:

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
  networking.firewall = {
    enable = true;
    interfaces.tailscale0 = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 ];
    };
  };
  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}/Documents";
    configDir = "/home/${username}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = false;
  };
  hardware.bluetooth = {
    enable = true;
    # Keep the adapter available for manual use without powering it on at boot.
    powerOnBoot = false;
  };
  zramSwap.enable = true;

  # Kill the largest eligible workload before the kernel OOM killer destabilizes
  # the graphical session. Do not run systemd-oomd alongside earlyoom.
  systemd.oomd.enable = false;
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 8;
    freeSwapThreshold = 15;
    reportInterval = 300;
    extraArgs = [
      # Niri resets OOMScoreAdjust after startup, so use earlyoom's own
      # supported candidate filter to preserve the compositor.
      "--avoid"
      "^niri$"
    ];
  };

  services.systemd-lock-handler.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
    randomizedDelaySec = "45min";
  };
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

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };

  environment.pathsToLink = [
    "/share/icons"
    "/share/themes"
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
