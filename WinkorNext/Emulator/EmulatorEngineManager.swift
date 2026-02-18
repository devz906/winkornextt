//
//  EmulatorEngineManager.swift
//  WinkorNext
//
//  Core Emulator Brain: Manager to launch the future hybrid Box64 + Wine engine.
//  Targets A18 Pro 16KB page size and enables DYNAREC for Winlator-level performance.
//

import Foundation

/// Environment keys required for A18 Pro (16KB page size) and Box64 DYNAREC.
/// These must be set before any Box64/Wine process is launched.
public enum Box64Environment {
    /// Mandatory for iPhone 16 Pro (A18 Pro) — 16KB page size architecture.
    /// Without this, standard emulators fail on 16 Pro.
    public static let page16K = "BOX64_PAGE16K"
    public static let page16KValue = "1"

    /// Enable dynamic recompilation. Without this, Box64 would be ~10x slower.
    public static let dynarec = "BOX64_DYNAREC"
    public static let dynarecValue = "1"
}

/// MoltenVK / Metal configuration for Vulkan→Metal translation (A18 Pro GPU).
public enum MoltenVKEnvironment {
    /// Use Metal Argument Buffers for maximum A18 Pro GPU throughput.
    public static let useMetalArgumentBuffers = "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS"
    public static let useMetalArgumentBuffersValue = "1"
}

/// Core Emulator Brain: launches and configures the hybrid Box64 + Wine engine.
public final class EmulatorEngineManager {

    public static let shared = EmulatorEngineManager()

    /// Path to the engine binary (e.g. winkor_engine). Nil until you add the binary.
    private var engineBinaryPath: String?

    /// Directory where Windows game files and Wine prefix will live.
    public var containerRoot: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("WinkorNext", isDirectory: true)
    }

    /// Engine binary name used by the build system and placeholder check.
    public static let engineBinaryName = "winkor_engine"

    private init() {
        resolveEnginePath()
    }

    /// Resolves path to winkor_engine if present in the app bundle or container.
    private func resolveEnginePath() {
        // 1) Bundle resource (e.g. Engine/winkor_engine)
        if let inBundle = Bundle.main.path(
            forResource: Self.engineBinaryName,
            ofType: nil,
            inDirectory: "Engine"
        ) {
            engineBinaryPath = inBundle
            return
        }
        // 2) Flat in bundle
        if let inBundle = Bundle.main.path(forResource: Self.engineBinaryName, ofType: nil) {
            engineBinaryPath = inBundle
            return
        }
        // 3) Container (e.g. after copying from Documents)
        let inContainer = containerRoot
            .appendingPathComponent(Self.engineBinaryName, isDirectory: false)
            .path
        if FileManager.default.fileExists(atPath: inContainer) {
            engineBinaryPath = inContainer
        }
    }

    /// Returns whether the engine binary is present (for placeholder / CI checks).
    public var hasEngineBinary: Bool {
        if let path = engineBinaryPath {
            return FileManager.default.isExecutableFile(atPath: path)
        }
        return false
    }

    /// Builds the environment for Box64 + Wine: A18 Pro 16KB page size + DYNAREC + MoltenVK Metal Argument Buffers.
    public func emulatorLaunchEnvironment() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        // A18 Pro: 16KB page size — mandatory for Winlator-level performance on this hardware.
        env[Box64Environment.page16K] = Box64Environment.page16KValue
        env[Box64Environment.dynarec] = Box64Environment.dynarecValue
        // Vulkan → Metal: Argument Buffers for maximum A18 Pro GPU throughput.
        env[MoltenVKEnvironment.useMetalArgumentBuffers] = MoltenVKEnvironment.useMetalArgumentBuffersValue
        return env
    }

    /// Prepares and launches the hybrid engine. Fails gracefully if binary is missing (placeholder-friendly).
    /// - Parameter arguments: Arguments to pass to the engine (e.g. path to exe, Wine prefix).
    /// - Returns: Process handle if launched; nil if binary missing or launch failed.
    public func launchEngine(arguments: [String] = []) -> Process? {
        guard let path = engineBinaryPath, hasEngineBinary else {
            return nil
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.environment = emulatorLaunchEnvironment()
        process.currentDirectoryURL = URL(fileURLWithPath: (path as NSString).deletingLastPathComponent)
        do {
            try process.run()
            return process
        } catch {
            return nil
        }
    }

    /// Ensures container directory exists (for Wine prefix and game files).
    public func ensureContainerExists() throws {
        try FileManager.default.createDirectory(at: containerRoot, withIntermediateDirectories: true)
    }
}
