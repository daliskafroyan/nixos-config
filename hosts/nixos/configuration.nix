{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/fonts.nix
    ../../modules/packages.nix
    ../../modules/secrets.nix
    ../../modules/gtk.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.yoran = import ../../home/yoran.nix;
  };

  system.stateVersion = "25.11";
}
