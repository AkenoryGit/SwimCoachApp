//
//  CurrentTimeIndicatorView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

/// Компонент отображает красную горизонтальную линию, указывающую текущее время на временной шкале.
struct CurrentTimeIndicatorView: View {
    let offset: CGFloat          // Смещение по вертикали для текущего времени
    let hourHeight: CGFloat      // Высота одного часа в пикселях

    var body: some View {
        Rectangle()
            .fill(Color.red)                         // Задаём цвет линии — красный
            .frame(height: 1)                        // Линия толщиной 1 пиксель
            .offset(y: offset - 0.5 + hourHeight / 2) // Смещение линии вниз на offset с компенсацией
            .padding(.leading, 60)                   // Отступ слева, чтобы не наезжать на подписи времени
    }
}
