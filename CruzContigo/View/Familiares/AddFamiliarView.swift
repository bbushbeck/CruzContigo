//
//  AddFamiliarView.swift
//  CruzContigo
//

import SwiftUI

struct AddFamiliarView: View {
    @Environment(FamiliaresStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft = FamiliarDraft()
    @State private var intentoGuardar = false
    @State private var guardando = false
    @State private var errorGuardado: String?

    private var errores: [FamiliarDraft.Campo: String] {
        intentoGuardar ? draft.errores : [:]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    titleSection
                    datosPersonales
                    seccionCuidado
                    contacto
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            footer
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
        .animation(.easeInOut(duration: 0.2), value: intentoGuardar)
        .alert("No se pudo guardar", isPresented: Binding(
            get: { errorGuardado != nil },
            set: { if !$0 { errorGuardado = nil } }
        )) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(errorGuardado ?? "")
        }
    }

    private var header: some View {
        HStack {
            BrandBackButton { dismiss() }
            Spacer()
            CompactBrandHeader()
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NUEVA PERSONA A CARGO")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.brandRed)
            Text("Agrega a un familiar")
                .font(.system(size: 30, weight: .bold))
            Text("Con estos datos crearemos su perfil para organizar su cuidado.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var datosPersonales: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Datos personales")

            BrandTextField(
                titulo: "Nombre(s)",
                placeholder: "Ej. Rosa María",
                texto: $draft.nombre,
                obligatorio: true,
                error: errores[.nombre]
            )
            .textContentType(.givenName)

            BrandTextField(
                titulo: "Apellidos",
                placeholder: "Ej. Hernández López",
                texto: $draft.apellidos,
                obligatorio: true,
                error: errores[.apellidos]
            )
            .textContentType(.familyName)

            FormFieldContainer(titulo: "Fecha de nacimiento", obligatorio: true, error: errores[.fechaNacimiento]) {
                DatePicker(
                    "Fecha de nacimiento",
                    selection: $draft.fechaNacimiento,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                .tint(.brandRed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .frame(height: 52)
                .fieldBorder(errores[.fechaNacimiento] != nil)
            }
        }
    }

    private var seccionCuidado: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Relación y cuidado")

            FormFieldContainer(titulo: "Parentesco", obligatorio: true, error: errores[.parentesco]) {
                ChipSelector(
                    opciones: Parentesco.allCases,
                    seleccion: $draft.parentesco,
                    titulo: \.titulo
                )
            }

            FormFieldContainer(titulo: "Tipo de cuidado", obligatorio: true, error: errores[.tipoCuidado]) {
                ChipSelector(
                    opciones: TipoCuidado.allCases,
                    seleccion: $draft.tipoCuidado,
                    titulo: \.titulo,
                    icono: \.icono
                )
            }
        }
    }

    private var contacto: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Contacto y notas")

            BrandTextField(
                titulo: "Teléfono (opcional)",
                placeholder: "10 dígitos",
                texto: $draft.telefono,
                error: errores[.telefono],
                teclado: .phonePad
            )

            FormFieldContainer(titulo: "Notas (opcional)") {
                TextField("Ej. Usa bastón, prefiere que le llamen Rosy", text: $draft.notas, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(16)
                    .fieldBorder(false)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if intentoGuardar && !draft.esValido {
                Text("Revisa los campos marcados en rojo.")
                    .font(.footnote)
                    .foregroundColor(.brandRed)
            }

            PrimaryButton(title: guardando ? "Guardando…" : "Guardar familiar") {
                Task { await guardar() }
            }
            .disabled(guardando)
            .opacity(guardando ? 0.7 : 1)

            HStack(spacing: 6) {
                Image(systemName: "lock.fill").font(.caption)
                Text("Tu información se mantiene protegida.").font(.footnote)
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
    }

    private func sectionTitle(_ texto: String) -> some View {
        Text(texto)
            .font(.title3)
            .fontWeight(.bold)
    }

    private func guardar() async {
        intentoGuardar = true
        guard let familiar = draft.construir() else { return }
        guardando = true
        defer { guardando = false }
        if let error = await store.agregar(familiar) {
            errorGuardado = error
        } else {
            dismiss()
        }
    }
}

#Preview {
    AddFamiliarView()
        .environment(FamiliaresStore())
}
