//
//  TimelineCalculation.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 24.06.2025.
//

//import Foundation
//import SwiftUI
//import CoreData

//// MARK: - Структура для позиционированных тренировок
//struct PositionedTraining: Identifiable {
//    var id: NSManagedObjectID { training.objectID } // уникальный идентификатор тренировки
//    let training: Training // объект тренировки из Core Data
//    let topOffset: CGFloat // позиция сверху в пикселях
//    let height: CGFloat // высота в пикселях
//    let column: Int // индекс колонки, если тренировка перекрывает другие
//    let totalColumns: Int // общее количество колонок в группе перекрывающихся тренировок
//}
//
//// MARK: - Расчёт позиции и высоты тренировок
//func calculatePositionedTrainings(from trainings: [Training], hourHeight: CGFloat) -> [PositionedTraining] {
//    let sorted = trainings.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
//    var result: [PositionedTraining] = []
//
//    var currentGroup: [Training] = []
//
//    func overlaps(_ a: Training, _ b: Training) -> Bool {
//        guard let aStart = a.date, let aEnd = a.endTime,
//              let bStart = b.date, let bEnd = b.endTime else { return false }
//        return max(aStart, bStart) < min(aEnd, bEnd)
//    }
//
//    func buildColumns(for group: [Training]) {
//        var columns: [[Training]] = []
//
//        for training in group {
//            var placed = false
//            for columnIndex in 0..<columns.count {
//                if let last = columns[columnIndex].last, !overlaps(last, training) {
//                    columns[columnIndex].append(training)
//                    placed = true
//                    break
//                }
//            }
//            if !placed {
//                columns.append([training])
//            }
//        }
//
//        for (colIndex, column) in columns.enumerated() {
//            for training in column {
//                if let (topOffset, height) = makeTrainingOffsetHeight(from: training, hourHeight: hourHeight) {
//                    result.append(PositionedTraining(
//                        training: training,
//                        topOffset: topOffset,
//                        height: height,
//                        column: colIndex,
//                        totalColumns: columns.count
//                    ))
//                }
//            }
//        }
//    }
//
//    for training in sorted {
//        guard let start = training.date, let end = training.endTime else { continue }
//
//        if currentGroup.isEmpty {
//            currentGroup.append(training)
//        } else {
//            let overlapsGroup = currentGroup.contains { overlaps($0, training) }
//            if overlapsGroup {
//                currentGroup.append(training)
//            } else {
//                buildColumns(for: currentGroup)
//                currentGroup = [training]
//            }
//        }
//    }
//
//    if !currentGroup.isEmpty {
//        buildColumns(for: currentGroup)
//    }
//
//    return result
//}
//
//// MARK: - Расчёт позиции и высоты дежурств
//func makePositionedDuties(from duties: [Duty], on day: Date, hourHeight: CGFloat) -> [PositionedDuty] {
//    let calendar = Calendar.current // получаем текущий календарь
//    let sixAMUTC = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: day)! // устанавливаем начало дня на 6:00 утра в UTC
//
//    return duties.compactMap { duty in // проходим по каждому дежурству
//        guard let start = duty.startTime, let end = duty.endTime else { return nil } // пропускаем дежурства без времени начала или окончания
//
//        let startMinutes = CGFloat(start.timeIntervalSince(sixAMUTC)) / 60.0 // вычисляем количество минут с 6:00 утра
//        let endMinutes = CGFloat(end.timeIntervalSince(sixAMUTC)) / 60.0 // вычисляем количество минут с 6:00 утра
//        let duration = endMinutes - startMinutes // вычисляем продолжительность в минутах
//        guard duration > 0 else { return nil } // пропускаем дежурства с нулевой или отрицательной продолжительностью
//
//        let minuteHeight = hourHeight / 60.0 // вычисляем высоту одной минуты в пикселях
//        let topOffset = startMinutes * minuteHeight / 2 // вычисляем смещение сверху в пикселях
//        let height = duration * minuteHeight // вычисляем высоту дежурства в пикселях
//
//        return PositionedDuty(duty: duty, topOffset: topOffset, height: height) // создаём PositionedDuty с вычисленными значениями
//    }
//}
//
//// MARK: - Вспомогательная функция для получения позиции и высоты одной тренировки
//func makeTrainingOffsetHeight(from training: Training, hourHeight: CGFloat) -> (topOffset: CGFloat, height: CGFloat)? {
//    guard let start = training.date, let end = training.endTime else { return nil } // проверяем, что есть дата начала и окончания тренировки
//    let calendar = Calendar.current // получаем текущий календарь
//    let minHour: CGFloat = 6 // минимальный час начала дня в пикселях
//
//    let startOfDay = calendar.startOfDay(for: start) // получаем начало дня для даты начала тренировки
//    let startMinutes = CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: start).minute ?? 0 + (calendar.dateComponents([.hour], from: startOfDay, to: start).hour ?? 0) * 60) // вычисляем количество минут с начала дня до начала тренировки
//    let endMinutes = CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: end).minute ?? 0 + (calendar.dateComponents([.hour], from: startOfDay, to: end).hour ?? 0) * 60) // вычисляем количество минут с начала дня до окончания тренировки
//
//    let clampedStart = max(startMinutes, minHour * 60) // ограничиваем начало тренировки минимумом в 6:00 утра
//    let clampedEnd = min(endMinutes, 23 * 60) // ограничиваем окончание тренировки максимумом в 23:00 вечера
//
//    let duration = clampedEnd - clampedStart // вычисляем продолжительность тренировки в минутах
//    guard duration > 0 else { return nil } // пропускаем тренировки с нулевой или отрицательной продолжительностью
//
//    let minuteHeight = hourHeight / 60.0 // вычисляем высоту одной минуты в пикселях
//    let topOffset = (clampedStart - minHour * 60) * minuteHeight // вычисляем смещение сверху в пикселях
//    let height = duration * minuteHeight // вычисляем высоту тренировки в пикселях
//
//    return (topOffset, height) // возвращаем кортеж с позицией и высотой тренировки
//}
//
//// MARK: - Индикатор текущего времени
//func currentTimeOffset() -> CGFloat? {
//    let calendar = Calendar.current // получаем текущий календарь
//    let now = Date() // получаем текущее время
//    let minHour: CGFloat = 6 // минимальный час начала дня в пикселях
//
//    let components = calendar.dateComponents([.hour, .minute], from: now) // извлекаем часы и минуты из текущего времени
//    guard let hour = components.hour, let minute = components.minute else { return nil } // проверяем, что часы и минуты корректно извлечены
//
//    let totalMinutes = CGFloat(hour * 60 + minute) // вычисляем общее количество минут с начала дня
//    let clampedMinutes = max(min(totalMinutes, 23 * 60), minHour * 60) // ограничиваем количество минут между 6:00 и 23:00
//
//    return clampedMinutes - minHour * 60 // возвращаем смещение относительно 6:00 утра в минутах
//}
