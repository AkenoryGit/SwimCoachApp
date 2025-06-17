//
//  ClientRowView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 19.05.2025.
//

import SwiftUI

// Эта структура представляет строку клиента в списке клиентов.
struct ClientRowView: View {
    let client: Client // Модель клиента, которую мы отображаем в строке

    var body: some View { // Тело представления
        VStack(alignment: .leading) { // Вертикальный стек для выравнивания элементов по левому краю
            Text(client.fullName ?? "Без имени") // Отображение полного имени клиента, если оно есть, иначе "Без имени"
                .font(.headline) // Установка шрифта заголовка для имени

            if let birthDate = client.birthDate { // Проверяем, есть ли дата рождения у клиента
                let formatter = Date.FormatStyle.dateTime // Создаем форматтер даты
                    .locale(Locale(identifier: "ru_RU")) // Устанавливаем локаль для форматирования даты на русский
                    .day() // Добавляем день в формат даты
                    .month(.wide) // Добавляем полный месяц в формат даты
                    .year() // Добавляем год в формат даты
                
                Text("Дата рождения: \(birthDate.formatted(formatter))") // Отображение даты рождения клиента с использованием форматтера
            }

            if let balances = client.balances as? Set<TrainingBalance>, !balances.isEmpty { // Проверяем, есть ли балансы тренировок у клиента
                VStack(alignment: .leading, spacing: 2) { // Вертикальный стек для отображения балансов
                    ForEach(TrainingType.allCases) { type in // Перебираем все типы тренировок
                        if let balance = balances.first(where: { $0.type == type.rawValue }), balance.count > 0 { // Проверяем, есть ли баланс для данного типа тренировки и его количество больше 0
                            Text("\(type.rawValue): \(balance.count)") // Отображение типа тренировки и количества оставшихся тренировок
                                .font(.subheadline) // Установка шрифта подзаголовка для текста баланса
                                .foregroundColor(.secondary) // Установка вторичного цвета для текста, чтобы он выглядел менее заметным
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4) // Добавляем вертикальные отступы для лучшего визуального восприятия
    }
}
