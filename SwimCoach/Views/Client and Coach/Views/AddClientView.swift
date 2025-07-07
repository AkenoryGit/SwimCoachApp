//
//  AddClientView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI
import CoreData

struct AddClientView: View { // Форма для добавления нового клиента
    @Environment(\.managedObjectContext) private var viewContext // Контекст Core Data для сохранения клиента
    @Environment(\.dismiss) private var dismiss // Позволяет закрыть модальное окно
    @StateObject private var viewModel = AddClientViewModel() // ViewModel для управления состоянием формы
    @State private var showDuplicateAlert = false
    @State private var allowSavingDuplicate = false

    var body: some View { // Главный интерфейс формы
        NavigationView { // Навигационное окно для управления переходами
            Form { // Форма для ввода данных клиента
                Section(header: Text("Данные клиента")) { // Секция с полями для ввода данных клиента
                    TextField("ФИО", text: $viewModel.fullName) // Текстовое поле для ввода ФИО клиента
                    TextField("Телефон", text: $viewModel.phone) // Текстовое поле для ввода номера телефона клиента
                        .keyboardType(.phonePad) // Устанавливаем клавиатуру для ввода номера телефона
                    Toggle("Указать дату рождения", isOn: $viewModel.isBirthDateSpecified)

                    if viewModel.isBirthDateSpecified {
                        DatePicker("Дата рождения", selection: $viewModel.birthDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                    } // Дата-пикер для выбора даты рождения клиента, если флаг isBirthDateSpecified установлен в true
                    TextField("Примечания", text: $viewModel.notes) // Текстовое поле для ввода примечаний о клиенте
                }

                Section(header: Text("Оплаченные тренировки")) { // Секция для выбора количества оплаченных тренировок
                    ForEach(TrainingType.allCases) { type in // Перебираем все типы тренировок
                        Stepper(value: Binding( // Создаем привязку для Stepper
                            get: { viewModel.trainingCounts[type] ?? 0 }, // Получаем текущее количество оплаченных тренировок для данного типа
                            set: { viewModel.trainingCounts[type] = $0 } // Устанавливаем новое количество оплаченных тренировок
                        ), in: 0...100) { // Stepper для изменения количества оплаченных тренировок
                            Text("\(type.rawValue): \(viewModel.trainingCounts[type] ?? 0)") // Отображаем текст с типом тренировки и количеством оплаченных тренировок
                        }
                    }
                }
            }
            .navigationTitle("Новый клиент") // Заголовок навигационного окна
            .toolbar { // Настройка панели инструментов
                ToolbarItem(placement: .cancellationAction) { // Кнопка для отмены добавления клиента
                    Button("Отмена") { // Действие при нажатии кнопки "Отмена"
                        dismiss() // Закрываем модальное окно
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let wasSaved = viewModel.saveClient(to: viewContext, allowDuplicate: allowSavingDuplicate)
                        if wasSaved {
                            dismiss()
                        } else {
                            showDuplicateAlert = true
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert("Клиент с таким ФИО уже существует", isPresented: $showDuplicateAlert) {
                Button("Отменить", role: .cancel) {
                    allowSavingDuplicate = false
                }
                Button("Создать всё равно", role: .destructive) {
                    allowSavingDuplicate = true
                    let saved = viewModel.saveClient(to: viewContext, allowDuplicate: true)
                    if saved {
                        dismiss()
                    }
                }
            } message: {
                Text("Вы уверены, что хотите создать клиента с таким же именем?")
            }
        }
    }
}
