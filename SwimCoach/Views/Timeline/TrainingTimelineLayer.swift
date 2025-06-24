//
//  TrainingTimelineLayer.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import SwiftUI

/// Представление слоя с тренировками, располагающимися на временной шкале.
struct TrainingTimelineLayer: View {
    let positionedTrainings: [PositionedTraining] // Отфильтрованные и рассчитанные по позиции тренировки
    let selectedDate: Date
    let hourHeight: CGFloat
    var onTrainingChanged: (() -> Void)? = nil

    @State private var nowOffset: CGFloat? = currentTimeOffset() // Текущее смещение по времени
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // Обновляем каждую минуту

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Красная линия текущего времени (если сегодня)
                if Calendar.current.isDateInToday(selectedDate),
                   let offset = nowOffset {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 1)
                        .offset(y: offset - 0.5)
                        .padding(.leading, 50)
                }

                // Отображение всех тренировок
                ForEach(positionedTrainings) { item in
                    DraggableTrainingView(
                        positionedTraining: item,
                        hourHeight: hourHeight,
                        leftBound: geometry.size.width * 0.1,
                        rightBound: geometry.size.width * 0.9,
                        onTrainingChanged: {
                            onTrainingChanged?()
                        },
                        fixedWidth: geometry.size.width
                    )
                }
            }
        }
        .onReceive(timer) { _ in
            nowOffset = currentTimeOffset()
        }
    }
}
