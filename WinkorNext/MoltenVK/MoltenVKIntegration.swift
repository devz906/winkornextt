//
//  MoltenVKIntegration.swift
//  WinkorNext
//
//  Vulkan to Metal Heart: Integration point for translating Vulkan commands
//  from Windows games into Apple's Metal API. Configured for Metal Argument
//  Buffers for maximum A18 Pro GPU throughput.
//

import Foundation

/// Central configuration for MoltenVK (Vulkan → Metal) used by the emulator shell.
public enum MoltenVKIntegration {

    /// Environment key to enable Metal Argument Buffers (recommended for A18 Pro).
    public static let metalArgumentBuffersEnvKey = "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS"

    /// Value to enable Metal Argument Buffers.
    public static let metalArgumentBuffersEnabled = "1"

    /// Builds the subset of environment variables that MoltenVK will read.
    /// Caller should merge this into the full launch environment (e.g. EmulatorEngineManager).
    public static func metalEnvironmentAdditions() -> [String: String] {
        [
            metalArgumentBuffersEnvKey: metalArgumentBuffersEnabled
        ]
    }

    /// Returns true if the current process/env is configured for Metal Argument Buffers.
    public static var isMetalArgumentBuffersConfigured: Bool {
        ProcessInfo.processInfo.environment[metalArgumentBuffersEnvKey] == metalArgumentBuffersEnabled
    }
}
