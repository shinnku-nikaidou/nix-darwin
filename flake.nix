{
  description = "shinnku's macbook pro nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix.url = "github:nix-community/fenix";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      fenix,
      nix-darwin,
      ...
    }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          fenix.overlays.default
          (final: prev: {
            python313 = prev.python313.override {
              packageOverrides = pyf: pyp: {
                accelerate = pyp.accelerate.overridePythonAttrs (_: {
                  doCheck = false;
                });
              };
            };
          })
        ];

      };

      rustToolchain = fenix.packages.${system}.complete.toolchain;

      baseModules = [
        {
          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [
              "root"
              "shinnkunikaidou"
            ];
          };

          nix.gc = {
            automatic = true;
            options = "--delete-older-than 14d";
          };

          nixpkgs = {
            hostPlatform = system;
            config.allowUnfree = true; # Also set it here for system packages
          };

          system.stateVersion = 6;
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
      ];
    in
    {
      darwinConfigurations."shinnkus-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        inherit system pkgs;
        modules = baseModules ++ [
          ./modules/python.nix
          ./modules/haskell.nix
          (
            { ... }:
            {
              environment.systemPackages = with pkgs; [
                vim
                nixfmt-rfc-style
                htop
                scrcpy
                nodejs_22
                pnpm
                ffmpeg-full
                iperf
                rustToolchain
                texliveFull
              ];

              environment.variables.RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
            }
          )
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ rustToolchain ];
        RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
      };
    };
}
