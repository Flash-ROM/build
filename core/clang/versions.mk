## Clang/LLVM release versions.

LLVM_RELEASE_VERSION := 3.8
LLVM_PREBUILTS_VERSION ?= clang-2690385
LLVM_PREBUILTS_BASE ?= prebuilts/clang/host

## Configure SnapDragon Clang

SDCLANG := true
SDCLANG_PATH := prebuilts/clang/host/linux-x86/sdclang-3.8/bin
SDCLANG_LTO_DEFS := build/core/sdllvm-lto-defs.mk
