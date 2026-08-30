{
  description = "Yoran's NixOS system and home configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia.url = "github:noctalia-dev/noctalia";
    helium-browser.url = "github:oxcl/nix-flake-helium-browser";
    zed.url = "github:zed-industries/zed";
    llm-agents.url = "github:numtide/llm-agents.nix";
    omp.url = "github:can1357/oh-my-pi";
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      username = "yoran";
      hostEntries = builtins.readDir ./hosts;
      hostNames = builtins.filter (name: hostEntries.${name} == "directory" && name != "common") (builtins.attrNames hostEntries);
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs hostName username; };
        modules = [
          { nixpkgs.hostPlatform = system; }
          (./hosts + "/${hostName}")
          inputs.sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
    in
    {
      nixosConfigurations = lib.genAttrs hostNames mkHost;
    };
}
