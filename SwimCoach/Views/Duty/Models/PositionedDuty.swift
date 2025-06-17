//
//  PositionedDuty.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 22.05.2025.
//

// Этот файл создаёт структуру PositionedDuty и функцию для вычисления расположения дежурств на временной шкале в интерфейсе приложения.

import SwiftUI
import CoreData

// Структура PositionedDuty описывает, как и где отобразить одно дежурство на экране.
struct PositionedDuty: Identifiable {
    var id: NSManagedObjectID { duty.objectID } // Уникальный ID для SwiftUI
    let duty: Duty // Сама сущность дежурства (взята из Core Data)
    let topOffset: CGFloat // Насколько от верхней границы экрана должно отступать дежурство
    let height: CGFloat // Высота прямоугольника дежурства (зависит от его длительности)
}

// Эта функция превращает массив всех дежурств в массив PositionedDuty
// То есть она рассчитывает, где и с какой высотой отрисовать каждое дежурство
func calculatePositionedDuties(from duties: [Duty], hourHeight: CGFloat) -> [PositionedDuty] {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current // используем текущую таймзону устройства
    print("🟡 calculatePositionedDuties вызвана, всего \(duties.count) дежурств")

    let minHour: CGFloat = 6 // Временная шкала начинается с 6 утра

    return duties.compactMap { duty in
        guard let start = duty.startTime, let end = duty.endTime else { return nil } // если нет времени начала или конца, пропускаем это дежурство

        // Находим начало дня (00:00) той даты, к которой относится дежурство
        let startOfDay = calendar.startOfDay(for: start)

        // Считаем, сколько минут прошло от начала дня до начала и конца дежурства
        let componentsStart = calendar.dateComponents([.hour, .minute], from: startOfDay, to: start)// минуты с начала дня до начала дежурства
        let componentsEnd = calendar.dateComponents([.hour, .minute], from: startOfDay, to: end) // минуты с начала дня до конца дежурства

        let startMinutes = CGFloat((componentsStart.hour ?? 0) * 60 + (componentsStart.minute ?? 0)) // минуты с начала дня до начала дежурства
        let endMinutes = CGFloat((componentsEnd.hour ?? 0) * 60 + (componentsEnd.minute ?? 0)) // минуты с начала дня до конца дежурства

        // Ограничиваем отображение только на интервале с 6:00 до 23:00
        let clampedStart = max(startMinutes, minHour * 60) // не раньше 6:00
        let clampedEnd = min(endMinutes, 23 * 60) // не позже 23:00

        let duration = clampedEnd - clampedStart // длительность дежурства в минутах
        guard duration > 0 else { return nil } // если дежурство слишком короткое — не показываем

        // hourHeight — это высота одного часа на экране
        // значит, minuteHeight — это высота одной минуты
        let minuteHeight = hourHeight / 60.0

        // topOffset — это на сколько пикселей вниз от начала шкалы надо поставить прямоугольник
        // height — это высота прямоугольника
        let topOffset = (clampedStart - minHour * 60) * minuteHeight
        let height = duration * minuteHeight

        print("🟡 \(duty.startTime?.formatted() ?? "—") – offset: \(topOffset), height: \(height)")

        // Возвращаем полностью подготовленный объект
        return PositionedDuty(duty: duty, topOffset: topOffset, height: height)
    }
}
