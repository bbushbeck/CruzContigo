//
//  ContentView.swift
//  CruzContigo
//

import SwiftUI

struct ContentView: View {
    @State private var familiaresStore = FamiliaresStore()
    @State private var preferencias = Preferencias.compartidas

    var body: some View {
        MainTabView()
            .environment(familiaresStore)
            .environment(preferencias)
            .aplicarPreferencias(preferencias)
            .environment(\.locale, Locale(identifier: "es_MX"))
    }
}

#Preview {
   // ContentView()
}
