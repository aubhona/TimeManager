//
//  GeneralTask+CoreDataProperties.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//
//

import Foundation
import CoreData


extension GeneralTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneralTask> {
        return NSFetchRequest<GeneralTask>(entityName: "GeneralTask")
    }

    @NSManaged public var deadlineDate: Date?
    @NSManaged public var specificTasks: NSSet?

}

// MARK: Generated accessors for specificTasks
extension GeneralTask {

    @objc(addSpecificTasksObject:)
    @NSManaged public func addToSpecificTasks(_ value: SpecificTask)

    @objc(removeSpecificTasksObject:)
    @NSManaged public func removeFromSpecificTasks(_ value: SpecificTask)

    @objc(addSpecificTasks:)
    @NSManaged public func addToSpecificTasks(_ values: NSSet)

    @objc(removeSpecificTasks:)
    @NSManaged public func removeFromSpecificTasks(_ values: NSSet)

}
