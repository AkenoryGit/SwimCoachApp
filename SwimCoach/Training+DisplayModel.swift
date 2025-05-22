//
//  Training+DisplayModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 21.05.2025.
//

import Foundation

extension Training {
    func toDisplayModel() -> TrainingDisplayModel? {
        guard let id = self.id,
              let start = self.date,
              let end = self.endTime else { return nil }

        let clients = (self.clients as? Set<Client>)?.compactMap { $0.fullName } ?? []

        return TrainingDisplayModel(
            id: id,
            type: self.type ?? "Без типа",
            clients: clients,
            startTime: start,
            endTime: end
        )
    }
}
