//
//  PersonTabType.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

// Перечисление вкладок для переключения между клиентами и тренерами.

import Foundation

/// Варианты вкладок в списке людей (клиенты / тренеры)
enum TabType: String, CaseIterable, Identifiable {
    case clients = "Клиенты"
    case coaches = "Тренера"

    var id: String { rawValue }
}
