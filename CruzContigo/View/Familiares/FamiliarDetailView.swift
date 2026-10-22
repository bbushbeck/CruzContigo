//
//  FamiliarDetailView.swift
//  CruzContigo
//

import SwiftUI

struct FamiliarDetailView: View {
    let familiarID: UUID

    @Environment(FamiliaresStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmarEliminar = false

    private var familiar: Familiar? {
        store.familiares.first { $0.id == familiarID }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BrandBackButton { dismiss() }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            if let familiar {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        perfil(familiar)
                        datos(familiar)
                        modulos(familiar)
                        eliminarBoton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            } else {
                Spacer()
                Text("Este perfil ya no existe.")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .confirmationDialog(
            "¿Eliminar a \(familiar?.nombre ?? "este familiar")?",
            isPresented: $confirmarEliminar,
            titleVisibility: .visible
        ) {
            Button("Eliminar perfil", role: .destructive) {
                guard let familiar else { return }
                Task {
                    await store.eliminar(familiar)
                    dismiss()
                }
            }
        } message: {
            Text("Se borrará su perfil de este dispositivo.")
        }
    }

    private func perfil(_ familiar: Familiar) -> some View {
        VStack(spacing: 12) {
            FamiliarAvatar(familiar: familiar, tamano: 96)
            Text(familiar.nombreCompleto)
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                InfoChip(texto: familiar.parentesco.titulo, icono: "heart.fill")
                InfoChip(texto: familiar.tipoCuidado.titulo, icono: familiar.tipoCuidado.icono)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func datos(_ familiar: Familiar) -> some View {
        VStack(spacing: 0) {
            FilaDato(icono: "calendar", titulo: "Fecha de nacimiento",
                     valor: "\(familiar.fechaNacimiento.formatted(date: .long, time: .omitted)) · \(familiar.edad) años")
            Divider().padding(.leading, 52)
            FilaDato(icono: "phone.fill", titulo: "Teléfono",
                     valor: familiar.telefono.map(formatearTelefono) ?? "Sin registrar")
            if let notas = familiar.notas {
                Divider().padding(.leading, 52)
                FilaDato(icono: "note.text", titulo: "Notas", valor: notas)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderGray, lineWidth: 1.5)
        )
    }

    private func modulos(_ familiar: Familiar) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Su cuidado")
                .font(.title3)
                .fontWeight(.bold)
            ForEach(Modulo.allCases.filter(\.esPorFamiliar)) { modulo in
                NavigationLink(value: Ruta.modulo(modulo, familiarID: familiar.id)) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.brandRed.opacity(0.08))
                                .frame(width: 44, height: 44)
                            Image(systemName: modulo.icono)
                                .foregroundColor(.brandRed)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(modulo.titulo).font(.headline).foregroundColor(.primary)
                            Text(modulo.subtitulo).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color(white: 0.7))
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.borderGray, lineWidth: 1.5)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var eliminarBoton: some View {
        Button(role: .destructive) {
            confirmarEliminar = true
        } label: {
            Label("Eliminar perfil", systemImage: "trash")
                .font(.subheadline.weight(.bold))
                .foregroundColor(.brandRed)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
    }

    private func formatearTelefono(_ t: String) -> String {
        guard t.count == 10 else { return t }
        let a = t.prefix(2), b = t.dropFirst(2).prefix(4), c = t.suffix(4)
        return "\(a) \(b) \(c)"
    }
}

struct FilaDato: View {
    let icono: String
    let titulo: String
    let valor: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icono)
                .foregroundColor(.brandRed)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).font(.caption).foregroundColor(.secondary)
                Text(valor).font(.body)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}
