//
//  CruzContigoComponents.swift
//  CruzContigo
//
//  Created by Ricardo Gómez on 20/10/26.
//

import SwiftUI

// MARK: - Theme

extension Color {
    static let brandRed = Color.adaptable(
        claro: UIColor(red: 0.86, green: 0.11, blue: 0.14, alpha: 1),
        oscuro: UIColor(red: 0.91, green: 0.21, blue: 0.24, alpha: 1),
        claroContraste: UIColor(red: 0.62, green: 0.05, blue: 0.09, alpha: 1),
        oscuroContraste: UIColor(red: 1.0, green: 0.45, blue: 0.47, alpha: 1)
    )
    static let borderGray = Color.adaptable(
        claro: UIColor(white: 0.90, alpha: 1),
        oscuro: UIColor(white: 0.22, alpha: 1),
        claroContraste: UIColor(white: 0.45, alpha: 1),
        oscuroContraste: UIColor(white: 0.70, alpha: 1)
    )
}

// MARK: - Brand Logo

struct BrandLogoView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image("LogoIcono")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .accessibilityIgnoresInvertColors()
                .accessibilityHidden(true)
                .padding(.bottom, 8)

            Text("Cruz").font(.app(.title)).fontWeight(.bold)
            + Text("Contigo")
                .font(.app(.title)).fontWeight(.bold)
                .foregroundColor(.brandRed)

            Text("Cuidar es estar juntos")
                .font(.app(.subheadline))
                .fontWeight(.semibold)
                .foregroundColor(.textoSuave)
        }
    }
}

// MARK: - Back Button

struct BrandBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.app(.title3))
                .foregroundColor(.brandRed)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.app(.headline))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.brandRed)
                .cornerRadius(16)
        }
    }
}

// MARK: - OTP Code Input

struct CodeInputView: View {
    @Binding var code: String
    let length: Int

    @FocusState private var isFocused: Bool

    var body: some View {
        cajas
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        // Campo real casi invisible: con tamaño 0 no puede recibir el foco.
        .background(campoOculto)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Código de \(length) dígitos")
        .accessibilityValue(valorAccesible)
        .accessibilityHint("Toca dos veces para escribir el código")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { isFocused = true }
    }

    private var cajas: some View {
        HStack(spacing: 12) {
            ForEach(0..<length, id: \.self) { index in
                CodeBoxView(
                    digit: digit(at: index),
                    isActive: index == code.count && isFocused
                )
            }
        }
    }

    private var campoOculto: some View {
        TextField("", text: $code)
            #if os(iOS)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            #endif
            .focused($isFocused)
            .foregroundStyle(.clear)
            .tint(.clear)
            .opacity(0.01)
            .onChange(of: code) { _, newValue in
                code = String(newValue.filter { $0.isNumber }.prefix(length))
            }
    }

    private var valorAccesible: String {
        if code.isEmpty { return "vacío" }
        let digitos: [String] = code.map { String($0) }
        return digitos.joined(separator: " ")
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}

struct CodeBoxView: View {
    let digit: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(isActive ? Color.brandRed : Color.borderGray, lineWidth: 2)
                .frame(width: 48, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                )

            if digit.isEmpty && isActive {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.brandRed)
                    .frame(width: 2, height: 28)
            } else {
                Text(digit)
                    .font(.app(.title2))
                    .fontWeight(.semibold)
            }
        }
    }
}
