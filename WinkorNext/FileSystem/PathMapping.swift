//
//  PathMapping.swift
//  WinkorNext
//
//  Winlator-style path mapping: iOS file paths ↔ Windows-style paths (C:\...).
//

import Foundation

/// Winlator-style mapping between iOS paths and Windows paths (e.g. drive_c → C:\).
public enum PathMapping {

    /// Windows C: drive prefix.
    public static let windowsDriveC = "C:\\"

    /// Converts an iOS file URL to a Windows path if it is under the virtual drive_c.
    /// - Parameter url: An iOS URL (e.g. .../WinkorNext/drive_c/users/Downloads/game.exe).
    /// - Returns: Windows path like `C:\users\Downloads\game.exe`, or nil if not under drive_c.
    public static func windowsPath(fromIOS url: URL, driveCRoot: URL) -> String? {
        let resolved = url.resolvingSymlinksInPath()
        let driveCRootResolved = driveCRoot.resolvingSymlinksInPath()
        guard resolved.path.hasPrefix(driveCRootResolved.path) else { return nil }
        let relative = resolved.path.dropFirst(driveCRootResolved.path.count)
        let trimmed = relative.hasPrefix("/") ? relative.dropFirst(1) : relative
        let windows = String(trimmed).replacingOccurrences(of: "/", with: "\\")
        return windowsDriveC + windows
    }

    /// Converts an iOS path string to a Windows path if under the given drive_c root.
    public static func windowsPath(fromIOSPath path: String, driveCRoot: URL) -> String? {
        windowsPath(fromIOS: URL(fileURLWithPath: path), driveCRoot: driveCRoot)
    }

    /// Converts a Windows path (e.g. C:\users\Downloads\game.exe) to an iOS file URL under the given drive_c root.
    /// - Parameters:
    ///   - windowsPath: Path like `C:\users\Downloads\game.exe` or `C:/users/Downloads/game.exe`.
    ///   - driveCRoot: The iOS URL for drive_c (e.g. .../WinkorNext/drive_c).
    /// - Returns: iOS file URL, or nil if the path is not on C:\.
    public static func iosURL(fromWindowsPath windowsPath: String, driveCRoot: URL) -> URL? {
        let normalized = windowsPath
            .replacingOccurrences(of: "\\", with: "/")
            .trimmingCharacters(in: .whitespaces)
        let prefix = normalized.uppercased()
        guard prefix.hasPrefix("C:/") || prefix.hasPrefix("C:\\") else { return nil }
        let dropCount = prefix.hasPrefix("C:/") ? 3 : 3
        let relative = String(normalized.dropFirst(dropCount))
        let components = relative.split(separator: "/").map(String.init)
        var url = driveCRoot
        for component in components where !component.isEmpty {
            url = url.appendingPathComponent(component, isDirectory: false)
        }
        return url
    }
}
