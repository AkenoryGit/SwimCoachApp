//
//  EntryType.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 25.06.2025.
//

import Foundation

/// Тип записи: тренировка или дежурство (используется при фильтрации, отображении и редактировании)
enum EntryType: String, CaseIterable, Identifiable {
    case training = "Тренировка"
    case duty = "Дежурство"

    var id: String { self.rawValue }

    /// Ключ, который реально сохраняется в Core Data (`training` или `duty`)
    var storageKey: String {
        switch self {
        case .training: return "training"
        case .duty: return "duty"
        }
    }
}

extension Training {
    var repeatFrequencyEnum: RepeatFrequency? {
        get { RepeatFrequency.from(raw: repeatFrequency) }
        set { repeatFrequency = newValue?.rawValue }
    }
}

extension Duty {
    var repeatFrequencyEnum: RepeatFrequency? {
        get { RepeatFrequency.from(raw: repeatFrequency) }
        set { repeatFrequency = newValue?.rawValue }
    }
}
