//
//  VerifyPhoneView.swift
//  CruzContigo
//
//  Created by Ricardo Gómez on 20/10/26.
//

import SwiftUI

struct VerifyPhoneView: View {
    @State private var code: String = ""

    private let codeLength = 6

    var body: some View {
        VStack(spacing: 0) {
            header
            BrandLogoView()
                .padding(.top, 24)
            titleSection
                .padding(.top, 28)
            codeSection
                .padding(.top, 28)
            resendSection
                .padding(.top, 24)

            Spacer()

            footer
                .padding(.bottom, 32)
        }
    }

    // MARK: - Secciones

    private var header: some View {
        HStack {
            BrandBackButton(action: {})
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Verifica tu número")
                .font(.system(size: 30, weight: .bold))

            (Text("Te enviamos un código de 6 dígitos al ")
                .foregroundColor(.secondary)
            + Text("+52 81 •••• 4567")
                .fontWeight(.bold)
                .foregroundColor(.primary))
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    private var codeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingresa el código para continuar.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            CodeInputView(code: $code, length: codeLength)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    private var resendSection: some View {
        VStack(spacing: 4) {
            Text("¿No recibiste el código?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {}) {
                Text("Reenviar código")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.brandRed)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            PrimaryButton(title: "Verificar y continuar", action: {})

            Button(action: {}) {
                Text("Cambiar número telefónico")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.brandRed)
            }

            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("Tu información se mantiene protegida.")
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    VerifyPhoneView()
}
