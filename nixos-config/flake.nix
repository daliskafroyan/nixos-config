{
  description = "yoran NixOS configuration with Noctalia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    noctalia.url = "github:noctalia-dev/noctalia";
    helium-browser.url = "github:oxcl/nix-flake-helium-browser";
  };

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
