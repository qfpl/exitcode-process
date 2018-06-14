{ mkDerivation, base, checkers, exitcode, hedgehog, lens
, QuickCheck, stdenv, tasty, tasty-hedgehog, tasty-hunit
, tasty-quickcheck, transformers
}:
mkDerivation {
  pname = "exitcode-process";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [ base exitcode ];
  testHaskellDepends = [
    base checkers hedgehog lens QuickCheck tasty tasty-hedgehog
    tasty-hunit tasty-quickcheck transformers
  ];
  homepage = "https://github.com/qfpl/exitcode-process";
  description = "A process library that uses the `exitcode` package";
  license = stdenv.lib.licenses.bsd3;
}
