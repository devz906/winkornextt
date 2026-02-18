//
//  FileSystemManager.swift
//  WinkorNext
//
//  Phase 2: The Nervous System — Virtual Windows environment for iOS 26.2.
//  Maps app storage to Wine's expected structure and creates the virtual C: drive.
//

import Foundation

/// Manages the virtual Windows (Wine) file system in the app's Documents folder.
/// Creates the required Wine directory structure on first launch (self-healing).
public final class FileSystemManager {

    public static let shared = FileSystemManager()

    private let fileManager = FileManager.default

    /// Root container (same as EmulatorEngineManager). Visible in Files app when File Sharing is enabled.
    public var containerRoot: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("WinkorNext", isDirectory: true)
    }

    /// Virtual C: drive root — Wine expects this.
    public var driveC: URL {
        containerRoot.appendingPathComponent("drive_c", isDirectory: true)
    }

    /// Windows system directory.
    public var windowsDir: URL {
        driveC.appendingPathComponent("windows", isDirectory: true)
    }

    /// Program Files (Winlator-style).
    public var programFiles: URL {
        driveC.appendingPathComponent("users", isDirectory: true).appendingPathComponent("Program Files", isDirectory: true)
    }

    /// Downloads — bridge for iOS Files app. User drags games here from PC; Wine can use as D: or Downloads.
    public var downloads: URL {
        driveC.appendingPathComponent("users", isDirectory: true).appendingPathComponent("Downloads", isDirectory: true)
    }

    /// Home directory for the engine (Box64/Wine). .box64rc is placed here.
    public var engineHome: URL {
        containerRoot
    }

    /// Hidden Box64 config file name.
    public static let box64rcFileName = ".box64rc"

    public var box64rcURL: URL {
        engineHome.appendingPathComponent(Self.box64rcFileName, isDirectory: false)
    }

    private init() {}

    // MARK: - Virtual C: Drive Setup

    /// Creates the full Wine directory structure if missing. Call on first launch for a self-healing C: drive.
    public func ensureWineStructure() throws {
        try fileManager.createDirectory(at: containerRoot, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: driveC, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: windowsDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: driveC.appendingPathComponent("users", isDirectory: true), withIntermediateDirectories: true)
        try fileManager.createDirectory(at: programFiles, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: downloads, withIntermediateDirectories: true)
        try ensureBox64rc()
    }

    /// Writes or updates the hidden .box64rc with A18 Pro optimizations so the engine remembers them.
    public func ensureBox64rc() throws {
        let content = """
        # WinkorNext — A18 Pro (iPhone 16 Pro) optimizations
        # 16KB page size and DYNAREC for Winlator-level performance
        BOX64_PAGE16K=1
        BOX64_DYNAREC=1
        """
        try content.write(to: box64rcURL, atomically: true, encoding: .utf8)
        try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: box64rcURL.path)
    }

    /// Returns true if the Wine structure (drive_c) already exists.
    public var hasWineStructure: Bool {
        fileManager.fileExists(atPath: driveC.path)
    }
}
