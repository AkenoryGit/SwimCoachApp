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
    
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var confirmDelete = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CoachData.fullName, ascending: true)],
        predicate: NSPredicate(format: "isMarkedDeleted == NO"),
        animation: .default
    ) private var activeCoaches: FetchedResults<CoachData>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    ) private var activeClients: FetchedResults<Client>

    // MARK: - Body
    var body: some View {
        NavigationView {
            content
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
                    editSheetView
                }
                .alert("Удалить запись?", isPresented: $confirmDelete) {
                    Button("Удалить", role: .destructive) {
                        deleteEntry()
                    }
                    Button("Отмена", role: .cancel) { }
                }
        }
    }

    // MARK: - Контент основной области
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация")
                .font(.title2.bold())
                .padding(.bottom, 4)

            Group {
                Text("📌 Тип: \(entry.type == .training ? "Тренировка" : "Дежурство")")
                Text("🕒 Время: \(formattedTimeRange)")
            }

            Group {
                if entry.type == .training, let training = fetchTraining(by: entry.id) {
                    Text("Название: \(training.type ?? "—")")
                    Text("Место: \(training.location ?? "—")")
                    Text("Заметка: \(training.note ?? "—")")
                    Text("Клиенты: \(training.clientsArray.map { $0.fullName ?? "Без имени" }.joined(separator: ", "))")
                } else if let duty = fetchDuty(by: entry.id) {
                    Text("За кого: \(duty.trainerName ?? "—")")
                    Text("Статус: \(duty.status ?? "—")")
                    Text("Заметка: \(duty.note ?? "—")")
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
    }

    // MARK: - Редактирование
    @ViewBuilder
    private var editSheetView: some View {
        NavigationStack {
            if entry.type == .training {
                if let training = fetchTraining(by: entry.id) {
                    EntryView(
                        viewModel: EntryViewModel(training: training),
                        activeClients: activeClients,
                        activeTrainers: activeCoaches,
                        onSave: {
                            onUpdate()
                            showEditSheet = false
                        }
                    )
                }
            } else {
                if let duty = fetchDuty(by: entry.id) {
                    EntryView(
                        viewModel: EntryViewModel(duty: duty),
                        activeClients: activeClients,
                        activeTrainers: activeCoaches,
                        onSave: {
                            onUpdate()
                            showEditSheet = false
                        }
                    )
                }
            }
        }
    }

    // MARK: - Вспомогательные функции
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

        switch entry.type {
        case .training:
            if let training = fetchTraining(by: entry.id) {
                context.delete(training)
            }
        case .duty:
            if let duty = fetchDuty(by: entry.id) {
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
