//
//  DutyLayerView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.05.2025.
//

import SwiftUI
import CoreData

// Этот файл содержит DutyLayerView, который отображает дежурства в виде блоков на временной шкале.
struct DutyLayerView: View {
    @Binding var selectedDate: Date // Дата, выбранная пользователем, для которой мы отображаем дежурства
    @Environment(\.managedObjectContext) private var viewContext // Контекст Core Data для доступа к данным дежурств

    @StateObject private var viewModel: DutyLayerViewModel // ViewModel для управления логикой получения и обработки дежурств
    private let hourHeight: CGFloat = 60 // Высота одного часа на временной шкале

    init(selectedDate: Binding<Date>) { // Инициализатор, принимающий выбранную дату
        self._selectedDate = selectedDate // Инициализация привязки к выбранной дате
        _viewModel = StateObject(wrappedValue: DutyLayerViewModel(context: PersistenceController.shared.container.viewContext)) // Инициализация ViewModel с контекстом Core Data
    }

    var body: some View { // Основное тело представления
        GeometryReader { geo in // Используем GeometryReader для получения размеров родительского представления
            ZStack(alignment: .topLeading) { // ZStack для наложения блоков дежурств
                let positionedDuties = calculatePositionedDuties(from: viewModel.duties, hourHeight: hourHeight) // Вычисляем позиции блоков дежурств на основе данных из ViewModel и высоты часа

                ForEach(positionedDuties) { item in //  Перебираем все позиционированные дежурства
                    DutyBlockView(
                        duty: item.duty, // Отображаем блок дежурства
                        topOffset: item.topOffset, // Смещение сверху для правильного позиционирования
                        height: item.height, // Высота блока дежурства
                        availableWidth: geo.size.width * 0.15 // Доступная ширина для блока дежурства
                    )
                    .position( // Позиционируем блок дежурства в соответствии с размерами родительского представления
                        x: geo.size.width - (geo.size.width * 0.15) / 2, // Выравниваем по правому краю
                        y: item.topOffset + item.height / 2 // Центрируем по вертикали
                    )
                }
            }
        }
        .onAppear { // Вызываем fetchData при появлении представления
            viewModel.fetch(for: selectedDate) // Получаем дежурства для выбранной даты
        }
        .onChange(of: selectedDate, initial: false) { oldValue, newValue in
            viewModel.fetch(for: newValue) // Обновляем дежурства при изменении выбранной даты
        }
    }
}
