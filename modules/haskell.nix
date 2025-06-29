{ pkgs, ... }:

let
  ghcVersion = pkgs.haskell.compiler.ghc98;
  hp = pkgs.haskell.packages.${ghcVersion};

  myPackages = hp.ghcWithPackages (
    hs: with hs; [
      text
      bytestring
      containers
      vector
      unordered-containers
      aeson
      hdr-json
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
