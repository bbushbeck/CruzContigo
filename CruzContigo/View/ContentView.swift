//
//  ContentView.swift
//  CruzContigo
//

import SwiftUI

struct ContentView: View {
    @State private var familiaresStore = FamiliaresStore()

    var body: some View {
        MainTabView()
            .environment(familiaresStore)
            .environment(\.locale, Locale(identifier: "es_MX"))
    }
}

#Preview {
    ContentView()
}
