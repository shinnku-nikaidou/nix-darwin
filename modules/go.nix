{ pkgs, ... }:
let
  goToolchain = pkgs.buildEnv {
    name = "go-toolchain";
    paths = with pkgs; [
      go
      gopls
      delve
    ];
  };
in
{
  environment.systemPackages = [ goToolchain ];

  environment.variables.GOPATH = "$HOME/go";
}
