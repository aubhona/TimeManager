//
//  TagRepository.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import Foundation

protocol TagRepository {
    
    func createTag(id: UUID, name: String, color: String, tasks: NSSet?)
    
    func deleteTagById(id: UUID)
    
    func getAllTags() -> [Tag]
    
    func getTagById(id: UUID) -> Tag?
    
    func deleteAllData()
}
