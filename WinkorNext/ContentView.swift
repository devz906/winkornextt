//
//  ContentView.swift
//  WinkorNext
//

import SwiftUI

struct ContentView: View {
    @State private var engineReady = EmulatorEngineManager.shared.hasEngineBinary

    var body: some View {
        VStack(spacing: 16) {
            Text("WinkorNext")
                .font(.title)
            Text("Winlator for iOS 26.2 · A18 Pro")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(engineReady ? "Engine binary present" : "Engine placeholder — add winkor_engine when ready")
                .font(.caption)
                .foregroundStyle(engineReady ? .green : .orange)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
