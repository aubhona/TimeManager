//
//  AddTagPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 27.03.2024.
//

import Foundation

internal final class AddTagPresenter {
    private weak var view: AddTagViewController?
    private var tagRepository: TagRepository
    
    
    init(view: AddTagViewController? = nil, tagRepository: TagRepository) {
        self.view = view
        self.tagRepository = tagRepository
    }
    
    public func addTag(name: String, color: String) throws {
        let id = UUID()
        let tasks = NSSet()
        tagRepository.createTag(id: id, name: name, color: color, tasks: tasks)
    }
}
