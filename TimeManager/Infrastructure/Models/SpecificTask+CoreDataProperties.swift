//
//  SpecificTask+CoreDataProperties.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//
//

import Foundation
import CoreData


extension SpecificTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecificTask> {
        return NSFetchRequest<SpecificTask>(entityName: "SpecificTask")
    }

    @NSManaged public var duration: Int64
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var generalTask: GeneralTask?

}
