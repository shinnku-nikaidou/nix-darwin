{ pkgs, ... }:

let
  hp = pkgs.haskell.packages.ghc98;

  myPackages = hp.ghcWithPackages (
    hs: with hs; [
      haskell-language-server

      # Core data structures and text processing
      text
      bytestring
      containers
      vector
      unordered-containers

      # JSON and serialization
      aeson
      aeson-pretty
      yaml
      binary
      cereal

      # HTTP and networking
      http-client
      http-client-tls
      http-types
      servant
      servant-server
      servant-client
      warp
      wreq

      # Parsing and regex
      parsec
      megaparsec
      attoparsec
      regex-pcre

      # Concurrency and parallelism
      async
      stm
      parallel

      # File system and IO
      directory
      filepath
      temporary
      unix

      # Testing
      hspec
      QuickCheck
      tasty
      tasty-hspec
      tasty-quickcheck

      # Utility libraries
      mtl
      transformers
      lens
      optparse-applicative
      time
      random
      split
      extra
      safe

      # Database
      sqlite-simple
      postgresql-simple

      # Logging and debugging
      monad-logger
      pretty-simple

      # Streaming
      conduit
      pipes
      streaming
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
    # hp.haskell-language-server
  ];

  environment.variables.STACK_ROOT = "$HOME/.stack";
}
