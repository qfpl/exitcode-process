{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:
let
  inherit (nixpkgs) pkgs;
  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  sources = {

    exitcode = (pkgs.fetchFromGitHub {
      owner = "qfpl";
      repo = "exitcode";
      rev = "bc31d0de9bd4886b912e03bdfa4a6c262b35fbf8";
      sha256 = "08vi4j77vfv6k1dnwfrvvrg9dzijk3c7iynw9k5d6wxb5chk9xhy";
    });

  };

  modifiedHaskellPackages = haskellPackages.override {
    overrides = self: super: {
      hedgehog       = self.callHackage "hedgehog" "0.6" {};
      tasty-hedgehog = self.callHackage "tasty-hedgehog" "0.2.0.0" {};
      polyparse = self.callHackage "polyparse" "1.12.1" {};
      concurrent-output = pkgs.haskell.lib.doJailbreak super.concurrent-output;
      exitcode = super.callPackage sources.exitcode { inherit nixpkgs compiler; };
    };
  };

  exitcode-process = modifiedHaskellPackages.callPackage ./exitcode-process.nix {};
in
  exitcode-process
