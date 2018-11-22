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
      rev = "28f57c842c8864542fde0efae8788ce7c2523fea";
      sha256 = "1v7aski1vvxxskg20xlgvgfvxv2yjyvdl3aszvvw0g6ak2jwgwsf";
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
