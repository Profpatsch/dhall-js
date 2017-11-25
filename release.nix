let nixpkgsSrc = (import <nixpkgs> {}).fetchFromGitHub {
      owner = "Profpatsch";
      repo = "nixpkgs";
      rev = "9ea1db72d66cfa0f617c01b69e9c8f732b55dd6f";
      sha256 = "0lxa19gnsinip4ky9b647bj8mns5ngqzcxw63ff2qyn0x65qqv5q";
    };
in (import nixpkgsSrc {
  overlays = [(self: super:
    let
      functionize = name: js: super.runCommand name {} ''
        echo "(function(global) {" > $out
        cat ${js} >> $out
        echo "})(typeof global !== 'undefined' ? global : this);" >> $out
      '';

      ghcjs = self.haskell.packages.ghcjsHEAD.ghcWithPackages
        (hp: [ hp.ghcjs-base hp.dhall-json ]);

      compileFileBrowser = name: file: super.runCommand name {} ''
        cp ${file} ./Main.hs
        # TODO: -DGHCJS_BROWSER ?
        ${ghcjs}/bin/ghcjs ./Main.hs
        mkdir $out
        cp Main.jsexe/* $out/
      '';

    in {
      export = let comp = compileFileBrowser "Main" ./Main.hs; in {
        orig = super.runCommand "export-test" {} ''
          # goog.{require,provide} are erroring,
          # they want to be in their own module files.
          # since we use all.js (which concats everything together),
          # they can be removed.
          sed -e "/goog\.require(/ d" \
              -e "/goog\.provide(/ d" \
            ${functionize "all.js" "${comp}/all.js"} \
            > $out
        '';
        small = super.runCommand "export-test-small" {} ''
          # jscomp_warning to turn some errors into warnings.
          # Hope, send thoughts & prayers it still works.
          ${self.closurecompiler}/bin/closure-compiler \
            --compilation_level=ADVANCED \
            --externs=${comp}/all.js.externs \
            --jscomp_warning=duplicate \
            --jscomp_warning=undefinedVars \
            ${self.export.orig} \
            > $out
        '';
      };
    }
  )];
}).export
