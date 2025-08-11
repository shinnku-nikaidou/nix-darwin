{
  description = "shinnku's macbook pro nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [];
      };

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
                parquet-tools

                clang-tools
                # cmake
                # ninja

                htop
                btop
                fastfetch

                unar
                p7zip

                nodejs
                pnpm
                yarn
                bun

                ffmpeg-full
                iperf

                gemini-cli
                claude-code

                texliveFull

                # For development
                uv
                jdk24
                ocaml
                php
              ];
            }
          )
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.go
          pkgs.gopls
          pkgs.gotools
          pkgs.delve
        ];
        GOPATH = "$HOME/go";
      };
    };
}
