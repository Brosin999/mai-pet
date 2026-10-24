{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Change to "aarch64-darwin" if you are on Mac ARM
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          nil
          nixfmt
          nixd
          statix
          deadnix
          typos
          git
        ];
      };
    };
}