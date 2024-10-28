{
  description = "Voting System";

  inputs = {
    nix-idris2-packages = {
      type = "github";
      owner = "mattpolzin";
      repo = "nix-idris2-packages";
      ref = "main";
    };
  };

  outputs = { self, nix-idris2-packages }:
    let
      nixpkgs = nix-idris2-packages.inputs.nixpkgs;
      lib = nixpkgs.lib;
      forEachSystem =
        f:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          f {
            inherit system;
            inherit (nix-idris2-packages.packages.${system}) idris2 idris2Lsp;
            idris2Packages = nix-idris2-packages.idris2Packages.${system};
            buildIdris = nix-idris2-packages.buildIdris.${system};
            buildIdris' = nix-idris2-packages.buildIdris'.${system};
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forEachSystem (
        { buildIdris, ... }:
        let
          # if you have 'allow-import-from-derivation' set true then you could
          # also use buildIdris' here and not specify `idrisLibraries`
          # explicitly.
          myPkg = buildIdris {
            ipkgName = "voting";
            src = ./.;
            idrisLibraries = [];
          };
        in
        {
          default = myPkg.executable;
        }
      );

      devShells = forEachSystem (
        {
          system,
          pkgs,
          idris2,
          idris2Lsp,
          ...
        }:
        {
          default = pkgs.mkShell {
            packages = [
              idris2
              idris2Lsp
              pkgs.rlwrap
            ];
            inputsFrom = [ self.packages.${system}.default ];
          };
        }
      );
    };
}
