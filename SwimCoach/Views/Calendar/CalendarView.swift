//
//  CalendarView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

struct CalendarView: View { // Компонент для отображения календаря с возможностью переключения между месяцем и неделей
    @Binding var selectedDate: Date // Дата, выбранная в календаре
    @State private var isExpanded = false // Состояние, определяющее, развернут ли календарь в режиме месяца или недели

    var body: some View { // Основное тело представления
        VStack(spacing: 0) { // Отступы между элементами
            ZStack { // Фон для календаря
                CalendarMonthView(selectedDate: $selectedDate) // Представление месяца календаря
                    .opacity(isExpanded ? 1 : 0) // Прозрачность в зависимости от состояния
                    .allowsHitTesting(isExpanded) // Позволяет взаимодействовать с элементами только в развернутом состоянии
                
                CalendarWeekView(selectedDate: $selectedDate) // Представление недели календаря
                    .opacity(isExpanded ? 0 : 1) // Прозрачность в зависимости от состояния
                    .allowsHitTesting(!isExpanded) // Позволяет взаимодействовать с элементами только в свернутом состоянии
            }
            .frame(height: isExpanded ? 400 : 80) // Высота календаря зависит от состояния
            .animation(.easeInOut(duration: 0.3), value: isExpanded) // Анимация изменения высоты
            .clipped() // Обрезает содержимое, выходящее за рамки представления
            
            Button(action: { // Действие при нажатии на кнопку переключения режима календаря
                withAnimation { // Анимация переключения
                    isExpanded.toggle() // Переключает состояние развернутости календаря
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down") // Иконка стрелки вверх или вниз в зависимости от состояния
                    .padding() // Отступы вокруг иконки
            }
            .padding(.horizontal) // Отступы по горизонтали
            .padding(.top, 0) // Отступы сверху
        }
        .background(Color(.systemGroupedBackground)) // Фон календаря
        .cornerRadius(12) // Закругление углов календаря
        .padding(.horizontal) // Отступы по горизонтали
    }
}


