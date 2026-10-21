//
//  OnBoardingRoleView.swift
//  CruzContigo
//
//  Created by Ricardo Gómez on 20/10/26.
//

import SwiftUI

enum UserRole {
    case cuidador
    case recibeCuidados
}

struct OnboardingRoleView: View {
    @State private var selectedRole: UserRole? = .cuidador

    var body: some View {
        VStack(spacing: 0) {
            CompactBrandHeader()
                .padding(.top, 12)

            header
                .padding(.top, 20)

            ProgressBarView(progress: 0.5)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            titleSection
                .padding(.top, 24)

            roleCards
                .padding(.top, 32)

            Spacer()

            footer
                .padding(.bottom, 32)
        }
    }

    // MARK: - Secciones

    private var header: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PASO 1 DE 2")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.brandRed)

            Text("¿Cómo usarás\nCruzContigo?")
                .font(.system(size: 32, weight: .bold))

            Text("Elige la opción que mejor te describa.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    private var roleCards: some View {
        VStack(spacing: 16) {
            RoleCard(
                title: "Soy cuidador",
                subtitle: "Quiero cuidar a un familiar\no a otra persona.",
                icon: "person.2",
                isSelected: selectedRole == .cuidador
            ) {
                selectedRole = .cuidador
            }

            RoleCard(
                title: "Recibo cuidados",
                subtitle: "Quiero consultar mi salud\ny recibir apoyo.",
                icon: "heart",
                isSelected: selectedRole == .recibeCuidados
            ) {
                selectedRole = .recibeCuidados
            }
        }
        .padding(.horizontal, 24)
    }

    private var footer: some View {
        VStack(spacing: 14) {
            PrimaryButton(title: "Continuar", action: {})
            Text("Podrás cambiar tu perfil más adelante.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - header logo compacto

struct CompactBrandHeader: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("Cruz").font(.title2).fontWeight(.bold)
            + Text("Contigo")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(.brandRed)

            Text("Cuidar es estar juntos")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Barra de prograeso

struct ProgressBarView: View {
    /// Value between 0 and 1.
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(white: 0.88))
                    .frame(height: 4)
                Capsule()
                    .fill(Color.brandRed)
                    .frame(width: geo.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Roles

struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 16) {
                    iconView

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .padding(20)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .brandRed : Color(white: 0.78))
                    .padding(14)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.brandRed.opacity(0.05) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.brandRed : Color.borderGray, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.brandRed.opacity(0.08) : Color(white: 0.95))
                .frame(width: 56, height: 56)
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.brandRed)
        }
    }
}

#Preview {
    OnboardingRoleView()
}
