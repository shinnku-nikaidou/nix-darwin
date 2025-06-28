{ pkgs, ... }:

let
  pythonEnv = pkgs.python312.withPackages (
    ps: with ps; [
      numpy
      pandas
      matplotlib
      scikit-learn
      sympy
      ps.torch
      ps.torchvision
      ps.torchaudio
    ]
  );
in
{
  environment.systemPackages = [
    pythonEnv
    pkgs.python312Packages.pip
    pkgs.python312Packages.virtualenv
  ];
}
