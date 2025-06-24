//
//  BackgroundTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.05.2025.
//

import SwiftUI

// Этот слой представляет собой фон для временной шкалы,
struct BackgroundTimelineLayer: View {
    let hourHeight: CGFloat // Высота одного часа в пикселях

    var body: some View { // тело представления
        VStack(spacing: 0) { // используем VStack для вертикального расположения элементов
            ForEach(6..<24) { hour in // перебираем часы с 6 до 23
                HStack(spacing: 0) { // горизонтальное расположение элементов
                    Text(String(format: "%02d:00", hour)) // форматируем час в виде "HH:MM"
                        .font(.caption2) // используем маленький шрифт для отображения времени
                        .foregroundColor(.gray) // цвет текста серый
                        .frame(width: 50, alignment: .trailing) // устанавливаем ширину и выравнивание текста справа
                        .padding(.trailing, 4) // отступ справа для текста

                    Rectangle() // создаём прямоугольник для линии времени
                        .fill(Color.gray.opacity(0.2)) // устанавливаем цвет линии с небольшой прозрачностью
                        .frame(height: 1) // устанавливаем высоту линии в 1 пиксель

                    Spacer() // используем Spacer для заполнения оставшегося пространства
                        .frame(width: 10) // отступ справа
                }
                Spacer() // используем Spacer для заполнения оставшегося пространства
                    .frame(height: hourHeight - 1) // высота Spacer равна высоте часа минус 1 пиксель для линии
            }
        }
        .padding(.leading, 10) // отступ слева для всего слоя
    }
}
