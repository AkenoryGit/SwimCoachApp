//
//  Client+CoreDataProperties.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var birthDate: Date?
    @NSManaged public var fullName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isDeletedClient: Bool
    @NSManaged public var notes: String?
    @NSManaged public var paidTrainingsCount: Int32
    @NSManaged public var phone: String?
    @NSManaged public var balances: NSSet?
    @NSManaged public var relatedClients: NSSet?
    @NSManaged public var training: NSSet?

}

// MARK: Generated accessors for balances
extension Client {

    @objc(addBalancesObject:)
    @NSManaged public func addToBalances(_ value: TrainingBalance)

    @objc(removeBalancesObject:)
    @NSManaged public func removeFromBalances(_ value: TrainingBalance)

    @objc(addBalances:)
    @NSManaged public func addToBalances(_ values: NSSet)

    @objc(removeBalances:)
    @NSManaged public func removeFromBalances(_ values: NSSet)

}

// MARK: Generated accessors for relatedClients
extension Client {

    @objc(addRelatedClientsObject:)
    @NSManaged public func addToRelatedClients(_ value: Client)

    @objc(removeRelatedClientsObject:)
    @NSManaged public func removeFromRelatedClients(_ value: Client)

    @objc(addRelatedClients:)
    @NSManaged public func addToRelatedClients(_ values: NSSet)

    @objc(removeRelatedClients:)
    @NSManaged public func removeFromRelatedClients(_ values: NSSet)

}

// MARK: Generated accessors for training
extension Client {

    @objc(addTrainingObject:)
    @NSManaged public func addToTraining(_ value: Training)

    @objc(removeTrainingObject:)
    @NSManaged public func removeFromTraining(_ value: Training)

    @objc(addTraining:)
    @NSManaged public func addToTraining(_ values: NSSet)

    @objc(removeTraining:)
    @NSManaged public func removeFromTraining(_ values: NSSet)

}

extension Client : Identifiable {

}

extension Client {
    var trainingBalancesArray: [TrainingBalance] {
        let set = balances as? Set<TrainingBalance> ?? []
        return set.sorted { ($0.type ?? "") < ($1.type ?? "") }
    }
}

extension Training {
    var clientsArray: [Client] {
        let set = clients as? Set<Client> ?? []
        return set.sorted { ($0.fullName ?? "") < ($1.fullName ?? "") }
    }
}

extension Client {
    func age(on date: Date) -> Int? {
        guard let birthDate = birthDate else { return nil }

        let calendar = Calendar.current

        let birthComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: date)

        guard let birthYear = birthComponents.year,
              let birthMonth = birthComponents.month,
              let birthDay = birthComponents.day,
              let currentYear = currentComponents.year,
              let currentMonth = currentComponents.month,
              let currentDay = currentComponents.day else {
            return nil
        }

        var age = currentYear - birthYear

        // если день рождения ещё не наступил в этом году — вычитаем 1
        if (currentMonth < birthMonth) || (currentMonth == birthMonth && currentDay < birthDay) {
            age -= 1
        }

        return age
    }
}
