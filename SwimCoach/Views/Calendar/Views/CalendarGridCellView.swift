//
//  CalendarGridCellView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import SwiftUI

// Это отдельное представление (View), которое отвечает за отображение одной ячейки в календарной сетке.
// То есть — отдельный день (например, 5 июня).
struct CalendarGridCellView: View {
    
    // Дата, которую нужно отобразить в этой ячейке
    let day: Date
    
    // Дата, которая выбрана пользователем (она нужна для выделения ячейки)
    let selectedDate: Date
    
    // Календарь (нужен для сравнения дат и форматирования)
    let calendar: Calendar
    
    // Замыкание, которое вызывается при нажатии на ячейку — сообщает, что пользователь выбрал этот день
    let onSelect: (Date) -> Void

    var body: some View {
        // Показываем число месяца (например, 5, 6, 7 и т.д.)
        Text("\(calendar.component(.day, from: day))")
        
            // Жирным делаем только ту дату, которая совпадает с выбранной (selectedDate)
            .fontWeight(calendar.isDate(day, inSameDayAs: selectedDate) ? .bold : .regular)
            
            // Чтобы ячейка растягивалась на максимум доступного пространства
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Добавим немного отступов вокруг текста
            .padding(6)
            
            // Фоновый цвет только для выбранной даты — синеватый кружок
            .background(calendar.isDate(day, inSameDayAs: selectedDate) ? Color.blue.opacity(0.2) : .clear)
            
            // Делаем фон круглым
            .clipShape(Circle())
            
            // Добавляем действие при тапе: если нажали на ячейку — вызываем onSelect(day)
            .onTapGesture {
                onSelect(day)
            }
    }
}
