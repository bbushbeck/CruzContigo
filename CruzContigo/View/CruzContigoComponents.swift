//
//  CruzContigoComponents.swift
//  CruzContigo
//
//  Created by Ricardo Gómez on 20/10/26.
//

import SwiftUI

// MARK: - Theme

extension Color {
    static let brandRed = Color(red: 0.78, green: 0.13, blue: 0.16)
    static let borderGray = Color(white: 0.82)
}

// MARK: - Brand Logo

struct BrandLogoView: View {
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.brandRed)
                    .frame(width: 72, height: 72)
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 8)

            Text("Cruz").font(.title).fontWeight(.bold)
            + Text("Contigo")
                .font(.title).fontWeight(.bold)
                .foregroundColor(.brandRed)

            Text("Cuidar es estar juntos")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Back Button

struct BrandBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.title3)
                .foregroundColor(.brandRed)
                .frame(width: 44, height: 44)
                .background(Color.brandRed.opacity(0.08))
                .cornerRadius(12)
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
                .font(.headline)
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
        ZStack {
            // Hidden real text field
            TextField("", text: $code)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .focused($isFocused)
                .frame(width: 0, height: 0)
                .opacity(0)
                .onChange(of: code) { newValue in
                    code = String(newValue.filter { $0.isNumber }.prefix(length))
                }

            HStack(spacing: 12) {
                ForEach(0..<length, id: \.self) { index in
                    CodeBoxView(
                        digit: digit(at: index),
                        isActive: index == code.count && isFocused
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
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
                        .fill(Color.white)
                )

            if digit.isEmpty && isActive {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.brandRed)
                    .frame(width: 2, height: 28)
            } else {
                Text(digit)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
    }
}
