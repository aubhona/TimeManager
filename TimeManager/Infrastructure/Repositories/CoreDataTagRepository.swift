//
//  CoreDataTagRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation
import UIKit
import CoreData

public final class CoreDataTagRepository: TagRepository {
    
    public static let shared = CoreDataTagRepository()
    
    private init() { }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func createTag(id: UUID, name: String, color: String, tasks: NSSet?) {
        guard let tagEntityDescription = NSEntityDescription.entity(forEntityName: "Tag", in: context) else { return }
        let tag = Tag(entity: tagEntityDescription, insertInto: context)
        tag.id = id
        tag.name = name
        tag.color = color
        tag.tasks = tasks
        
        appDelegate.saveContext()
    }
    
    func getTagById(id: UUID) -> Tag? {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch let error as NSError {
            print("Error fetching tag by ID: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func deleteTagById(id: UUID) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tags = try context.fetch(fetchRequest)
            if let tagToDelete = tags.first {
                context.delete(tagToDelete)
                try context.save()
            }
        } catch let error as NSError {
            print("Error deleting tag: \(error), \(error.userInfo)")
        }
    }
    
    func getAllTags() -> [Tag] {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            let tags = try context.fetch(fetchRequest)
            return tags
        } catch let error as NSError {
            print("Error fetching tags: \(error), \(error.userInfo)")
            return []
        }
    }
}
