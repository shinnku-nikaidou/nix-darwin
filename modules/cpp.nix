{ pkgs, ... }:

let
  # Unified LLVM 20 toolchain
  llvm20 = pkgs.llvmPackages_20;
  clang20Stdenv = llvm20.stdenv;

  # Ensure all libraries are compiled with the same clang++ 20
  gmpWithClang = pkgs.gmp.override { stdenv = clang20Stdenv; };
  gmpxxWithClang = pkgs.gmpxx.override { stdenv = clang20Stdenv; };
  boostWithClang = pkgs.boost.override { stdenv = clang20Stdenv; };
in
{
  environment.systemPackages = with pkgs; [
    # LLVM 20 complete toolchain
    llvm20.libcxxClang # Compiler (clang/clang++)
    llvm20.clang-tools # Development tools (clangd, clang-format, clang-tidy, etc.)
    llvm20.llvm # LLVM core tools
    llvm20.lldb # Debugger

    # Libraries compiled with unified clang++ 20
    gmpWithClang
    gmpxxWithClang
    boostWithClang

    # Build tools
    cmake
    ninja
    pkg-config

    # Optional debugging tools
    gdb
  ];

  # Set environment variables to ensure correct compiler usage
  environment.variables = {
    CC = "${llvm20.libcxxClang}/bin/clang";
    CXX = "${llvm20.libcxxClang}/bin/clang++";
  };
}
