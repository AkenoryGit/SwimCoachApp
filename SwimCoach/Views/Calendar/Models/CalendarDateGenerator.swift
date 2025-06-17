//
//  CalendarDateGenerator.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import Foundation

// Структура, которая отвечает за генерацию дат месяца для отображения в календарной сетке
struct CalendarDateGenerator {
    
    /// Генерирует массив всех дат, которые нужно отобразить в календарной сетке для заданного месяца.
    /// Этот массив включает не только фактические дни месяца, но и дополнительные "пустые" ячейки
    /// в начале (для выравнивания по дням недели).
    ///
    /// - Parameters:
    ///   - baseDate: Любая дата внутри нужного месяца (например, 1 июня или 15 июня).
    ///   - calendar: Календарь, который используется для расчётов (обычно .current).
    ///
    /// - Returns: Массив объектов `Date`, представляющих собой все дни календарной сетки.
    static func generateMonthDates(for baseDate: Date, calendar: Calendar) -> [Date] {
        
        // Получаем диапазон всех дней в месяце (например, 1...30)
        guard let range = calendar.range(of: .day, in: .month, for: baseDate),
              // Получаем первое число месяца (например, 1 июня 2025)
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else {
            return []
        }

        // Определяем, на какой день недели приходится 1-е число месяца
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        // Вычисляем, сколько "пустых" ячеек нужно добавить перед началом месяца,
        // чтобы дни начинались с нужного дня недели (например, с понедельника)
        let paddingDays = firstWeekday - calendar.firstWeekday

        // Общее количество ячеек в сетке: дни месяца + отступ в начале
        let totalDays = range.count + (paddingDays >= 0 ? paddingDays : 7 + paddingDays)

        // Формируем массив дат, начиная с "первого видимого дня в сетке"
        return (0..<totalDays).compactMap { offset in
            calendar.date(byAdding: .day,
                          value: offset - (paddingDays >= 0 ? paddingDays : 7 + paddingDays),
                          to: startOfMonth)
        }
    }
}
