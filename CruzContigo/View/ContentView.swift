//
//  ContentView.swift
//  CruzContigo
//

import SwiftUI

struct ContentView: View {
    @State private var familiaresStore = FamiliaresStore()

    var body: some View {
        DashboardView()
            .environment(familiaresStore)
    }
}

#Preview {
    ContentView()
}
