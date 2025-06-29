{ pkgs, ... }:

let
  hp = pkgs.haskell.packages.ghc98;

  myPackages = hp.ghcWithPackages (
    hs: with hs; [
      text
      bytestring
      containers
      vector
      unordered-containers
      aeson
    ]
  );

in
{
  environment.systemPackages = [
    myPackages
    hp.cabal-install
    hp.stack
    hp.hoogle
    hp.stylish-haskell
  ];

  environment.variables.STACK_ROOT = "$HOME/.stack";
}
