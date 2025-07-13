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
          ./modules/go.nix
          (
            { ... }:
            {
              environment.systemPackages = with pkgs; [
                nixfmt-rfc-style
                helix
                vim
                rclone
                protobuf

                # clang-tools
                # cmake
                # ninja

                htop
                btop
                fastfetch

                unar
                p7zip

                scrcpy
                nodejs
                pnpm
                yarn
                bun

                ffmpeg-full
                iperf

                gemini-cli

                rustToolchain
                texliveFull

                # For development
                uv
                jdk24
                ocaml
                mono
                php
              ];

              environment.variables.RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
            }
          )
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          rustToolchain
          pkgs.go
          pkgs.gopls
          pkgs.gotools
          pkgs.delve
        ];
        RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        GOPATH = "$HOME/go";
      };
    };
}
