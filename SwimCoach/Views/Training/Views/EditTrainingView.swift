//
//  EditTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

// MARK: - Экран редактирования тренировки

struct EditTrainingView: View {
    
    // MARK: - Environment и State

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showTimeErrorAlert = false
    @State private var timeErrorMessage = ""

    // MARK: - Входные параметры

    let entryID: UUID
    let onSave: () -> Void

    // MARK: - ViewModel

    @StateObject private var viewModel: EditTrainingViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    ) private var activeClients: FetchedResults<Client>

    // MARK: - Инициализация

    init(entryID: UUID, viewModel: EditTrainingViewModel, onSave: @escaping () -> Void) {
        self.entryID = entryID
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onSave = onSave
    }

    // MARK: - UI

    var body: some View {
        KeyboardDismissWrapper {
        NavigationView {
            Form {
                parametersSection
                clientsSection
                notesSection
            }
            .navigationTitle("Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        handleSave()
                    }
                    .disabled(viewModel.selectedClients.isEmpty)
                }
            }
        }
        .alert("Ошибка", isPresented: $showTimeErrorAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(timeErrorMessage)
        }
    }
    }

    // MARK: - Секции формы

    private var parametersSection: some View {
        Section(header: Text("Дата и параметры")) {
            DatePicker("Начало", selection: $viewModel.date)
            DatePicker("Окончание", selection: $viewModel.endTime)

            Picker("Тип тренировки", selection: $viewModel.selectedType) {
                ForEach(TrainingType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }

            Picker("Локация", selection: $viewModel.selectedLocation) {
                ForEach(TrainingLocation.allCases) { location in
                    Text(location.rawValue).tag(location)
                }
            }

            Picker("Статус", selection: $viewModel.status) {
                ForEach(TrainingStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }
    }

    private var clientsSection: some View {
        Section(header: Text("Клиенты")) {
            TextField("Поиск клиента", text: $viewModel.clientSearchText)
                .textFieldStyle(.roundedBorder)

            let filtered = viewModel.filteredClients(from: activeClients)
            let limitedClients = viewModel.showAllClients ? filtered : Array(filtered.prefix(4))

            ForEach(limitedClients) { client in
                if let clientID = client.id {
                    MultipleSelectionRow(
                        title: client.fullName ?? "Без имени",
                        isSelected: viewModel.selectedClients.contains(clientID)
                    ) {
                        viewModel.toggleClientSelection(clientID)
                    }
                }
            }

            if filtered.count > 3 {
                Button(viewModel.showAllClients ? "Свернуть" : "Показать всех") {
                    withAnimation {
                        viewModel.showAllClients.toggle()
                    }
                }
                .foregroundColor(.blue)
            }
        }
    }

    private var notesSection: some View {
        Section(header: Text("Заметка")) {
            TextEditor(text: $viewModel.note)
                .frame(height: 100)
        }
    }

    // MARK: - Логика валидации и сохранения

    private func handleSave() {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: viewModel.date)
        let endHour = calendar.component(.hour, from: viewModel.endTime)
        let duration = viewModel.endTime.timeIntervalSince(viewModel.date)

        if startHour < 6 || endHour > 23 {
            showTimeErrorAlert("Время должно быть между 06:00 и 23:00")
            return
        }

        if viewModel.date >= viewModel.endTime {
            showTimeErrorAlert("Время начала не может быть позже или равно времени окончания")
            return
        }

        if duration < 20 * 60 {
            showTimeErrorAlert("Длительность записи должна быть не менее 20 минут")
            return
        }

        viewModel.saveChanges(context: viewContext, clients: activeClients) {
            onSave()
            dismiss()
        }
    }

    private func showTimeErrorAlert(_ message: String) {
        timeErrorMessage = message
        showTimeErrorAlert = true
    }
}

