{ mkDerivation, base, checkers, deriving-compat, exitcode, hedgehog
, lens, QuickCheck, semigroupoids, stdenv, tasty, tasty-hedgehog
, tasty-hunit, tasty-quickcheck, transformers, witherable
}:
mkDerivation {
  pname = "exitcode-process";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base deriving-compat exitcode lens semigroupoids witherable
  ];
  testHaskellDepends = [
    base checkers hedgehog lens QuickCheck tasty tasty-hedgehog
    tasty-hunit tasty-quickcheck transformers
  ];
  homepage = "https://github.com/qfpl/exitcode-process";
  description = "A process library that uses the `exitcode` package";
  license = stdenv.lib.licenses.bsd3;
}
