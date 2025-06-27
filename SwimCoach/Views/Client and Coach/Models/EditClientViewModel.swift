//
//  EditClientViewModel.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//

import Foundation
import CoreData

class EditClientViewModel: ObservableObject {
    @Published var fullName: String
    @Published var phone: String
    @Published var birthDate: Date
    @Published var notes: String
    @Published var trainingCounts: [TrainingType: Int]

    private let client: Client

    init(client: Client) {
        self.client = client
        self.fullName = client.fullName ?? ""
        self.phone = client.phone ?? ""
        self.birthDate = client.birthDate ?? Date()
        self.notes = client.notes ?? ""

        var result: [TrainingType: Int] = [:]
        for type in TrainingType.allCases {
            let count = client.trainingBalancesArray.first(where: { $0.type == type.rawValue })?.count ?? 0
            result[type] = Int(count)
        }
        self.trainingCounts = result
    }

    func saveChanges(context: NSManagedObjectContext) {
        client.fullName = fullName
        client.phone = phone
        client.birthDate = birthDate
        client.notes = notes

        for (type, count) in trainingCounts {
            if let balance = client.trainingBalancesArray.first(where: { $0.type == type.rawValue }) {
                balance.count = Int32(count)
            } else if count > 0 {
                let balance = TrainingBalance(context: context)
                balance.id = UUID()
                balance.type = type.rawValue
                balance.count = Int32(count)
                balance.client = client
            }
        }

        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении клиента: \(error.localizedDescription)")
        }
    }
}
