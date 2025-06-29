{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # c++
    gcc
    clang-tools
    llvm
    boost
    gmp
    cmake
    gdb
    make
    ccls
  ];
}
