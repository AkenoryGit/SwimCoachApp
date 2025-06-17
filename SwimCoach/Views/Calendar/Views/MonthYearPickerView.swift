//
//  MonthYearPickerView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import SwiftUI

// Эта структура представляет собой пользовательский интерфейс для выбора месяца и года.
struct MonthYearPickerView: View {
    @Binding var currentDate: Date // Текущая дата, которую нужно изменить
    @Binding var showPicker: Bool // Флаг для отображения или скрытия этого интерфейса

    let months: [String] = { // Получаем список месяцев на русском языке
        let formatter = DateFormatter() // Создаем форматтер даты
        formatter.locale = Locale(identifier: "ru_RU") // Устанавливаем локаль на русский
        return formatter.standaloneMonthSymbols.map { $0.capitalized } // Получаем названия месяцев и делаем их с заглавной буквы
    }()
    let years = Array(2000...Calendar.current.component(.year, from: Date()) + 5) // Генерируем массив годов от 2000 до текущего года + 5 лет

    var body: some View { // Основной интерфейс
           VStack(spacing: 0) { // Заголовок и пикеры для выбора месяца и года
               Text("Выбор месяца и года") // Заголовок
                   .font(.headline) // Шрифт заголовка
                   .padding() // Отступы вокруг заголовка

               HStack { // Горизонтальный стек для пикеров
                   // Пикер для выбора месяца
                   Picker("Месяц", selection: Binding( // Создаем биндинг для выбора месяца
                       get: { // Получаем текущий месяц из currentDate
                           Calendar.current.component(.month, from: currentDate) - 1 // Месяцы в Swift начинаются с 1, поэтому вычитаем 1
                       },
                       set: { newMonth in // Устанавливаем новый месяц
                           // Обновляем currentDate при выборе нового месяца
                           currentDate = updateDate(
                               month: newMonth + 1, // Добавляем 1, чтобы вернуть месяц к формату Swift
                               year: Calendar.current.component(.year, from: currentDate) // Получаем текущий год из currentDate
                           )
                       }
                   )) {
                       ForEach(0..<months.count, id: \.self) { index in // Перебираем индексы месяцев
                           Text(months[index]).tag(index) // Создаем текст для каждого месяца и устанавливаем тег равным индексу
                       }
                   }
                   .pickerStyle(WheelPickerStyle()) // Стиль пикера — колесо
                   .frame(maxWidth: .infinity) // Задаем максимальную ширину для пикера

                   // Пикер для выбора года
                   Picker("Год", selection: Binding(
                       get: { // Получаем текущий год из currentDate
                           Calendar.current.component(.year, from: currentDate) // Год в Swift начинается с 1, поэтому просто получаем год
                       },
                       set: { newYear in // Устанавливаем новый год
                           // Обновляем currentDate при выборе нового года
                           currentDate = updateDate(
                               month: Calendar.current.component(.month, from: currentDate), // Получаем текущий месяц из currentDate
                               year: newYear // Устанавливаем новый год
                           )
                       }
                   )) {
                       ForEach(years, id: \.self) { year in // Перебираем массив годов
                           Text(String(year)).tag(year) // Создаем текст для каждого года и устанавливаем тег равным году
                       }
                   }
                   .pickerStyle(WheelPickerStyle()) // Стиль пикера — колесо
                   .frame(maxWidth: .infinity) // Задаем максимальную ширину для пикера
               }

               Button("Готово") { // Кнопка для подтверждения выбора
                   showPicker = false // Закрываем окно выбора
               }
               .padding() // Отступы вокруг кнопки
           }
           .frame(height: 300) // Задаем высоту всего интерфейса
           .background(Color(.systemBackground)) // Устанавливаем фон интерфейса
           .cornerRadius(12) // Закругляем углы интерфейса
           .shadow(radius: 8) // Добавляем тень для глубины
           .padding() // Отступы вокруг всего интерфейса
       }

       // Вспомогательная функция — создаёт новую дату с указанным месяцем и годом
       private func updateDate(month: Int, year: Int) -> Date {
           let components = DateComponents(year: year, month: month, day: 1) // Создаем компоненты даты с указанным годом, месяцем и первым числом месяца
           return Calendar.current.date(from: components) ?? Date() // Возвращаем новую дату или текущую дату, если что-то пошло не так
       }
   }
