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

    init(duty: Duty, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditDutyViewModel(duty: duty))
        self.onSave = onSave
    }
    
    init(entryID: UUID, onSave: @escaping () -> Void) {
        self.onSave = onSave
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Duty> = Duty.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entryID as CVarArg)
        request.fetchLimit = 1

        if let duty = try? context.fetch(request).first {
            _viewModel = StateObject(wrappedValue: EditDutyViewModel(duty: duty))
        } else {
            let placeholder = Duty(context: context)
            placeholder.id = entryID
            placeholder.startTime = Date()
            placeholder.endTime = Date().addingTimeInterval(3600)
            _viewModel = StateObject(wrappedValue: EditDutyViewModel(duty: placeholder))
            print("⚠️ Не удалось найти дежурство с id \(entryID)")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Редактирование дежурства")
                .font(.title2)
                .bold()

            TextField("Заметка", text: $viewModel.note)
                .textFieldStyle(.roundedBorder)

            DatePicker("Начало", selection: $viewModel.startTime, displayedComponents: [.hourAndMinute])
            DatePicker("Окончание", selection: $viewModel.endTime, displayedComponents: [.hourAndMinute])

            Picker("Дежурство за", selection: $viewModel.selectedTrainer) {
                ForEach(viewModel.allTrainers, id: \.self) { trainer in
                    Text(trainer.fullName).tag(Optional(trainer))
                }
            }
            .pickerStyle(MenuPickerStyle())

            if let trainer = viewModel.selectedTrainer {
                Text("Выбран: \(trainer.fullName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Picker("Статус", selection: $viewModel.selectedStatus) {
                ForEach(viewModel.allStatuses, id: \.self) {
                    Text($0).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Spacer()

            Button("Сохранить") {
                let calendar = Calendar.current
                let startHour = calendar.component(.hour, from: viewModel.startTime)
                let endHour = calendar.component(.hour, from: viewModel.endTime)
                let duration = viewModel.endTime.timeIntervalSince(viewModel.startTime)

                if startHour < 6 || endHour > 23 {
                    showAlert("Время должно быть между 06:00 и 23:00")
                    return
                }

                if viewModel.startTime >= viewModel.endTime {
                    showAlert("Время начала не может быть позже или равно времени окончания")
                    return
                }

                if duration < 20 * 60 {
                    showAlert("Длительность дежурства должна быть не менее 20 минут")
                    return
                }

                viewModel.save(context: viewContext) {
                    onSave()
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Button(role: .destructive) {
                viewModel.delete(context: viewContext) {
                    dismiss()
                }
            } label: {
                Text("Удалить дежурство")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 10)
        }
        .padding()
        .alert("Ошибка", isPresented: $showTimeErrorAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(timeErrorMessage)
        }
    }

    private func showAlert(_ message: String) {
        timeErrorMessage = message
        showTimeErrorAlert = true
    }
}
