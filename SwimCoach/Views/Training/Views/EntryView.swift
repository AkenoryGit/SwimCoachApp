//
//  EntryView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 30.06.2025.
//

import SwiftUI
import CoreData

struct EntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: EntryViewModel

    var activeClients: FetchedResults<Client>
    var activeTrainers: FetchedResults<CoachData>
    var onSave: (() -> Void)? = nil

    var body: some View {
            KeyboardDismissWrapper {
                Form {
                    // Если режим создания - можно добавить выбор категории (тренировка или дежурство)
                    if viewModel.mode == .create {
                        Section(header: Text("Тип записи")) {
                            Picker("Категория", selection: Binding(
                                get: { viewModel.category },
                                set: { newValue in
                                    // При смене категории можно очистить или сбросить поля, если надо
                                    viewModel.category = newValue
                                })) {
                                Text("Тренировка").tag(EntryCategory.training)
                                Text("Дежурство").tag(EntryCategory.duty)
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // Общие параметры даты и времени
                    Section(header: Text("Дата и время")) {
                        DatePicker("Начало", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("Окончание", selection: $viewModel.endTime, displayedComponents: [.date, .hourAndMinute])
                        Picker("Длительность", selection: $viewModel.selectedDuration) {
                                ForEach(viewModel.possibleDurations, id: \.self) { duration in
                                    Text("\(duration)")
                                        .tag(duration)
                                }
                            }
                            .pickerStyle(.segmented) // Или .menu, если много вариантов
                    }

                    // Отдельные параметры для тренировки
                    if viewModel.category == .training {
                        Section(header: Text("Тип тренировки")) {
                            Picker("Тип", selection: Binding(
                                get: { viewModel.selectedType },
                                set: { newType in
                                    viewModel.onTypeOrLocationChanged(type: newType, location: viewModel.selectedLocation)
                                }
                            )) {
                                ForEach(TrainingType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Локация", selection: Binding(
                                get: { viewModel.selectedLocation },
                                set: { newLocation in
                                    viewModel.onTypeOrLocationChanged(type: viewModel.selectedType, location: newLocation)
                                }
                            )) {
                                ForEach(TrainingLocation.allCases) { location in
                                    Text(location.rawValue).tag(location)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Статус", selection: $viewModel.status) {
                                Text("Запланирована").tag("Запланирована")
                                Text("Проведена").tag("Проведена")
                            }
                            .pickerStyle(.segmented)
                        }

                        Section(header: Text("Клиенты")) {
                            TextField("Поиск клиента", text: $viewModel.clientSearchText)
                                .textFieldStyle(.roundedBorder)

                            let filteredClients = viewModel.filteredClients(from: activeClients)
                            let clientsToShow = viewModel.showAllClients ? filteredClients : Array(filteredClients.prefix(4))

                            ForEach(clientsToShow) { client in
                                if let clientID = client.id {
                                    Button(action: {
                                        viewModel.toggleClientSelection(clientID)
                                    }) {
                                        HStack {
                                            Text(client.fullName ?? "Без имени")
                                            Spacer()
                                            if viewModel.selectedClients.contains(clientID) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            if filteredClients.count > 4 {
                                Button(viewModel.showAllClients ? "Свернуть" : "Показать всех") {
                                    withAnimation {
                                        viewModel.showAllClients.toggle()
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }

                    // Отдельные параметры для дежурства
                    if viewModel.category == .duty {
                        Section(header: Text("Тренер")) {
                            TextField("Поиск тренера", text: $viewModel.trainerSearchText)
                                .textFieldStyle(.roundedBorder)

                            let filteredTrainers = viewModel.filteredTrainers(from: activeTrainers)
                            let trainersToShow = viewModel.showAllTrainers ? filteredTrainers : Array(filteredTrainers.prefix(3))

                            ForEach(trainersToShow, id: \.objectID) { trainer in
                                Button(action: {
                                    viewModel.selectedTrainer = trainer
                                }) {
                                    HStack {
                                        Text(trainer.fullName ?? "Без имени")
                                        Spacer()
                                        if viewModel.selectedTrainer?.objectID == trainer.objectID {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }

                            if filteredTrainers.count > 3 {
                                Button(viewModel.showAllTrainers ? "Свернуть" : "Показать всех") {
                                    withAnimation {
                                        viewModel.showAllTrainers.toggle()
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                        }

                        Section(header: Text("Статус")) {
                            Picker("Статус", selection: $viewModel.status) {
                                Text("Запланировано").tag("Запланирована")
                                Text("Проведено").tag("Проведена")
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // Заметка — общая для всех
                    Section(header: Text("Заметка")) {
                        TextEditor(text: $viewModel.note)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle(viewModel.mode == .create ? "Новая запись" : "Редактирование")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        Task {
                            await saveEntry()
                        }
                    }
                    .disabled(viewModel.category == .training && viewModel.selectedClients.isEmpty)
                }
            }
            .alert("Ошибка", isPresented: $viewModel.showTimeErrorAlert) {
                Button("ОК", role: .cancel) { }
            } message: {
                Text(viewModel.timeErrorMessage)
            }
    }

    @MainActor
    private func saveEntry() async {
        viewModel.save(context: viewContext,
                       activeClients: activeClients,
                       activeTrainers: activeTrainers) {
            onSave?()
            dismiss()
        }
    }
}
