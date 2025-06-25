//
//  TimelineCalculation.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - Структура для позиционированных тренировок
struct PositionedTraining: Identifiable {
    var id: NSManagedObjectID { training.objectID } // уникальный идентификатор тренировки
    let training: Training // объект тренировки из Core Data
    let topOffset: CGFloat // позиция сверху в пикселях
    let height: CGFloat // высота в пикселях
    let column: Int // индекс колонки, если тренировка перекрывает другие
    let totalColumns: Int // общее количество колонок в группе перекрывающихся тренировок
}

// MARK: - Расчёт позиции и высоты тренировок
func calculatePositionedTrainings(from trainings: [Training], hourHeight: CGFloat) -> [PositionedTraining] {
    let sorted = trainings.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) } // сортируем тренировки по дате
    var result: [PositionedTraining] = [] // массив для хранения результатов
    var currentGroup: [Training] = [] // текущая группа перекрывающихся тренировок

    func addGroup(_ group: [Training]) { // функция для добавления группы тренировок в результат
        let count = group.count // количество тренировок в группе
        for (index, training) in group.enumerated() { // проходим по каждой тренировке в группе
            if let (topOffset, height) = makeTrainingOffsetHeight(from: training, hourHeight: hourHeight) { // вычисляем позицию и высоту
                result.append(PositionedTraining( // создаём PositionedTraining
                    training: training, // объект тренировки
                    topOffset: topOffset, // позиция сверху
                    height: height, // высота
                    column: index, // индекс колонки в группе
                    totalColumns: count // подсчет количества колонок
                ))
            }
        }
    }

    for training in sorted { // проходим по отсортированным тренировкам
        guard let start = training.date, let end = training.endTime else { continue } // пропускаем тренировки без даты или времени окончания
        if currentGroup.isEmpty { // если текущая группа пуста, добавляем тренировку
            currentGroup.append(training) // добавляем тренировку в группу
        } else { // если группа уже содержит тренировки
            let overlaps = currentGroup.contains { other in // проверяем, перекрывается ли текущая тренировка с другими в группе
                guard let otherStart = other.date, let otherEnd = other.endTime else { return false } // пропускаем тренировки без даты или времени окончания
                return max(start, otherStart) < min(end, otherEnd) // проверяем перекрытие по времени
            }
            if overlaps { // если есть перекрытие, добавляем тренировку в текущую группу
                currentGroup.append(training) // добавляем тренировку в группу
            } else { // если нет перекрытия, сохраняем текущую группу и начинаем новую
                addGroup(currentGroup) // добавляем текущую группу в результат
                currentGroup = [training] // начинаем новую группу с текущей тренировкой
            }
        }
    }

    if !currentGroup.isEmpty { // если осталась непустая группа после цикла
        addGroup(currentGroup) // добавляем её в результат
    }

    return result // возвращаем массив с позиционированными тренировками
}

// MARK: - Расчёт позиции и высоты дежурств
func makePositionedDuties(from duties: [Duty], on day: Date, hourHeight: CGFloat) -> [PositionedDuty] {
    let calendar = Calendar.current // получаем текущий календарь
    let sixAMUTC = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: day)! // устанавливаем начало дня на 6:00 утра в UTC

    return duties.compactMap { duty in // проходим по каждому дежурству
        guard let start = duty.startTime, let end = duty.endTime else { return nil } // пропускаем дежурства без времени начала или окончания

        let startMinutes = CGFloat(start.timeIntervalSince(sixAMUTC)) / 60.0 // вычисляем количество минут с 6:00 утра
        let endMinutes = CGFloat(end.timeIntervalSince(sixAMUTC)) / 60.0 // вычисляем количество минут с 6:00 утра
        let duration = endMinutes - startMinutes // вычисляем продолжительность в минутах
        guard duration > 0 else { return nil } // пропускаем дежурства с нулевой или отрицательной продолжительностью

        let minuteHeight = hourHeight / 60.0 // вычисляем высоту одной минуты в пикселях
        let topOffset = startMinutes * minuteHeight / 2 // вычисляем смещение сверху в пикселях
        let height = duration * minuteHeight // вычисляем высоту дежурства в пикселях

        return PositionedDuty(duty: duty, topOffset: topOffset, height: height) // создаём PositionedDuty с вычисленными значениями
    }
}

// MARK: - Вспомогательная функция для получения позиции и высоты одной тренировки
func makeTrainingOffsetHeight(from training: Training, hourHeight: CGFloat) -> (topOffset: CGFloat, height: CGFloat)? {
    guard let start = training.date, let end = training.endTime else { return nil } // проверяем, что есть дата начала и окончания тренировки
    let calendar = Calendar.current // получаем текущий календарь
    let minHour: CGFloat = 6 // минимальный час начала дня в пикселях

    let startOfDay = calendar.startOfDay(for: start) // получаем начало дня для даты начала тренировки
    let startMinutes = CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: start).minute ?? 0 + (calendar.dateComponents([.hour], from: startOfDay, to: start).hour ?? 0) * 60) // вычисляем количество минут с начала дня до начала тренировки
    let endMinutes = CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: end).minute ?? 0 + (calendar.dateComponents([.hour], from: startOfDay, to: end).hour ?? 0) * 60) // вычисляем количество минут с начала дня до окончания тренировки

    let clampedStart = max(startMinutes, minHour * 60) // ограничиваем начало тренировки минимумом в 6:00 утра
    let clampedEnd = min(endMinutes, 23 * 60) // ограничиваем окончание тренировки максимумом в 23:00 вечера

    let duration = clampedEnd - clampedStart // вычисляем продолжительность тренировки в минутах
    guard duration > 0 else { return nil } // пропускаем тренировки с нулевой или отрицательной продолжительностью

    let minuteHeight = hourHeight / 60.0 // вычисляем высоту одной минуты в пикселях
    let topOffset = (clampedStart - minHour * 60) * minuteHeight // вычисляем смещение сверху в пикселях
    let height = duration * minuteHeight // вычисляем высоту тренировки в пикселях

    return (topOffset, height) // возвращаем кортеж с позицией и высотой тренировки
}

// MARK: - Индикатор текущего времени
func currentTimeOffset() -> CGFloat? {
    let calendar = Calendar.current // получаем текущий календарь
    let now = Date() // получаем текущее время
    let minHour: CGFloat = 6 // минимальный час начала дня в пикселях

    let components = calendar.dateComponents([.hour, .minute], from: now) // извлекаем часы и минуты из текущего времени
    guard let hour = components.hour, let minute = components.minute else { return nil } // проверяем, что часы и минуты корректно извлечены

    let totalMinutes = CGFloat(hour * 60 + minute) // вычисляем общее количество минут с начала дня
    let clampedMinutes = max(min(totalMinutes, 23 * 60), minHour * 60) // ограничиваем количество минут между 6:00 и 23:00

    return clampedMinutes - minHour * 60 // возвращаем смещение относительно 6:00 утра в минутах
}
