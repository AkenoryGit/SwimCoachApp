//
//  EditTrainingView.swift.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI
import CoreData

struct EditTrainingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showTimeErrorAlert = false
    @State private var timeErrorMessage = ""

    let entryID: UUID
    let onSave: () -> Void

    @StateObject private var viewModel = AddTrainingViewModel() // тот же ViewModel, что и в AddTrainingView
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    ) private var activeClients: FetchedResults<Client>

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Тип записи
                Section(header: Text("Тип записи")) {
                    Picker("Тип", selection: $viewModel.entryType) {
                        ForEach(EntryType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(true) // тип не редактируем
                }

                // MARK: - Основное
                Section(header: Text("Дата и параметры")) {
                    if viewModel.entryType == .duty {
                        Picker("Дежурство за", selection: $viewModel.selectedTrainer) {
                            ForEach(mockTrainers, id: \.self) { trainer in
                                Text(trainer.fullName).tag(Optional(trainer))
                            }
                        }
                    }

                    DatePicker("Начало", selection: $viewModel.date)
                    DatePicker("Окончание", selection: $viewModel.endTime)

                    if viewModel.entryType == .training {
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
                    }

                    Picker("Статус", selection: $viewModel.status) {
                        Text("Запланирована").tag("Запланирована")
                        Text("Проведена").tag("Проведена")
                        Text("Отменена").tag("Отменена")
                    }
                }

                // MARK: - Клиенты
                if viewModel.entryType == .training {
                    Section(header: Text("Клиенты")) {
                        ForEach(activeClients) { client in
                            MultipleSelectionRow(
                                title: client.fullName ?? "Без имени",
                                isSelected: viewModel.selectedClients.contains(client.id ?? UUID())
                            ) {
                                viewModel.toggleClientSelection(client)
                            }
                        }
                    }
                }

                // MARK: - Заметка
                Section(header: Text("Заметка")) {
                    TextEditor(text: $viewModel.note)
                        .frame(height: 100)
                }
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

                        viewModel.updateTraining(id: entryID, context: viewContext, activeClients: activeClients) {
                            onSave()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.selectedClients.isEmpty)
                }
            }
            .onAppear {
                viewModel.loadTraining(id: entryID, context: viewContext)
            }
        }
        .alert("Ошибка", isPresented: $showTimeErrorAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(timeErrorMessage)
        }
    }
    
    private func showTimeErrorAlert(_ message: String) {
        timeErrorMessage = message
        showTimeErrorAlert = true
    }
}

