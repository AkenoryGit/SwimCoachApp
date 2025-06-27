//
//  EntryDetailView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 27.06.2025.
//

import SwiftUI
import CoreData

struct EntryDetailView: View {
    let entry: PositionedEntry
    let onUpdate: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
    @State private var confirmDelete = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Информация")
                    .font(.title2.bold())
                    .padding(.bottom, 4)

                Group {
                    Text("📌 Тип: \(entry.type == .training ? "Тренировка" : "Дежурство")")
                    Text("🕒 Время: \(formattedTimeRange)")
                }

                if entry.type == .training {
                    // Расширенное отображение тренировки
                    if let training = fetchTraining(by: entry.id) {
                        Text("🏷 Название: \(training.type ?? "—")")
                        Text("📍 Место: \(training.location ?? "—")")
                        Text("📝 Заметка: \(training.note ?? "—")")
                        Text("👥 Клиенты: \(training.clientsArray.map { $0.fullName ?? "Без имени" }.joined(separator: ", "))")
                    }
                } else {
                    // Расширенное отображение дежурства
                    if let duty = fetchDuty(by: entry.id) {
                        Text("👤 За кого: \(duty.trainerName ?? "—")")
                        Text("📌 Статус: \(duty.status ?? "—")")
                        Text("📝 Заметка: \(duty.note ?? "—")")
                    }
                }

                Spacer()

                Button("Редактировать") {
                    showEditSheet = true
                }
                .buttonStyle(.bordered)

                Button("Удалить", role: .destructive) {
                    confirmDelete = true
                }

            }
            .padding()
            .navigationTitle("Информация")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if entry.type == .training {
                    EditTrainingView(entryID: entry.id) {
                        onUpdate()
                    }
                } else {
                    EditDutyView(entryID: entry.id) {
                        onUpdate()
                    }
                }
            }
            .alert("Удалить запись?", isPresented: $confirmDelete) {
                Button("Удалить", role: .destructive) {
                    deleteEntry()
                }
                Button("Отмена", role: .cancel) { }
            }
        }
    }
    
    private func fetchTraining(by id: UUID) -> Training? {
        let request: NSFetchRequest<Training> = Training.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? PersistenceController.shared.container.viewContext.fetch(request).first
    }

    private func fetchDuty(by id: UUID) -> Duty? {
        let request: NSFetchRequest<Duty> = Duty.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? PersistenceController.shared.container.viewContext.fetch(request).first
    }

    private var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: entry.startTime)) — \(formatter.string(from: entry.endTime))"
    }

    private func deleteEntry() {
        let context = PersistenceController.shared.container.viewContext

        if entry.type == .training {
            let request: NSFetchRequest<Training> = Training.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

            if let training = try? context.fetch(request).first {
                context.delete(training)
            }
        } else {
            let request: NSFetchRequest<Duty> = Duty.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

            if let duty = try? context.fetch(request).first {
                context.delete(duty)
            }
        }

        do {
            try context.save()
            onUpdate()
        } catch {
            print("❌ Ошибка при удалении: \(error)")
        }

        dismiss()
    }
}
