//
//  SettingsPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 31.03.2024.
//

import Foundation

internal final class SettingsPresenter {
    private weak var view: SettingsViewController?
    private var specificTaskRepository: SpecificTaskRepository
    private var tagRepository: TagRepository
    private var generalTaskRepository: GeneralTaskRepository
    
    init(_ view: SettingsViewController? = nil, _ specificTaskRepository: SpecificTaskRepository, _ tagRepository: TagRepository, _ generalTaskRepository: GeneralTaskRepository) {
        self.view = view
        self.specificTaskRepository = specificTaskRepository
        self.tagRepository = tagRepository
        self.generalTaskRepository = generalTaskRepository
    }
    
    public func deleteAllData() {
        tagRepository.deleteAllData()
        specificTaskRepository.deleteAllData()
        generalTaskRepository.deleteAllData()
    }
}
