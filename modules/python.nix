{ pkgs, ... }:

let
  pythonEnv = pkgs.python313.withPackages (
    ps: with ps; [
      numpy
      pandas
      matplotlib
      scikit-learn
      sympy
      uvicorn
      falcon
      flask
      fastapi
      requests
      httpx
      ipython
      black

      # pytorch
      ps.torch
      ps.torchvision
      ps.torchaudio
      tensorboardx

      # large language models
      sentence-transformers
      transformers

      #  langchain
      langchain
      langchain-community
      langchain-chroma
      langchain-openai
      langchain-ollama
      langchain-huggingface # it will compile fail due to issue: https://github.com/pytorch/pytorch/issues/150121

      # google
      google-genai
      google-generativeai
    ]
  );
in
{
  environment.systemPackages = [
    pythonEnv
    pkgs.python313Packages.pip
    pkgs.python313Packages.virtualenv
  ];
}
