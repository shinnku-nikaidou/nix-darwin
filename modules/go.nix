{ pkgs, goToolchain, ... }:
{
  environment.systemPackages = [
    goToolchain
  ];

  environment.variables.GOPATH = "$HOME/go";
}
