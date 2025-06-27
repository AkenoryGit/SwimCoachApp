//
//  TrainingBalance+CoreDataProperties.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.06.2025.
//
//

import Foundation
import CoreData


extension TrainingBalance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainingBalance> {
        return NSFetchRequest<TrainingBalance>(entityName: "TrainingBalance")
    }

    @NSManaged public var count: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var client: Client?

}

extension TrainingBalance : Identifiable {

}
