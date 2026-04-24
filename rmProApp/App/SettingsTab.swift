//
//  SettingsTab.swift
//  rmProApp
//
//  Placeholder. Owns its own NavigationStack so future destinations
//  (force resync, logout, about, etc.) can slot in without touching
//  the other tabs.
//

import SwiftUI

enum SettingsDestination: Hashable {
    // No destinations yet.
}

struct SettingsTab: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("Settings")
                    .font(.title2.bold())
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Settings")
        }
    }
}
