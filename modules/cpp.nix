{ pkgs, ... }:

let
  # Unified LLVM 20 toolchain
  llvm20 = pkgs.llvmPackages_20;
  clang20Stdenv = llvm20.stdenv;

  # Ensure all libraries are compiled with the same clang++ 20
  gmpWithClang = pkgs.gmp.override { stdenv = clang20Stdenv; };
  boostWithClang = pkgs.boost.override { stdenv = clang20Stdenv; };
in
{
  environment.systemPackages = with pkgs; [
    # LLVM 20 complete toolchain
    llvm20.libcxxClang # Compiler (clang/clang++)
    llvm20.clang-tools # Development tools (clangd, clang-format, clang-tidy, etc.)
    llvm20.llvm # LLVM core tools
    llvm20.lldb # Debugger
    llvm20.libcxx # C++ standard library

    # Libraries compiled with unified clang++ 20
    gmpWithClang
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

    # Ensure we use Nix's libc++ but system libc
    CPLUS_INCLUDE_PATH = "${llvm20.libcxx.dev}/include/c++/v1:${gmpWithClang.dev}/include:${boostWithClang.dev}/include";
    C_INCLUDE_PATH = "${gmpWithClang.dev}/include";
    
    # Add library search paths
    LIBRARY_PATH = "${llvm20.libcxx}/lib:${gmpWithClang}/lib:${boostWithClang}/lib";
    LD_LIBRARY_PATH = "${llvm20.libcxx}/lib:${gmpWithClang}/lib:${boostWithClang}/lib";

    # pkg-config paths
    PKG_CONFIG_PATH = "${gmpWithClang}/lib/pkgconfig:${boostWithClang}/lib/pkgconfig";

    # Compiler flags to use Nix libc++ but avoid system header conflicts
    CXXFLAGS = "-stdlib=libc++ -nostdinc++ -isystem ${llvm20.libcxx.dev}/include/c++/v1 -isystem ${gmpWithClang.dev}/include -isystem ${boostWithClang.dev}/include";
    LDFLAGS = "-L${llvm20.libcxx}/lib -L${gmpWithClang}/lib -L${boostWithClang}/lib -lc++ -lc++abi -Wl,-rpath,${llvm20.libcxx}/lib -Wl,-rpath,${gmpWithClang}/lib -Wl,-rpath,${boostWithClang}/lib";

  };
}
