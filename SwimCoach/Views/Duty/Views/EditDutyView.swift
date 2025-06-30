//
//  EditDutyView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 12.06.2025.
//

import SwiftUI
import CoreData

struct EditDutyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditDutyViewModel

    @State private var showTimeErrorAlert = false
    @State private var timeErrorMessage = ""

    let onSave: () -> Void

    // MARK: - Инициализация

    init(duty: Duty, coaches: FetchedResults<CoachData>, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditDutyViewModel(duty: duty, coaches: coaches))
        self.onSave = onSave
    }

    init(entryID: UUID, coaches: FetchedResults<CoachData>, onSave: @escaping () -> Void) {
        self.onSave = onSave
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Duty> = Duty.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entryID as CVarArg)
        request.fetchLimit = 1

        let fetchedDuty = try? context.fetch(request).first

        let duty = fetchedDuty ?? {
            let placeholder = Duty(context: context)
            placeholder.id = entryID
            placeholder.startTime = Date()
            placeholder.endTime = Date().addingTimeInterval(3600)
            return placeholder
        }()

        _viewModel = StateObject(wrappedValue: EditDutyViewModel(duty: duty, coaches: coaches))
    }

    // MARK: - Основное тело

    var body: some View {
        KeyboardDismissWrapper {
            NavigationView {
                Form {
                    // Тренер
                    Section(header: Text("Тренер")) {
                        TextField("Поиск тренера", text: $viewModel.trainerSearchText)
                            .textFieldStyle(.roundedBorder)
                        
                        let filtered = viewModel.filteredTrainers()
                        let limited = viewModel.showAllTrainers ? filtered : Array(filtered.prefix(3))
                        
                        ForEach(limited, id: \.objectID) { trainer in
                            HStack {
                                Text(trainer.fullName ?? "Без имени")
                                Spacer()
                                if viewModel.selectedTrainer?.objectID == trainer.objectID {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectedTrainer = trainer
                            }
                        }
                        
                        if filtered.count > 3 {
                            Button(viewModel.showAllTrainers ? "Свернуть" : "Показать всех") {
                                withAnimation {
                                    viewModel.showAllTrainers.toggle()
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Время
                    Section(header: Text("Время")) {
                        DatePicker("Начало", selection: $viewModel.startTime, displayedComponents: [.hourAndMinute])
                        DatePicker("Окончание", selection: $viewModel.endTime, displayedComponents: [.hourAndMinute])
                    }
                    
                    // Статус
                    Section(header: Text("Статус")) {
                        Picker("Статус", selection: $viewModel.selectedStatus) {
                            ForEach(viewModel.allStatuses, id: \.self) {
                                Text($0).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Заметка
                    Section(header: Text("Заметка")) {
                        AutoSizingTextEditor(text: $viewModel.note)
                            .frame(minHeight: 100)
                    }
                }
                .navigationTitle("Редактирование")
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider() // аккуратная линия над кнопкой
                    Button("Сохранить") {
                        validateAndSave()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .alert("Ошибка", isPresented: $viewModel.showTimeErrorAlert) {
                Button("ОК", role: .cancel) { }
            } message: {
                Text(viewModel.timeErrorMessage)
            }
        }
    }

    // MARK: - Методы

    private func validateAndSave() {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: viewModel.startTime)
        let endHour = calendar.component(.hour, from: viewModel.endTime)
        let duration = viewModel.endTime.timeIntervalSince(viewModel.startTime)

        guard startHour >= 6 && endHour <= 23 else {
            showAlert("Время должно быть между 06:00 и 23:00")
            return
        }

        guard viewModel.startTime < viewModel.endTime else {
            showAlert("Время начала не может быть позже или равно времени окончания")
            return
        }

        guard duration >= 20 * 60 else {
            showAlert("Длительность дежурства должна быть не менее 20 минут")
            return
        }

        viewModel.save(context: viewContext) {
            onSave()
            dismiss()
        }
    }

    private func showAlert(_ message: String) {
        timeErrorMessage = message
        showTimeErrorAlert = true
    }
}

// MARK: - Автоматически растущий TextEditor

struct AutoSizingTextEditor: View {
    @Binding var text: String
    @State private var dynamicHeight: CGFloat = 100

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .background(Color.clear)
                .frame(minHeight: dynamicHeight, maxHeight: .infinity)
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
                }
        }
    }
}
