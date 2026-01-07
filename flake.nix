{
  description = "Phattaraphan's NixOS Flake";

  inputs = {
    # Using the same version as your stateVersion
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # imports hardware detection
        ./hardware-configuration.nix
        
        # imports configuration file
        ./configuration.nix
      ];
    };
  };
}
