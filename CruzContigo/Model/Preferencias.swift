//
//  Preferencias.swift
//  CruzContigo
//

import SwiftUI
import Observation
import CoreText

enum Apariencia: String, CaseIterable, Identifiable {
    case sistema, clara, oscura

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .sistema: "Automática"
        case .clara: "Clara"
        case .oscura: "Oscura"
        }
    }

    var icono: String {
        switch self {
        case .sistema: "circle.lefthalf.filled"
        case .clara: "sun.max.fill"
        case .oscura: "moon.fill"
        }
    }

    var esquema: ColorScheme? {
        switch self {
        case .sistema: nil
        case .clara: .light
        case .oscura: .dark
        }
    }
}

@Observable
final class Preferencias {
    static let compartidas = Preferencias()

    static let tamanos: [DynamicTypeSize] = [.large, .xLarge, .xxLarge, .xxxLarge, .accessibility1, .accessibility2, .accessibility3]

    private enum Clave {
        static let apariencia = "pref.apariencia"
        static let dislexia = "pref.dislexia"
        static let tamanoSistema = "pref.tamanoSistema"
        static let tamano = "pref.tamano"
        static let contraste = "pref.contraste"
        static let movimiento = "pref.reducirMovimiento"
        static let vibraciones = "pref.vibraciones"
        static let negritas = "pref.negritas"
    }

    private let defaults: UserDefaults

    var apariencia: Apariencia { didSet { defaults.set(apariencia.rawValue, forKey: Clave.apariencia) } }
    var dislexia: Bool { didSet { defaults.set(dislexia, forKey: Clave.dislexia) } }
    var tamanoDelSistema: Bool { didSet { defaults.set(tamanoDelSistema, forKey: Clave.tamanoSistema) } }
    var indiceTamano: Int { didSet { defaults.set(indiceTamano, forKey: Clave.tamano) } }
    var masContraste: Bool { didSet { defaults.set(masContraste, forKey: Clave.contraste) } }
    var reducirMovimiento: Bool { didSet { defaults.set(reducirMovimiento, forKey: Clave.movimiento) } }
    var vibraciones: Bool { didSet { defaults.set(vibraciones, forKey: Clave.vibraciones) } }
    var textoEnNegritas: Bool { didSet { defaults.set(textoEnNegritas, forKey: Clave.negritas) } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        apariencia = Apariencia(rawValue: defaults.string(forKey: Clave.apariencia) ?? "") ?? .sistema
        dislexia = defaults.bool(forKey: Clave.dislexia)
        tamanoDelSistema = defaults.object(forKey: Clave.tamanoSistema) as? Bool ?? true
        indiceTamano = defaults.object(forKey: Clave.tamano) as? Int ?? 1
        masContraste = defaults.bool(forKey: Clave.contraste)
        reducirMovimiento = defaults.bool(forKey: Clave.movimiento)
        vibraciones = defaults.object(forKey: Clave.vibraciones) as? Bool ?? true
        textoEnNegritas = defaults.bool(forKey: Clave.negritas)
    }

    var tamanoTexto: DynamicTypeSize? {
        guard !tamanoDelSistema else { return nil }
        return Self.tamanos[min(max(indiceTamano, 0), Self.tamanos.count - 1)]
    }

    func restablecer() {
        apariencia = .sistema
        dislexia = false
        tamanoDelSistema = true
        indiceTamano = 1
        masContraste = false
        reducirMovimiento = false
        vibraciones = true
        textoEnNegritas = false
    }
}

enum Tipografia {
    static let dislexiaRegular = "OpenDyslexic-Regular"
    static let dislexiaNegrita = "OpenDyslexic-Bold"

    static func registrar() {
        for nombre in [dislexiaRegular, dislexiaNegrita] {
            guard let url = Bundle.main.url(forResource: nombre, withExtension: "otf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func tamanoBase(_ estilo: Font.TextStyle) -> CGFloat {
        switch estilo {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }

    static func esEnfatico(_ estilo: Font.TextStyle) -> Bool {
        [.largeTitle, .title, .title2, .title3, .headline].contains(estilo)
    }
}

extension Font {
    static func app(_ estilo: Font.TextStyle) -> Font {
        let prefs = Preferencias.compartidas
        if prefs.dislexia {
            let nombre = Tipografia.esEnfatico(estilo) || prefs.textoEnNegritas ? Tipografia.dislexiaNegrita : Tipografia.dislexiaRegular
            return .custom(nombre, size: Tipografia.tamanoBase(estilo) * 0.92, relativeTo: estilo)
        }
        return prefs.textoEnNegritas ? .system(estilo).bold() : .system(estilo)
    }
}

extension Color {
    static func adaptable(claro: UIColor, oscuro: UIColor, claroContraste: UIColor? = nil, oscuroContraste: UIColor? = nil) -> Color {
        Color(uiColor: UIColor { rasgos in
            let alto = rasgos.accessibilityContrast == .high
            if rasgos.userInterfaceStyle == .dark {
                return alto ? (oscuroContraste ?? oscuro) : oscuro
            }
            return alto ? (claroContraste ?? claro) : claro
        })
    }

    static let textoSuave = Color.adaptable(
        claro: .secondaryLabel,
        oscuro: .secondaryLabel,
        claroContraste: .label,
        oscuroContraste: .label
    )

    static let iconoSuave = Color.adaptable(
        claro: .tertiaryLabel,
        oscuro: .tertiaryLabel,
        claroContraste: .secondaryLabel,
        oscuroContraste: .secondaryLabel
    )

    static let rellenoSuave = Color(uiColor: .tertiarySystemFill)
}

private struct ModificadorPreferencias: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var movimientoSistema
    let prefs: Preferencias

    func body(content: Content) -> some View {
        let reducir = prefs.reducirMovimiento || movimientoSistema
        content
            .font(.app(.body))
            .tracking(prefs.dislexia ? -1 : 0)
            .preferredColorScheme(prefs.apariencia.esquema)
            .modifier(TamanoTexto(tamano: prefs.tamanoTexto))
            .environment(\.reducirMovimiento, reducir)
            .transaction { transaccion in
                if prefs.reducirMovimiento { transaccion.animation = nil }
            }
            .onChange(of: prefs.masContraste, initial: true) { _, valor in
                aplicarContraste(valor)
            }
    }

    private func aplicarContraste(_ alto: Bool) {
        for escena in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            if alto {
                escena.traitOverrides.accessibilityContrast = .high
            } else {
                escena.traitOverrides.remove(UITraitAccessibilityContrast.self)
            }
        }
    }
}

private struct TamanoTexto: ViewModifier {
    let tamano: DynamicTypeSize?

    func body(content: Content) -> some View {
        if let tamano {
            content.dynamicTypeSize(tamano)
        } else {
            content
        }
    }
}

private struct ClaveReducirMovimiento: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var reducirMovimiento: Bool {
        get { self[ClaveReducirMovimiento.self] }
        set { self[ClaveReducirMovimiento.self] = newValue }
    }
}

extension View {
    func aplicarPreferencias(_ prefs: Preferencias) -> some View {
        modifier(ModificadorPreferencias(prefs: prefs))
    }

    func vibracion<T: Equatable>(_ tipo: SensoryFeedback, trigger: T) -> some View {
        sensoryFeedback(tipo, trigger: trigger) { _, _ in
            Preferencias.compartidas.vibraciones
        }
    }
}
