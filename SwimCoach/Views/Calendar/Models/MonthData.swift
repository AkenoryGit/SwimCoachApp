//
//  MonthData.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 17.06.2025.
//

import SwiftUI

 // Эта структура представляет данные о месяце для календаря
struct MonthData: Identifiable, Equatable { // 🔍 добавлено Equatable для сравнения
    let id = UUID() // Уникальный идентификатор для каждого месяца
    let date: Date // Дата, представляющая месяц
}
