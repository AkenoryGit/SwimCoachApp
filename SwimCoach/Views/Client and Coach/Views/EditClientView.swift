//
//  EditClientView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 16.05.2025.
//

import SwiftUI

// Эта структура представляет собой экран редактирования клиента
struct EditClientView: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст Core Data для сохранения изменений
    @Environment(\.dismiss) private var dismiss // Позволяет закрыть модальное окно редактирования
    
    @ObservedObject var client: Client // Клиент, который редактируется
    
    @State private var fullName: String = "" // ФИО клиента
    @State private var birthDate: Date = Date() // Дата рождения клиента
    @State private var phone: String = "" // Номер телефона клиента
    @State private var notes: String = "" // Примечания клиента
    
    var body: some View {
        NavigationStack { // Используем NavigationStack для навигации
            Form { // Форма для ввода данных клиента
                Section(header: Text("Имя")) { // Секция для ввода имени клиента
                    TextField("Имя", text: $fullName) // Текстовое поле для ввода ФИО
                        
                }
                
                Section(header: Text("Дата рождения")) { // Секция для ввода даты рождения
                    DatePicker("Выберите дату", selection: $birthDate, displayedComponents: .date) // Выбор даты
                        
                }
                
                Section(header: Text("Телефон")) { // Секция для ввода телефона
                    TextField("Телефон", text: $phone) // Текстовое поле для ввода номера телефона
                        .keyboardType(.phonePad) // Устанавливаем клавиатуру для ввода номера телефона
                }

                Section(header: Text("Примечания")) { // Секция для ввода примечаний
                    TextEditor(text: $notes) // Редактор текста для ввода примечаний
                        .frame(minHeight: 100) // Минимальная высота редактора текста
                }
            }
            .navigationTitle("Редактировать") // Название экрана
            .toolbar { // Панель инструментов с кнопками
                ToolbarItem(placement: .confirmationAction) { // Кнопка сохранения
                    Button("Сохранить") { // Кнопка для сохранения изменений
                        saveChanges() // Сохраняем изменения клиента
                    }
                }
                ToolbarItem(placement: .cancellationAction) { // Кнопка отмены
                    Button("Отмена") { // Кнопка для отмены изменений
                        dismiss() // Закрываем модальное окно редактирования
                    }
                }
            }
            .onAppear { // При появлении экрана заполняем поля данными клиента
                fullName = client.fullName ?? "" // ФИО клиента
                birthDate = client.birthDate ?? Date() // Дата рождения клиента
                phone = client.phone ?? "" // Номер телефона клиента
                notes = client.notes ?? "" // Примечания клиента
            }
        }
    }

    private func saveChanges() { // Функция для сохранения изменений клиента
        client.fullName = fullName // Сохраняем ФИО клиента
        client.birthDate = birthDate // Сохраняем дату рождения клиента
        client.phone = phone // Сохраняем номер телефона клиента
        client.notes = notes // Сохраняем примечания клиента

        do { // Попытка сохранить изменения в Core Data
            try viewContext.save() // Сохраняем контекст
            dismiss() // Закрываем модальное окно редактирования
        } catch { // вылавнивание ошибки
            print("Ошибка при сохранении клиента: \(error.localizedDescription)") // вывод сообщения об ошибке при сохарнении клиента
        }
    }
}
