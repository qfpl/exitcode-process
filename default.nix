{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:
let
  inherit (nixpkgs) pkgs;
  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  tasty-hedgehog-github = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "qfpl";
    repo = "tasty-hedgehog";
    rev = "5da389f5534943b430300a213c5ffb5d0e13459e";
    sha256 = "04pmr9q70gakd327sywpxr7qp8jnl3b0y2sqxxxcj6zj2q45q38m";
  }) {};

  sources = {

    exitcode = (pkgs.fetchFromGitHub {
      owner = "qfpl";
      repo = "exitcode";
      rev = "dc2f8e44d8e918dd20636e4a65bde7dd3ff73ae8";
      sha256 = "1llynvjdhiz19s8ax1nzzmpq4xg6s76xlz5yglyszqw8zqc12p24";
    });

  };

  modifiedHaskellPackages = haskellPackages.override {
    overrides = self: super: {
      tasty-hedgehog =
        if super ? tasty-hedgehog
        then super.tasty-hedgehog
        else tasty-hedgehog-github;
      exitcode = super.callPackage sources.exitcode {};
    };
  };

  exitcode-process = modifiedHaskellPackages.callPackage ./exitcode-process.nix {};
in
  exitcode-process
