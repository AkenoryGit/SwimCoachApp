//
//  EditTrainingView.swift.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

struct EditTrainingView: View {
    @ObservedObject var training: Training
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var endTime: Date
    @State private var selectedType: TrainingType
    @State private var selectedLocation: TrainingLocation
    @State private var status: TrainingStatus
    @State private var note: String
    @State private var selectedClients: Set<UUID> = []

    // 👇 Добавили сохранение исходного статуса
    private let originalStatus: String

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    )
    private var activeClients: FetchedResults<Client>

    init(training: Training) {
        _training = ObservedObject(wrappedValue: training)
        _date = State(initialValue: training.date ?? Date())
        _endTime = State(initialValue: training.endTime ?? Date())
        _selectedType = State(initialValue: TrainingType(rawValue: training.type ?? "") ?? .personal)
        _selectedLocation = State(
            initialValue: TrainingLocation(rawValue: training.location ?? "") ?? .bigPool
        )
        _status = State(initialValue: TrainingStatus(rawValue: training.status ?? "") ?? .planned)
        _note = State(initialValue: training.note ?? "")
        self.originalStatus = training.status ?? "Запланирована" // 👈 тут сохраняем старый статус
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Дата и время", selection: $date)
                    DatePicker("Окончание", selection: $endTime)
                    Picker("Тип тренировки", selection: $selectedType) {
                        ForEach(TrainingType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("Локация", selection: $selectedLocation) {
                        ForEach(TrainingLocation.allCases) { location in
                            Text(location.rawValue).tag(location)
                        }
                    }
                    Picker("Статус", selection: $status) {
                        ForEach(TrainingStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                } header: {
                    Text("Дата и тип")
                }

                Section(header: Text("Клиенты")) {
                    ForEach(activeClients) { client in
                        MultipleSelectionRow(
                            title: client.fullName ?? "Без имени",
                            isSelected: selectedClients.contains(client.id ?? UUID())
                        ) {
                            toggleClientSelection(client)
                        }
                    }
                }

                Section(header: Text("Заметка")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Редактировать")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSelectedClients()
            }
        }
    }

    private func toggleClientSelection(_ client: Client) {
        guard let id = client.id else { return }
        if selectedClients.contains(id) {
            selectedClients.remove(id)
        } else {
            selectedClients.insert(id)
        }
    }

    private func loadSelectedClients() {
        guard let clients = training.clients as? Set<Client> else { return }
        selectedClients = Set(clients.compactMap { $0.id })
    }

    private func saveChanges() {
        training.date = date
        training.endTime = endTime
        training.type = selectedType.rawValue
        training.location = selectedLocation.rawValue
        training.status = status.rawValue
        training.note = note

        // Обновим список клиентов
        if let existingClients = training.clients as? Set<Client> {
            for client in existingClients {
                if let id = client.id, !selectedClients.contains(id) {
                    training.removeFromClients(client)
                }
            }
        }

        for client in activeClients {
            if let id = client.id, selectedClients.contains(id) {
                training.addToClients(client)
            }
        }

        // 👇 Списываем с баланса, если статус изменился на "Проведена" или "Отменена, но списана"
        let statusesToDeduct: [TrainingStatus] = [.completed, .cancelledAndPaid]

        if let old = TrainingStatus(rawValue: originalStatus),
           statusesToDeduct.contains(old),
           statusesToDeduct.contains(status) {
            for client in activeClients {
                guard let id = client.id else { continue }

                if selectedClients.contains(id),
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue && $0.count > 0 }) {
                    balance.count -= 1
                }
            }
        }
        // 🟢 Возврат баланса, если статус стал НЕсписывающим, а раньше был списывающим
        if let old = TrainingStatus(rawValue: originalStatus),
           statusesToDeduct.contains(old),
           !statusesToDeduct.contains(status) {
            
            for client in activeClients {
                guard let id = client.id else { continue }

                if selectedClients.contains(id),
                   let balances = client.balances as? Set<TrainingBalance>,
                   let balance = balances.first(where: { $0.type == selectedType.rawValue }) {
                    balance.count += 1
                }
            }
        }

        do {
            try viewContext.save()
            TrainingUpdateNotifier.shared.notifyUpdate()
        } catch {
            print("Ошибка при сохранении изменений: \(error.localizedDescription)")
        }
    }
}
