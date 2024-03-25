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
        return
    }
    
    func deleteTag(id: UUID) {
        return
    }
    
    func getAllTags() -> [Tag] {
        return []
    }
    
    func getTagById() -> Tag? {
        return nil
    }
}
