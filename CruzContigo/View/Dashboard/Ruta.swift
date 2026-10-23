//
//  Ruta.swift
//  CruzContigo
//

import SwiftUI

enum Ruta: Hashable {
    case agregarFamiliar
    case familiar(UUID)
    case elegirFamiliar(Modulo)
    case modulo(Modulo, familiarID: UUID?)
}

extension View {
    func conDestinos() -> some View {
        navigationDestination(for: Ruta.self) { ruta in
            Group {
                switch ruta {
                case .agregarFamiliar:
                    AltaPersonaView()
                case .familiar(let id):
                    FamiliarDetailView(familiarID: id)
                case .elegirFamiliar(let modulo):
                    ElegirFamiliarView(modulo: modulo)
                case .modulo(let modulo, let familiarID):
                    ModuloDestino(modulo: modulo, familiarID: familiarID)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

struct ModuloDestino: View {
    let modulo: Modulo
    let familiarID: UUID?

    var body: some View {
        switch modulo {
        default:
            ModuloPendienteView(modulo: modulo, familiarID: familiarID)
        }
    }
}
