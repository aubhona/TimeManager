//
//  TagSettingsPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 30.03.2024.
//

import Foundation

internal final class TagSettingsPresenter {
    private var tags: [Tag]
    private weak var view: TagSettingsViewController?
    private var tagRepository: TagRepository
    
    init(_ view: TagSettingsViewController?, _ tagRepository: TagRepository) {
        self.view = view
        self.tagRepository = tagRepository
        tags = tagRepository.getAllTags()
    }
    
    public func getTagsCount() -> Int {
        tags = tagRepository.getAllTags()
        
        return tags.count
    }
    
    public func getTag(index: Int) -> TagDto {
        let tag = tags[index]
        
        return TagDto(id: tag.id!, name: tag.name!, color: tag.color!)
    }
    
    public func deleteSelectedTag(tagsIndexes: [Int]) {
        tagsIndexes.forEach{ tagRepository.deleteTagById(id: tags[$0].id!) }
    }
}
