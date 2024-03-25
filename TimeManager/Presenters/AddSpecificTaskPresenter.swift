//
//  AddSpecificTaskPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 15.03.2024.
//

import Foundation

public final class AddSpecificTaskPresenter {
    private weak var view: AddSpecificTaskViewController?
    private var taskRepository: SpecificTaskRepository
    
    init(_ view: AddSpecificTaskViewController, _ taskRepository: SpecificTaskRepository) {
        self.view = view
        self.taskRepository = taskRepository
    }
    
    public func addTask(name: String, description: String, scheduledDate: Date, duration: Int64) {
        let id = UUID()
        let tags = NSSet()
        taskRepository.createTask(id: id, name: name, isCompleted: false, taskDescription: description, tags: tags, duration: duration, scheduledDate: scheduledDate, generalTask: nil)
    }
}
