((import <nixpkgs> {}).haskell.packages.ghcjsHEAD.override {
  overrides = self: super: {
        my-pkg = let
          buildDepends = with self; [
            ghcjs-base
            dhall-json
          ];
          in super.mkDerivation {
            pname = "pkg-env";
            src = "/dev/null";
            version = "none";
            license = "none";
            inherit buildDepends;
            buildTools = with self; [
              ghcid
              cabal-install
              hpack
              hscolour
              (hoogleLocal {
                packages = buildDepends;
              })
            ];
          };
      };
}).my-pkg.env
