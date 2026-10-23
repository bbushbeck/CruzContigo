//
//  DashboardView.swift
//  CruzContigo
//

import SwiftUI

struct DashboardView: View {
    @Binding var pestana: Pestana

    @Environment(FamiliaresStore.self) private var store
    @Environment(\.dynamicTypeSize) private var tipo
    @AppStorage(ClavesApp.personaSeleccionada) private var seleccionID = ""
    @AppStorage(ClavesApp.primerosPasosOcultos) private var primerosPasosOcultos = false
    @State private var ruta: [Ruta] = []
    @State private var mostrarEmergencia = false

    private var seleccionada: Familiar? {
        store.familiares.first { $0.id.uuidString == seleccionID } ?? store.familiares.first
    }

    var body: some View {
        NavigationStack(path: $ruta) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    encabezado
                    saludo
                    seccionPersonas
                    Button { mostrarEmergencia = true } label: { EmergenciaCard() }
                        .buttonStyle(.plain)
                    if let seleccionada {
                        seccionAccesos(seleccionada)
                        if !primerosPasosOcultos {
                            PrimerosPasosView(
                                persona: seleccionada,
                                abrir: { ruta.append($0) },
                                ocultar: { withAnimation { primerosPasosOcultos = true } }
                            )
                        }
                        seccionRecordatorios
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .fondoBarraEstado()
            .refreshable { await store.cargar() }
            .toolbar(.hidden, for: .navigationBar)
            .conDestinos()
        }
        .task {
            if store.estado == .inicial { await store.cargar() }
        }
        .sheet(isPresented: $mostrarEmergencia) {
            EmergenciaSheet(persona: seleccionada) { modulo in
                mostrarEmergencia = false
                if let seleccionada {
                    ruta.append(.modulo(modulo, familiarID: seleccionada.id))
                } else {
                    ruta.append(.agregarFamiliar)
                }
            }
        }
    }

    private var encabezado: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brandRed)
                    .frame(width: 40, height: 40)
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text("Cruz\(Text("Contigo").foregroundColor(.brandRed))")
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if !tipo.isAccessibilitySize {
                    Text("Cuidar es estar juntos")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            Spacer()
            Button {
                pestana = .mas
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color(white: 0.95)))
            }
            .accessibilityLabel("Tu perfil y más opciones")
        }
        .accessibilityElement(children: .contain)
    }

    private var saludo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(textoSaludo)
                .font(.largeTitle.weight(.bold))
                .accessibilityAddTraits(.isHeader)
            Text(subtitulo)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var textoSaludo: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: "¡Buenos días!"
        case 12..<19: "¡Buenas tardes!"
        default: "¡Buenas noches!"
        }
    }

    private var subtitulo: String {
        switch store.familiares.count {
        case 0: "Empecemos por registrar a la persona que cuidas."
        case 1: "Aquí tienes lo importante sobre \(store.familiares[0].nombre)."
        default: "Elige a quién quieres atender ahora."
        }
    }

    private var seccionPersonas: some View {
        VStack(alignment: .leading, spacing: 12) {
            SeccionHeader(titulo: "Personas a tu cuidado") {
                if !store.familiares.isEmpty {
                    NavigationLink(value: Ruta.agregarFamiliar) {
                        EnlaceTexto(titulo: "Agregar", icono: "plus")
                    }
                }
            }
            contenidoPersonas
        }
    }

    @ViewBuilder
    private var contenidoPersonas: some View {
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
            if store.familiares.isEmpty {
                EstadoVacioFamiliares {
                    ruta.append(.agregarFamiliar)
                }
            } else if tipo.isAccessibilitySize {
                listaVertical
            } else {
                carrusel
            }
        }
    }

    private var carrusel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(store.familiares) { familiar in
                    Button {
                        seleccionar(familiar)
                    } label: {
                        PersonaTile(familiar: familiar, seleccionada: familiar.id == seleccionada?.id)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { menuPersona(familiar) }
                }
                NavigationLink(value: Ruta.agregarFamiliar) {
                    AgregarPersonaTile()
                }
                .buttonStyle(.plain)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 2)
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
        .sensoryFeedback(.selection, trigger: seleccionID)
    }

    private var listaVertical: some View {
        VStack(spacing: 12) {
            ForEach(store.familiares) { familiar in
                Button {
                    seleccionar(familiar)
                } label: {
                    FamiliarCard(familiar: familiar)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(familiar.id == seleccionada?.id ? Color.brandRed : .clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(familiar.id == seleccionada?.id ? .isSelected : [])
            }
        }
    }

    @ViewBuilder
    private func menuPersona(_ familiar: Familiar) -> some View {
        Button {
            ruta.append(.familiar(familiar.id))
        } label: {
            Label("Ver perfil", systemImage: "person.text.rectangle")
        }
        if let telefono = familiar.telefono, let url = URL(string: "tel://\(telefono)") {
            Link(destination: url) {
                Label("Llamar a \(familiar.nombre)", systemImage: "phone")
            }
        }
    }

    private func seccionAccesos(_ persona: Familiar) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SeccionHeader(titulo: "Accesos rápidos") {
                NavigationLink(value: Ruta.familiar(persona.id)) {
                    EnlaceTexto(titulo: "Perfil de \(persona.nombre)")
                }
            }
            if tipo.isAccessibilitySize {
                VStack(spacing: 10) {
                    ForEach(Modulo.accesosRapidos) { modulo in
                        NavigationLink(value: Ruta.modulo(modulo, familiarID: persona.id)) {
                            AccesoRapidoTile(modulo: modulo, compacto: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                HStack(spacing: 10) {
                    ForEach(Modulo.accesosRapidos) { modulo in
                        NavigationLink(value: Ruta.modulo(modulo, familiarID: persona.id)) {
                            AccesoRapidoTile(modulo: modulo)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var seccionRecordatorios: some View {
        VStack(alignment: .leading, spacing: 12) {
            SeccionHeader(titulo: "Próximos recordatorios") {
                Button {
                    pestana = .recordatorios
                } label: {
                    EnlaceTexto(titulo: "Ver todos", icono: nil)
                }
            }
            HStack(spacing: 14) {
                Image(systemName: "bell.badge")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nada pendiente por ahora")
                        .font(.subheadline.weight(.semibold))
                    Text("Cuando registres medicamentos o citas, sus avisos aparecerán aquí.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .tarjetaBorde()
            .accessibilityElement(children: .combine)
        }
    }

    private var cargando: some View {
        HStack {
            Spacer()
            ProgressView("Cargando…")
            Spacer()
        }
        .padding(.vertical, 32)
    }

    private func seleccionar(_ familiar: Familiar) {
        withAnimation(.snappy(duration: 0.2)) {
            seleccionID = familiar.id.uuidString
        }
    }
}

struct EstadoVacioFamiliares: View {
    let agregar: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.tintaSuave)
                    .frame(width: 88, height: 88)
                Image(systemName: "person.2.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(.brandRed)
            }
            .accessibilityHidden(true)
            Text("Aún no agregas a nadie")
                .font(.headline)
            Text("Registra a la persona que cuidas para tener su información médica, medicamentos y citas en un solo lugar.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Agregar persona", action: agregar)
                .padding(.top, 6)
            Text("Toma menos de un minuto.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderGray, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        )
    }
}

struct PrimerosPasosView: View {
    let persona: Familiar
    let abrir: (Ruta) -> Void
    let ocultar: () -> Void

    private struct Paso: Identifiable {
        let id: Int
        let titulo: String
        let hecho: Bool
        let ruta: Ruta
    }

    private var pasos: [Paso] {
        [
            Paso(id: 1, titulo: "Agrega a una persona a tu cuidado", hecho: true, ruta: .agregarFamiliar),
            Paso(id: 2, titulo: "Completa la información médica de \(persona.nombre)", hecho: false, ruta: .modulo(.fichaMedica, familiarID: persona.id)),
            Paso(id: 3, titulo: "Invita a alguien a cuidar contigo", hecho: false, ruta: .modulo(.redCuidado, familiarID: nil))
        ]
    }

    var body: some View {
        let hechos = pasos.filter(\.hecho).count
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Primeros pasos")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text("\(hechos) de \(pasos.count) completados")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Ocultar", action: ocultar)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .frame(minHeight: 44)
            }
            ProgressBarView(progress: Double(hechos) / Double(pasos.count))
                .accessibilityHidden(true)
            VStack(spacing: 0) {
                ForEach(pasos) { paso in
                    Button {
                        abrir(paso.ruta)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: paso.hecho ? "checkmark.circle.fill" : "\(paso.id).circle")
                                .font(.title3)
                                .foregroundColor(paso.hecho ? .green : .brandRed)
                            Text(paso.titulo)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(paso.hecho ? .secondary : .primary)
                                .strikethrough(paso.hecho)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                            if !paso.hecho {
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(Color(white: 0.6))
                            }
                        }
                        .frame(minHeight: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(paso.hecho)
                    .accessibilityLabel(paso.hecho ? "\(paso.titulo), completado" : paso.titulo)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tintaSuave)
        )
    }
}

struct EstadoErrorView: View {
    let mensaje: String
    let reintentar: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.brandRed)
                .accessibilityHidden(true)
            Text("No pudimos cargar la información")
                .font(.headline)
            Text(mensaje)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Reintentar", action: reintentar)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.brandRed)
                .frame(minHeight: 44)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
        .environment(FamiliaresStore())
}
