{ inputs, hostName, username, ... }:

let
  userHomeModule = ../../home + "/${username}.nix";
in
{
  imports = [
    ../../modules/system.nix
    ../../modules/fonts.nix
    ../../modules/packages.nix
    ../../modules/secrets.nix
    ../../modules/gtk.nix
  ];

  networking.hostName = hostName;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs hostName username; };
    users.${username} = import userHomeModule;
  };

  system.stateVersion = "25.11";
}
