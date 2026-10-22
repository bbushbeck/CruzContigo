//
//  FamiliarComponents.swift
//  CruzContigo
//

import SwiftUI

struct FamiliarAvatar: View {
    let familiar: Familiar
    var tamano: CGFloat = 56

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.brandRed.opacity(0.1))
            Text(familiar.iniciales)
                .font(.system(size: tamano * 0.36, weight: .bold))
                .foregroundColor(.brandRed)
        }
        .frame(width: tamano, height: tamano)
        .accessibilityHidden(true)
    }
}

struct InfoChip: View {
    let texto: String
    var icono: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icono { Image(systemName: icono) }
            Text(texto)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(.brandRed)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.brandRed.opacity(0.08)))
    }
}

struct FamiliarCard: View {
    let familiar: Familiar

    var body: some View {
        HStack(spacing: 16) {
            FamiliarAvatar(familiar: familiar)

            VStack(alignment: .leading, spacing: 6) {
                Text(familiar.nombreCompleto)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(familiar.parentesco.titulo) · \(familiar.edad) años")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                InfoChip(texto: familiar.tipoCuidado.titulo, icono: familiar.tipoCuidado.icono)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(white: 0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderGray, lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
    }
}

struct ModuloCard: View {
    let modulo: Modulo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandRed.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: modulo.icono)
                    .font(.system(size: 20))
                    .foregroundColor(.brandRed)
            }
            Text(modulo.titulo)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(modulo.subtitulo)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderGray, lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
    }
}

struct FormFieldContainer<Content: View>: View {
    let titulo: String
    var obligatorio = false
    var error: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                Text(titulo)
                if obligatorio {
                    Text("*").foregroundColor(.brandRed)
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)

            content

            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.brandRed)
                    .transition(.opacity)
            }
        }
    }
}

struct BrandTextField: View {
    let titulo: String
    let placeholder: String
    @Binding var texto: String
    var obligatorio = false
    var error: String? = nil
    var teclado: UIKeyboardType = .default

    var body: some View {
        FormFieldContainer(titulo: titulo, obligatorio: obligatorio, error: error) {
            TextField(placeholder, text: $texto)
                .keyboardType(teclado)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .fieldBorder(error != nil)
        }
    }
}

extension View {
    func fieldBorder(_ conError: Bool) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(conError ? Color.brandRed : Color.borderGray, lineWidth: 1.5)
            )
    }
}

struct ChipSelector<Opcion: Identifiable & Hashable>: View {
    let opciones: [Opcion]
    @Binding var seleccion: Opcion?
    let titulo: (Opcion) -> String
    var icono: ((Opcion) -> String)? = nil

    private let columnas = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columnas, alignment: .leading, spacing: 8) {
            ForEach(opciones) { opcion in
                let activo = seleccion == opcion
                Button {
                    seleccion = opcion
                } label: {
                    HStack(spacing: 6) {
                        if let icono { Image(systemName: icono(opcion)) }
                        Text(titulo(opcion))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(activo ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(activo ? Color.brandRed : Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(activo ? Color.brandRed : Color.borderGray, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(activo ? .isSelected : [])
            }
        }
    }
}
