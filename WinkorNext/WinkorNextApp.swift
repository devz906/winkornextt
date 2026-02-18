//
//  WinkorNextApp.swift
//  WinkorNext
//

import SwiftUI

@main
struct WinkorNextApp: App {
    init() {
        // Phase 2: Ensure virtual C: drive and .box64rc exist on first launch (self-healing).
        try? FileSystemManager.shared.ensureWineStructure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
