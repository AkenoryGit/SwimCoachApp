//
//  AddClientView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

struct AddClientView: View {
    // Доступ к Core Data — именно через этот контекст мы добавим клиента в базу
    @Environment(\.managedObjectContext) private var viewContext

    // Позволяет закрыть модальное окно (форма добавления клиента)
    @Environment(\.dismiss) private var dismiss

    // Эти переменные будут хранить то, что вводит пользователь
    @State private var fullName = ""               // ФИО клиента
    @State private var phone = ""                  // Номер телефона
    @State private var birthDate = Date()          // Дата рождения
    @State private var notes = ""                  // Примечания (ограничения и т.п.)
    /// Словарь: [тип тренировки : сколько оплачено]
    @State private var trainingCounts: [TrainingType: Int] = {
        var result: [TrainingType: Int] = [:]
        for type in TrainingType.allCases {
            result[type] = 0
        }
        return result
    }()

    var body: some View {
        NavigationView {
            Form {
                // Секция формы с полями для ввода
                Section(header: Text("Данные клиента")) {
                    // Текстовое поле для ФИО
                    TextField("ФИО", text: $fullName)
                    
                    // Текстовое поле для номера телефона
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)

                    // Выбор даты рождения
                    DatePicker("Дата рождения", selection: $birthDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ru_RU"))

                    // Текстовое поле для примечаний
                    TextField("Примечания", text: $notes)

                    // Степпер для выбора количества оплаченных тренировок
                    Section(header: Text("Оплаченные тренировки")) {
                        ForEach(TrainingType.allCases) { type in
                            Stepper(value: Binding(
                                get: { trainingCounts[type] ?? 0 },
                                set: { trainingCounts[type] = $0 }
                            ), in: 0...100) {
                                Text("\(type.rawValue): \(trainingCounts[type] ?? 0)")
                            }
                        }
                    }
                    }
                }
            

            // Заголовок навигации
            .navigationTitle("Новый клиент")

            // Кнопки сверху справа и слева
            .toolbar {
                // Кнопка "Отмена" (слева) — просто закрывает форму
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                // Кнопка "Сохранить" (справа) — вызывает функцию addClient()
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        addClient()  // вызываем функцию сохранения
                        dismiss()    // закрываем окно после сохранения
                    }
                    // Кнопка будет неактивна, если поле ФИО пустое
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    // Функция, которая создаёт нового клиента и сохраняет его в базу данных
private func addClient() {
    let newClient = Client(context: viewContext)
    newClient.id = UUID()
    newClient.fullName = fullName
    newClient.phone = phone
    newClient.birthDate = birthDate
    newClient.notes = notes

    // Для каждого типа тренировки создаём баланс, если количество > 0
    for (type, count) in trainingCounts where count > 0 {
        let balance = TrainingBalance(context: viewContext)
        balance.id = UUID()
        balance.type = type.rawValue
        balance.count = Int32(count)
        balance.client = newClient
    }

    do {
        try viewContext.save()
    } catch {
        print("Ошибка при сохранении клиента: \(error.localizedDescription)")
    }
}
}
