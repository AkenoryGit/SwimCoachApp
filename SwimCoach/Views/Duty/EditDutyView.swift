//
//  EditDutyView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 12.06.2025.
//

import SwiftUI

struct EditDutyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var note: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedTrainer: Trainer?
    @State private var selectedStatus: String

    let duty: Duty
    let allTrainers: [Trainer] = mockTrainers
    let allStatuses = ["Запланирована", "Проведена", "Отменена"]

    init(duty: Duty) {
        self.duty = duty
        _note = State(initialValue: duty.note ?? "")
        _selectedTrainer = State(initialValue: mockTrainers.first(where: { $0.fullName == duty.trainerName }))
        _selectedStatus = State(initialValue: duty.status ?? "Запланирована")

        let calendar = Calendar.current

        let start = duty.startTime ?? Date()
        let end = duty.endTime ?? Date()

        let componentsStart = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: start)
        let componentsEnd = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: end)

        _startTime = State(initialValue: calendar.date(from: componentsStart) ?? Date())
        _endTime = State(initialValue: calendar.date(from: componentsEnd) ?? Date())
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Редактирование дежурства")
                .font(.title2)
                .bold()

            TextField("Заметка", text: $note)
                .textFieldStyle(.roundedBorder)
            DatePicker("Начало", selection: $startTime, displayedComponents: [.hourAndMinute])
            DatePicker("Окончание", selection: $endTime, displayedComponents: [.hourAndMinute])
            Picker("Дежурство за", selection: $selectedTrainer) {
                ForEach(allTrainers, id: \.self) { trainer in
                    Text(trainer.fullName).tag(Optional(trainer)) // Optional обязательно!
                }
            }
            .pickerStyle(MenuPickerStyle())
            if let trainer = selectedTrainer {
                Text("Выбран: \(trainer.fullName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Picker("Статус", selection: $selectedStatus) {
                ForEach(allStatuses, id: \.self) { status in
                    Text(status).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Spacer()
            Button("Сохранить") {
                duty.note = note
                duty.startTime = startTime
                duty.endTime = endTime
                duty.trainerName = selectedTrainer?.fullName
                duty.status = selectedStatus

                do {
                    try viewContext.save()
                    print("✅ Дежурство обновлено")
                    dismiss()
                } catch {
                    print("❌ Ошибка при сохранении: \(error.localizedDescription)")
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            Button(role: .destructive) {
                viewContext.delete(duty)

                do {
                    try viewContext.save()
                    print("🗑️ Дежурство удалено")
                    dismiss()
                } catch {
                    print("❌ Ошибка при удалении: \(error.localizedDescription)")
                }
            } label: {
                Text("Удалить дежурство")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 10)
        }
        .padding()
    }
}
