//
//  DayTimelineView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI

// Этот файл описывает представление DayTimelineView,
struct DayTimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст Core Data для работы с данными
    @Binding var selectedDate: Date //  Дата, выбранная для отображения в таймлайне
    @StateObject private var viewModel = DayTimelineViewModel() // Модель представления для управления данными таймлайна

    private let hourHeight: CGFloat = 60 // Высота одного часа в таймлайне, можно настроить по желанию

    var body: some View { // тело представления
        ScrollView(.vertical) { // Вертикальная прокрутка для таймлайна
            VStack(spacing: 0) { // Используем VStack для вертикального расположения элементов
                ZStack(alignment: .topLeading) { // ZStack для наложения элементов таймлайна
                    TimelineBackgroundView(hourHeight: hourHeight) // Фон таймлайна с разметкой часов

                    if Calendar.current.isDateInToday(selectedDate), // проверяем, является ли выбранная дата сегодняшней
                       let offset = viewModel.nowOffset { // получаем смещение текущего времени
                        CurrentTimeIndicatorView(offset: offset, hourHeight: hourHeight) // Индикатор текущего времени
                    }

                    TrainingTimelineLayer( // Слой с тренировками
                        positionedTrainings: viewModel.positionedTrainings, // позиционированные тренировки
                        selectedDate: selectedDate, // выбранная дата
                        hourHeight: hourHeight, // высота часа
                        onTrainingChanged: { // обработчик изменения тренировки
                            viewModel.fetchData(for: selectedDate, context: viewContext) //  обновляем данные после изменения тренировки
                        }
                    )

                    DutyTimelineLayer( // Слой с дежурствами
                        positionedDuties: viewModel.positionedDuties, // позиционированные дежурства
                        hourHeight: hourHeight // высота часа
                    )
                }
            }
        }
        .onAppear { // при появлении представления
            viewModel.fetchData(for: selectedDate, context: viewContext) // загружаем данные для выбранной даты
        }
        .onChange(of: selectedDate) { // при изменении выбранной даты
            viewModel.fetchData(for: selectedDate, context: viewContext) // обновляем данные для новой даты
        }
    }
}


