//
//  Task+CoreDataProperties.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//
//

import Foundation
import CoreData


extension Task {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var tags: NSSet?
    
}

// MARK: Generated accessors for tags
extension Task {
    
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)
    
    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)
    
    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)
    
    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
    
}

extension Task : Identifiable {
    
}
