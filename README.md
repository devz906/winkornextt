# WinkorNext

**Winlator equivalent for iOS 26.2** — optimized for **iPhone 16 Pro (A18 Pro)**.

WinkorNext is a Logic Shell and app harness for a future hybrid **Box64 + Wine** engine, with Vulkan→Metal translation via MoltenVK and entitlements tuned for JIT and full 8GB RAM on iOS 26.2.

## Architecture

- **Core Emulator Brain**: Manager to launch the hybrid Box64/Wine engine with A18 Pro–specific env (`BOX64_PAGE16K=1`, `BOX64_DYNAREC=1`).
- **Vulkan to Metal Heart**: MoltenVK integration with Metal Argument Buffers for maximum A18 Pro GPU throughput.
- **Hardware Unlock**: JIT and Increased Memory Limit entitlements for iOS 26.2.

## Requirements

- **No Xcode required locally.** The app is built on GitHub Actions.
- Runner: macOS with Xcode (iOS 26.2 SDK when available).
- Target: iPhone 16 Pro (A18 Pro) — 16KB page size support.

## Build

- **GitHub**: Push to `main` or `master`, or run the **Build** workflow manually.  
  `.github/workflows/build.yml` uses **XcodeGen** to generate the Xcode project, then builds and produces an **unsigned IPA** artifact (`WinkorNext-unsigned-ipa`).
- **Placeholder**: The build stays green even when the `winkor_engine` binary is missing; add it under `WinkorNext/Engine/` when ready.

## License

See LICENSE file.
