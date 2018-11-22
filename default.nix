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
      rev = "bdcd9f3ed7db539163eb7b3d9bd0c27e543163d7";
      sha256 = "1pai4x3q82z2nkc7cqv8q15n2n71mam4g357ix1g0ma9zpq8mfjw";
    });

  };

  modifiedHaskellPackages = haskellPackages.override {
    overrides = self: super: {
      # hedgehog       = self.callHackage "hedgehog" "0.6" {};
      # tasty-hedgehog = self.callHackage "tasty-hedgehog" "0.2.0.0" {};
      # polyparse = self.callHackage "polyparse" "1.12.1" {};
      exitcode = super.callPackage sources.exitcode {};
    };
  };

  exitcode-process = modifiedHaskellPackages.callPackage ./exitcode-process.nix {};
in
  exitcode-process
