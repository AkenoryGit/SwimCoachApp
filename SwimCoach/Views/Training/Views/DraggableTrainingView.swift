//
//  DraggableTrainingView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 20.05.2025.
//

import SwiftUI

// MARK: - Представление карточки тренировки/дежурства на таймлайне с возможностью перетаскивания

struct DraggableTrainingView: View {

    // MARK: - Внешние зависимости

    /// Контекст Core Data
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Входные параметры

    /// Модель с тренировкой и параметрами позиционирования
    let positionedTraining: PositionedTraining

    /// Высота одного часа на экране (в пикселях)
    let hourHeight: CGFloat

    /// Левая граница области, где разрешено размещение
    let leftBound: CGFloat

    /// Правая граница области, где разрешено размещение
    let rightBound: CGFloat

    /// Фиксированная ширина карточки (если нужно)
    let fixedWidth: CGFloat

    /// Колбек при изменении тренировки — перерисовывает представление
    var onTrainingChanged: (() -> Void)? = nil

    // MARK: - Состояния

    /// Временное смещение при перетаскивании
    @State private var dragOffset: CGFloat = 0

    /// Индикатор активного перетаскивания
    @State private var isDragging = false

    /// Текущий открытый редактор (если не nil — отображается)
    @State private var editorViewModel: EditTrainingViewModel? = nil

    // MARK: - Основное отображение

    var body: some View {
        let training = positionedTraining.training
        let isDuty = training.type == "Дежурство"

        let totalOffset = positionedTraining.topOffset + dragOffset
        let availableWidth = rightBound - leftBound
        let cardWidth = availableWidth / CGFloat(positionedTraining.totalColumns)
        let xOffset = leftBound + CGFloat(positionedTraining.column) * cardWidth

        // Основная карточка: тренировка или дежурство
        Group {
            if isDuty {
                DutyCardView(training: training, width: cardWidth, height: positionedTraining.height)
            } else {
                TrainingCardView(training: training, width: cardWidth)
            }
        }
        .offset(x: xOffset, y: totalOffset)
        .frame(width: cardWidth, height: positionedTraining.height)
        .gesture(dragGesture(for: training))
        .onTapGesture {
            if !isDragging {
                // Инициализация вьюмодели редактора по текущей тренировке
                let vm = EditTrainingViewModel(training: training)
                vm.entryType = isDuty ? .duty : .training
                editorViewModel = vm
            }
        }
        .sheet(item: $editorViewModel) { viewModel in
            EditTrainingView(viewModel: viewModel) {
                onTrainingChanged?()
            }
        }
    }

    // MARK: - Жест перетаскивания

    /// Возвращает жест DragGesture, который обрабатывает смещение тренировки по вертикали
    private func dragGesture(for training: Training) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                dragOffset = value.translation.height
                isDragging = true
            }
            .onEnded { value in
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                applyOffset(value.translation.height, to: training)
                dragOffset = 0
                isDragging = false
            }
    }

    // MARK: - Обработка применения смещения

    /// Применяет смещение к дате и сохраняет обновлённую тренировку в Core Data
    private func applyOffset(_ offset: CGFloat, to training: Training) {
        training.date = shift(training.date, by: offset)
        training.endTime = shift(training.endTime, by: offset)

        do {
            try viewContext.save()
            onTrainingChanged?()
        } catch {
            print("❌ Ошибка при сохранении: \(error.localizedDescription)")
        }
    }

    // MARK: - Пересчёт смещённой даты

    /// Переводит вертикальное смещение в минуты и возвращает новую дату
    private func shift(_ date: Date?, by pixels: CGFloat) -> Date? {
        guard let date else { return nil }
        let minutes = pixels / hourHeight * 60
        return Calendar.current.date(byAdding: .minute, value: Int(minutes), to: date)
    }
}

