//
//  Recordatorio.swift
//  Recordatorio
//
//  Created by María Fernanda Espinosa Vásquez on 20/10/26.
//

import SwiftUI

private let rojo = Color(red: 0.85, green: 0.04, blue: 0.14)
private let rosa = Color(red: 1, green: 0.94, blue: 0.95)

struct Recordatorio: Identifiable {
    let id = UUID()
    var titulo: String
    var familiar: String
    var fecha: Date
    var completado = false
}

struct RecordatoriosView: View {
    @State private var recordatorios: [Recordatorio] = [
        Recordatorio(
            titulo: "Tomar medicamento",
            familiar: "María",
            fecha: .now.addingTimeInterval(3600)
        ),
        Recordatorio(
            titulo: "Cita médica",
            familiar: "José",
            fecha: .now.addingTimeInterval(86400)
        )
    ]

    @State private var mostrarFormulario = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Mis recordatorios")
                    .font(.title2.bold())

                Text("Organiza el cuidado de tus familiares.")
                    .font(.subheadline)
                    .foregroundStyle(.gray)

                Text("Próximos recordatorios")
                    .font(.headline)

                ForEach($recordatorios) { $recordatorio in
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(rojo)
                            .padding(12)
                            .background(.white)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 5) {
                            Text(recordatorio.titulo)
                                .font(.subheadline.bold())
                                .strikethrough(recordatorio.completado)

                            Text(recordatorio.familiar)
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Text(recordatorio.fecha,
                                 format: .dateTime
                                    .day()
                                    .month()
                                    .hour()
                                    .minute())
                                .font(.caption)
                                .foregroundStyle(rojo)
                        }

                        Spacer()

                        Button {
                            recordatorio.completado.toggle()
                        } label: {
                            Image(systemName:
                                recordatorio.completado
                                ? "checkmark.circle.fill"
                                : "circle"
                            )
                            .font(.title2)
                            .foregroundStyle(rojo)
                        }
                    }
                    .padding()
                    .background(rosa)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }

                Button {
                    mostrarFormulario = true
                } label: {
                    Label("Agregar recordatorio", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(rojo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Recordatorios")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostrarFormulario) {
            NuevoRecordatorioView { nuevo in
                recordatorios.append(nuevo)
            }
        }
    }
}

struct NuevoRecordatorioView: View {
    @Environment(\.dismiss) private var dismiss

    var onGuardar: (Recordatorio) -> Void
    let notify = NotificationHandler()

    @State private var titulo = ""
    @State private var familiar = "María"
    @State private var fecha = Date().addingTimeInterval(300)

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre del recordatorio", text: $titulo)

                Picker("Familiar", selection: $familiar) {
                    Text("María").tag("María")
                    Text("José").tag("José")
                }

                DatePicker(
                    "Fecha y hora",
                    selection: $fecha,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            .navigationTitle("Nuevo recordatorio")
            .onAppear {
                notify.askPermission()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let nuevo = Recordatorio(
                            titulo: titulo,
                            familiar: familiar,
                            fecha: fecha
                        )

                        notify.sendNotification(
                            date: fecha,
                            type: "date",
                            title: "CruzContigo ❤️",
                            body: "\(familiar): \(titulo)"
                        )

                        onGuardar(nuevo)
                        dismiss()
                    }

                    .disabled(titulo.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecordatoriosView()
    }
}
