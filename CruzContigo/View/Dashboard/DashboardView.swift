//
//  DashboardView.swift
//  CruzContigo
//

import SwiftUI

struct DashboardView: View {
    @Environment(FamiliaresStore.self) private var store
    @State private var ruta: [Ruta] = []

    private let columnas = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack(path: $ruta) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    seccionFamiliares
                    seccionModulos
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .refreshable { await store.cargar() }
            .toolbar(.hidden, for: .navigationBar)
            .conDestinos()
        }
        .tint(.brandRed)
        .task {
            if store.estado == .inicial { await store.cargar() }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(saludo)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text("Cruz\(Text("Contigo").foregroundColor(.brandRed))")
                    .font(.title).fontWeight(.bold)
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.brandRed)
                    .frame(width: 48, height: 48)
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)
        }
    }

    private var saludo: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: "Buenos días"
        case 12..<19: "Buenas tardes"
        default: "Buenas noches"
        }
    }

    private var seccionFamiliares: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Personas a tu cuidado")
                        .font(.title3)
                        .fontWeight(.bold)
                    if !store.familiares.isEmpty {
                        Text("\(store.familiares.count) registrada\(store.familiares.count == 1 ? "" : "s")")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if !store.familiares.isEmpty {
                    NavigationLink(value: Ruta.agregarFamiliar) {
                        Label("Agregar", systemImage: "plus")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.brandRed)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.brandRed.opacity(0.08)))
                    }
                }
            }

            contenidoFamiliares
        }
    }

    @ViewBuilder
    private var contenidoFamiliares: some View {
        switch store.estado {
        case .inicial:
            cargando
        case .cargando where store.familiares.isEmpty:
            cargando
        case .error(let mensaje) where store.familiares.isEmpty:
            EstadoErrorView(mensaje: mensaje) {
                Task { await store.cargar() }
            }
        default:
            listaFamiliares
        }
    }

    private var cargando: some View {
        HStack {
            Spacer()
            ProgressView("Cargando familiares…")
            Spacer()
        }
        .padding(.vertical, 32)
    }

    @ViewBuilder
    private var listaFamiliares: some View {
        if store.familiares.isEmpty {
            EstadoVacioFamiliares {
                ruta.append(.agregarFamiliar)
            }
        } else {
            VStack(spacing: 12) {
                ForEach(store.familiares) { familiar in
                    NavigationLink(value: Ruta.familiar(familiar.id)) {
                        FamiliarCard(familiar: familiar)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var seccionModulos: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Módulos")
                .font(.title3)
                .fontWeight(.bold)

            LazyVGrid(columns: columnas, spacing: 12) {
                ForEach(Modulo.allCases) { modulo in
                    Button {
                        abrir(modulo)
                    } label: {
                        ModuloCard(modulo: modulo)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func abrir(_ modulo: Modulo) {
        guard modulo.esPorFamiliar else {
            ruta.append(.modulo(modulo, familiarID: nil))
            return
        }
        switch store.familiares.count {
        case 0: ruta.append(.agregarFamiliar)
        case 1: ruta.append(.modulo(modulo, familiarID: store.familiares[0].id))
        default: ruta.append(.elegirFamiliar(modulo))
        }
    }
}

struct EstadoVacioFamiliares: View {
    let agregar: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.brandRed.opacity(0.08))
                    .frame(width: 88, height: 88)
                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 36))
                    .foregroundColor(.brandRed)
            }
            Text("Aún no agregas a nadie")
                .font(.headline)
            Text("Registra a la persona que cuidas para organizar su información médica, medicamentos y citas.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Agregar familiar", action: agregar)
                .padding(.top, 6)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderGray, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        )
    }
}

struct EstadoErrorView: View {
    let mensaje: String
    let reintentar: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 32))
                .foregroundColor(.brandRed)
            Text("No pudimos cargar la información")
                .font(.headline)
            Text(mensaje)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Reintentar", action: reintentar)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.brandRed)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DashboardView()
        .environment(FamiliaresStore())
}
