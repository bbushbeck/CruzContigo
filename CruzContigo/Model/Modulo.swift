//
//  Modulo.swift
//  CruzContigo
//

import Foundation

enum Modulo: String, CaseIterable, Identifiable, Hashable {
    case fichaMedica, medicamentos, citas, redCuidado, emergencia, ayuda

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .fichaMedica: "Ficha médica"
        case .medicamentos: "Medicamentos"
        case .citas: "Citas"
        case .redCuidado: "Red de cuidado"
        case .emergencia: "Emergencia"
        case .ayuda: "Ayuda cercana"
        }
    }

    var subtitulo: String {
        switch self {
        case .fichaMedica: "Alergias, enfermedades y tipo de sangre"
        case .medicamentos: "Tratamientos y registro de tomas"
        case .citas: "Agenda y recordatorios"
        case .redCuidado: "Invita a otros cuidadores"
        case .emergencia: "Ficha sin conexión (demo)"
        case .ayuda: "Opciones de apoyo y donación"
        }
    }

    var icono: String {
        switch self {
        case .fichaMedica: "doc.text.fill"
        case .medicamentos: "pills.fill"
        case .citas: "calendar"
        case .redCuidado: "person.3.fill"
        case .emergencia: "staroflife.fill"
        case .ayuda: "hand.raised.fill"
        }
    }

    var sprint: Int {
        switch self {
        case .fichaMedica, .medicamentos, .citas: 2
        case .redCuidado: 1
        case .emergencia, .ayuda: 3
        }
    }

    var esPorFamiliar: Bool {
        switch self {
        case .fichaMedica, .medicamentos, .citas: true
        default: false
        }
    }
}
