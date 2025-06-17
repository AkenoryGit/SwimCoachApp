//
//  CalendarMonthHeaderView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

// Этот файл отвечает за отображение заголовка календаря: месяц и год,
// а также стрелки для перехода на предыдущий и следующий месяц.
//
// Заголовок календаря состоит из трёх элементов:
// - Кнопка "влево" для перехода на предыдущий месяц.
// - Текст с текущим названием месяца и года.
// - Кнопка "вправо" для перехода на следующий месяц.

import SwiftUI

// Представление (View) заголовка месяца в календаре
struct CalendarMonthHeaderView: View {
    // Дата, на основе которой будет отображаться название месяца и года (например, Июнь 2025)
    let currentDate: Date

    // Обработчики нажатий:
    let onBack: () -> Void      // При нажатии на стрелку "влево"
    let onForward: () -> Void   // При нажатии на стрелку "вправо"
    let onTitleTap: () -> Void  // При нажатии на название месяца (например, чтобы открыть выбор месяца и года)

    var body: some View {
        HStack { // Отображаем элементы в горизонтальном ряду
            // Кнопка "назад" (влево)
            Button(action: onBack) {
                Image(systemName: "chevron.left")
            }

            Spacer() // Отступ между кнопкой "назад" и названием месяца

            // Кнопка с названием месяца и года (например, "Июнь 2025")
            Button(action: onTitleTap) {
                Text(monthTitle(for: currentDate))
                    .font(.headline)
            }

            Spacer() // Отступ между названием месяца и кнопкой "вперёд"

            // Кнопка "вперёд" (вправо)
            Button(action: onForward) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.bottom, 5) // Отступ снизу для визуального разделения
    }

    // Приватная функция, которая формирует строку вида "Июнь 2025"
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter() // Создаем экземпляр форматтера для работы с датами
        formatter.locale = Locale(identifier: "ru_RU") // Локализация — на русском
        formatter.dateFormat = "LLLL yyyy"             // Формат: полное название месяца и год
        return formatter.string(from: date).capitalized // Возвращаем строку с заглавной буквы
    }
}
