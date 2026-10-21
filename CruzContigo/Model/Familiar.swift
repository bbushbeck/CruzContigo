//
//  Familiar.swift
//  CruzContigo
//

import Foundation

enum Parentesco: String, Codable, CaseIterable, Identifiable {
    case madre, padre, abuela, abuelo, hijo, hija, pareja, hermano, hermana, otro

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .madre: "Madre"
        case .padre: "Padre"
        case .abuela: "Abuela"
        case .abuelo: "Abuelo"
        case .hijo: "Hijo"
        case .hija: "Hija"
        case .pareja: "Pareja"
        case .hermano: "Hermano"
        case .hermana: "Hermana"
        case .otro: "Otro"
        }
    }
}

enum TipoCuidado: String, Codable, CaseIterable, Identifiable {
    case adultoMayor, discapacidad, enfermedadCronica, recuperacion, otro

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .adultoMayor: "Adulto mayor"
        case .discapacidad: "Discapacidad"
        case .enfermedadCronica: "Enfermedad crónica"
        case .recuperacion: "En recuperación"
        case .otro: "Otro"
        }
    }

    var icono: String {
        switch self {
        case .adultoMayor: "figure.walk"
        case .discapacidad: "figure.roll"
        case .enfermedadCronica: "heart.text.square"
        case .recuperacion: "bandage"
        case .otro: "person"
        }
    }
}

struct Familiar: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var nombre: String
    var apellidos: String
    var fechaNacimiento: Date
    var parentesco: Parentesco
    var tipoCuidado: TipoCuidado
    var telefono: String?
    var notas: String?
    var fechaRegistro: Date = Date()

    var nombreCompleto: String { "\(nombre) \(apellidos)" }

    var iniciales: String {
        let n = nombre.first.map(String.init) ?? ""
        let a = apellidos.first.map(String.init) ?? ""
        return (n + a).uppercased()
    }

    var edad: Int {
        Calendar.current.dateComponents([.year], from: fechaNacimiento, to: Date()).year ?? 0
    }
}

struct FamiliarDraft {
    var nombre = ""
    var apellidos = ""
    var fechaNacimiento = Calendar.current.date(byAdding: .year, value: -70, to: Date()) ?? Date()
    var parentesco: Parentesco? = nil
    var tipoCuidado: TipoCuidado? = nil
    var telefono = ""
    var notas = ""

    enum Campo: Hashable { case nombre, apellidos, fechaNacimiento, parentesco, tipoCuidado, telefono }

    var errores: [Campo: String] {
        var e: [Campo: String] = [:]
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespaces)
        let apellidosLimpios = apellidos.trimmingCharacters(in: .whitespaces)

        if nombreLimpio.isEmpty { e[.nombre] = "El nombre es obligatorio." }
        else if nombreLimpio.count < 2 { e[.nombre] = "Escribe al menos 2 letras." }

        if apellidosLimpios.isEmpty { e[.apellidos] = "Los apellidos son obligatorios." }

        if fechaNacimiento > Date() { e[.fechaNacimiento] = "La fecha no puede ser futura." }

        if parentesco == nil { e[.parentesco] = "Selecciona el parentesco." }
        if tipoCuidado == nil { e[.tipoCuidado] = "Selecciona el tipo de cuidado." }

        let digitos = telefono.filter(\.isNumber)
        if !telefono.isEmpty && digitos.count != 10 {
            e[.telefono] = "El teléfono debe tener 10 dígitos."
        }
        return e
    }

    var esValido: Bool { errores.isEmpty }

    func construir() -> Familiar? {
        guard esValido, let parentesco, let tipoCuidado else { return nil }
        let notasLimpias = notas.trimmingCharacters(in: .whitespacesAndNewlines)
        return Familiar(
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            apellidos: apellidos.trimmingCharacters(in: .whitespaces),
            fechaNacimiento: fechaNacimiento,
            parentesco: parentesco,
            tipoCuidado: tipoCuidado,
            telefono: telefono.isEmpty ? nil : telefono.filter(\.isNumber),
            notas: notasLimpias.isEmpty ? nil : notasLimpias
        )
    }
}
