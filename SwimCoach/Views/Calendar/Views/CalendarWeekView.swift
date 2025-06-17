//
//  CalendarWeekView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import SwiftUI

// Вьюшка отображает неделю в виде горизонтального ряда дней.
// Каждый день можно тапнуть — и он станет выбранной датой.
struct CalendarWeekView: View {
    // Это дата, которую выбрал пользователь. Она приходит извне как @Binding.
    @Binding var selectedDate: Date
    
    // Календарь, с которым работаем (обычно используется локальный текущий календарь)
    private let calendar = Calendar.current

    var body: some View {
        // Определяем первый день недели, к которой принадлежит selectedDate.
        // Например, если выбрано 14 июня, и неделя начинается с понедельника — получим 10 июня.
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? Date()
        
        // Горизонтальный ряд из 7 дней недели
        HStack(spacing: 12) {
            // Перебираем 7 дней, начиная от начала недели
            ForEach(0..<7, id: \.self) { offset in
                // Смещаемся от начала недели на offset дней (0 — это первый день недели, 6 — последний)
                let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!

                // Для каждой даты создаём вертикальный столбик: короткое название дня недели + число месяца
                VStack {
                    // Название дня недели (например: Пн, Вт, Ср)
                    Text(shortWeekdayName(for: date))
                        .font(.caption)
                    
                    // Число месяца (например: 14)
                    Text(dayNumber(for: date))
                        // Если день выбранный — делаем жирным и добавляем фон
                        .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .regular) // жирный шрифт для выбранного дня
                        .padding(6) // добавляем отступы вокруг числа
                        .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.2) : .clear) // синий фон для выбранного дня
                        .clipShape(Circle())  // Делаем фон круглым
                }
                .onTapGesture { // Добавляем обработчик нажатия на день
                                   // Если пользователь нажал на день — он становится выбранным
                                   selectedDate = date
                               }
                           }
                       }
                       .padding(.horizontal) // Добавляем горизонтальные отступы вокруг всей недели
                   }

                   // Вспомогательная функция: возвращает сокращённое имя дня недели (например, "Пн")
                   private func shortWeekdayName(for date: Date) -> String {
                       let formatter = DateFormatter() // создаём форматтер для даты
                       formatter.locale = Locale(identifier: "ru_RU") // устанавливаем локаль на русский
                       formatter.dateFormat = "EE" // EE — это краткое имя дня (в зависимости от локали)
                       return formatter.string(from: date) // форматируем дату и получаем строку
                   }

                   // Вспомогательная функция: возвращает просто число дня (например, "7")
                   private func dayNumber(for date: Date) -> String {
                       let formatter = DateFormatter() // создаём форматтер для даты
                       formatter.dateFormat = "d" // d — это просто число дня месяца
                       return formatter.string(from: date) // форматируем дату и получаем строку
                   }
               }
