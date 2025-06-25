//
//  AddTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//
import SwiftUI
import CoreData

// MARK: - Экран добавления новой тренировки или дежурства

struct AddTrainingView: View {

    // MARK: - Среда окружения

    /// Контекст Core Data
    @Environment(\.managedObjectContext) private var viewContext

    /// Закрытие экрана
    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModel

    /// ViewModel для работы с формой добавления
    @StateObject private var viewModel = AddTrainingViewModel()

    // MARK: - Данные из Core Data

    /// Список всех активных клиентов (не удалённых)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.fullName, ascending: true)],
        predicate: NSPredicate(format: "isDeletedClient == NO"),
        animation: .default
    ) private var activeClients: FetchedResults<Client>

    /// Список доступных тренеров (заглушка/mock)
    private let allTrainers = mockTrainers

    // MARK: - UI

    var body: some View {
        NavigationView {
            Form {

                // MARK: - Тип записи (Тренировка / Дежурство)
                Section(header: Text("Тип записи")) {
                    Picker("Тип", selection: $viewModel.entryType) {
                        ForEach(EntryType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Основные параметры записи
                Section(header: Text("Дата и параметры")) {

                    // Выбор тренера, если это дежурство
                    if viewModel.entryType == .duty {
                        Picker("Дежурство за", selection: $viewModel.selectedTrainer) {
                            ForEach(allTrainers, id: \.self) { trainer in
                                Text(trainer.fullName).tag(Optional(trainer))
                            }
                        }
                    }

                    // Дата начала
                    DatePicker("Дата и время", selection: $viewModel.date)
                        .onChange(of: viewModel.date) {
                            viewModel.endTime = viewModel.calculateEndTime(for: viewModel.selectedType.rawValue,
                                                                            startDate: viewModel.date)
                        }

                    // Время окончания
                    DatePicker("Окончание", selection: $viewModel.endTime)

                    // Тип тренировки (если не дежурство)
                    if viewModel.entryType == .training {
                        Picker("Тип тренировки", selection: $viewModel.selectedType) {
                            ForEach(TrainingType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .onChange(of: viewModel.selectedType) {
                            viewModel.endTime = viewModel.calculateEndTime(for: viewModel.selectedType.rawValue,
                                                                            startDate: viewModel.date)
                        }

                        // Локация тренировки
                        Picker("Локация", selection: $viewModel.selectedLocation) {
                            ForEach(TrainingLocation.allCases) { location in
                                Text(location.rawValue).tag(location)
                            }
                        }
                    }

                    // Статус
                    Picker("Статус", selection: $viewModel.status) {
                        Text("Запланирована").tag("Запланирована")
                        Text("Проведена").tag("Проведена")
                        Text("Отменена").tag("Отменена")
                    }
                }

                // MARK: - Список клиентов (только для тренировок)
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
            .navigationTitle("Новая тренировка")
            .toolbar {
                // Кнопка отмены
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                // Кнопка сохранения
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        viewModel.saveTraining(context: viewContext, activeClients: activeClients) {
                            dismiss()
                        }
                    }
                    // Блокировка кнопки, если нет выбранных клиентов при создании тренировки
                    .disabled(viewModel.entryType == .training && viewModel.selectedClients.isEmpty)
                }
            }
        }
    }
} 
