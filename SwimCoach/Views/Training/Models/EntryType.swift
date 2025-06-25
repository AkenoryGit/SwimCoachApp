//
//  EntryType.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 25.06.2025.
//

import Foundation

/// Тип записи: тренировка или дежурство (используется как при создании, так и при редактировании)
enum EntryType: String, CaseIterable, Identifiable {
    case training = "Тренировка"
    case duty = "Дежурство"

    var id: String { self.rawValue }
}
