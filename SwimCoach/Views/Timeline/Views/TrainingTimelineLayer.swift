//
//  TrainingTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

// Этот файл содержит слой для отображения тренировок на временной шкале.
struct TrainingTimelineLayer: View {
    let positionedTrainings: [PositionedTraining] // Отфильтрованные и рассчитанные по позиции тренировки
    let selectedDate: Date // Дата, для которой отображается таймлайн
    let hourHeight: CGFloat // Высота одного часа в пикселях
    var onTrainingChanged: (() -> Void)? = nil // Обработчик изменения тренировки

    @State private var nowOffset: CGFloat? = currentTimeOffset() // Текущее смещение по времени
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // Обновляем каждую минуту

    var body: some View { // тело представления
        GeometryReader { geometry in // используем GeometryReader для получения размеров контейнера
            ZStack(alignment: .topLeading) { // ZStack для наложения элементов
                // Красная линия текущего времени (если сегодня)
                if Calendar.current.isDateInToday(selectedDate),
                   let offset = nowOffset { // получаем смещение текущего времени
                    Rectangle() // создаём прямоугольник для линии
                        .fill(Color.red) // устанавливаем цвет линии красным
                        .frame(height: 1) // устанавливаем высоту линии в 1 пиксель
                        .offset(y: offset - 0.5) // смещаем линию по вертикали на половину пикселя для центрирования
                        .padding(.leading, 50) // отступ слева для линии текущего времени
                }

                // Отображение всех тренировок
                ForEach(positionedTrainings) { item in
                    DraggableTrainingView( // представление для перетаскиваемой тренировки
                        positionedTraining: item, // позиционированная тренировка
                        hourHeight: hourHeight, // высота часа
                        leftBound: geometry.size.width * 0.1, // левый предел для перетаскивания
                        rightBound: geometry.size.width * 0.9, // правый предел для перетаскивания
                        fixedWidth: geometry.size.width, // фиксированная ширина для тренировки
                        onTrainingChanged: { // обработчик изменения тренировки
                            onTrainingChanged?() // вызываем обработчик, если он задан
                        },
                    )
                }
            }
        }
        .onReceive(timer) { _ in // при получении события таймера
            nowOffset = currentTimeOffset() // обновляем смещение текущего времени
        }
    }
}
