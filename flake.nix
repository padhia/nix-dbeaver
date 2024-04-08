{
  description = "Nix flake to build dbeaver tool";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.default = pkgs.callPackage ./dbeaver.nix {};
    overlays.default = final: prev: { dbeaver = prev.callPackage ./dbeaver.nix {}; };
  };
}
