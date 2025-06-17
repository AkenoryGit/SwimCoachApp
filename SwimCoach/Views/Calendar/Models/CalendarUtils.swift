//
//  CalendarUtils.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import Foundation

struct CalendarUtils { // Методы для работы с календарем и датами
    
    // Возвращает массив коротких названий дней недели (Пн, Вт, Ср...) в заданной локали
        static func weekdays(using calendar: Calendar) -> [String] {
            let formatter = DateFormatter() // Создаём форматтер для получения названий дней недели
            formatter.locale = Locale(identifier: "ru_RU") // Устанавливаем локаль на русский
            formatter.calendar = calendar // Устанавливаем календарь, чтобы получить правильные названия
            return formatter.shortWeekdaySymbols // Возвращаем короткие названия дней недели
        }
    
    // Находит индекс месяца, который соответствует дате в массиве MonthData
        static func findCurrentMonthIndex(in months: [MonthData], matching date: Date, using calendar: Calendar) -> Int? {
            return months.firstIndex { // Ищем индекс первого элемента, который соответствует условию
                calendar.isDate($0.date, equalTo: date, toGranularity: .month) // Проверяем, совпадает ли месяц даты в массиве с заданной датой
            }
        }

    // Возвращает строку с названием месяца и года (например, "Июнь 2025")
    static func monthTitle(for date: Date, localeIdentifier: String = "ru_RU") -> String {
        let formatter = DateFormatter() // Создаём форматтер для форматирования даты
        formatter.locale = Locale(identifier: localeIdentifier) // Устанавливаем локаль на русский
        formatter.dateFormat = "LLLL yyyy" // Устанавливаем формат даты: название месяца и год
        return formatter.string(from: date).capitalized // Форматируем строку и возвращаем её
    }

    // Генерирует массив всех дат месяца с учётом отступа перед началом (для отображения в сетке)
    static func generateMonthDates(for baseDate: Date, calendar: Calendar = .current) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: baseDate), // получаем диапазон дней в месяце
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate)) else { // получаем начало месяца
            return [] // если не удалось получить диапазон или начало месяца, возвращаем пустой массив
        }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth) // получаем первый день недели для начала месяца
        let paddingDays = firstWeekday - calendar.firstWeekday // вычисляем количество дней, которые нужно добавить перед первым днём месяца
        let totalDays = range.count + (paddingDays >= 0 ? paddingDays : 7 + paddingDays) // общее количество дней в сетке месяца

        return (0..<totalDays).compactMap { offset in // создаём массив дат с учётом отступа
            calendar.date(byAdding: .day, value: offset - (paddingDays >= 0 ? paddingDays : 7 + paddingDays), to: startOfMonth) // добавляем дни к началу месяца
        }
    }

    // Возвращает индекс месяца в массиве, если дата `target` совпадает с датой из массива `months` по месяцу
    static func indexForMonth(_ months: [MonthData], target: Date, calendar: Calendar = .current) -> Int? {
        months.firstIndex(where: {
            calendar.isDate($0.date, equalTo: target, toGranularity: .month) // проверяем, совпадает ли месяц даты в массиве с заданной датой
        })
    }
    
    // Изменяет текущий индекс месяца в пределах допустимого диапазона
    static func changeMonth(_ currentIndex: inout Int, by value: Int, in months: [MonthData]) {
        let newIndex = currentIndex + value // вычисляем новый индекс, прибавляя значение к текущему индексу
        if months.indices.contains(newIndex) { // проверяем, находится ли новый индекс в пределах допустимого диапазона
            currentIndex = newIndex // если да, обновляем текущий индекс
        }
    }
}
