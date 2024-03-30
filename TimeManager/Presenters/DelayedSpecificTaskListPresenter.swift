//
//  DelayedSpecificTaskListPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import Foundation

internal final class DelayedSpecificTaskListPresenter {
    private var tasks: [SpecificTask] = [SpecificTask]()
    private weak var view: DelayedSpecificTaskListViewController?
    private var taskRepository: SpecificTaskRepository
    
    init(_ view: DelayedSpecificTaskListViewController?, _ taskRepository: SpecificTaskRepository) {
        self.view = view
        self.taskRepository = taskRepository
        tasks = taskRepository.getDelayedTasks()
    }
    
    func getTasksCount() -> Int {
        tasks = taskRepository.getDelayedTasks()
        
        return tasks.count
    }
    
    func getTask(index: Int) -> SpecificTaskDto {
        let specificTask = tasks[index]
        
        let tags = (specificTask.tags!.allObjects as! [Tag]).compactMap { TagDto(id: $0.id!, name: $0.name!, color: $0.color!) }
        let specificTaskDto = SpecificTaskDto(
            id: specificTask.id!,
            name: specificTask.name!,
            isCompleted: specificTask.isCompleted,
            taskDescription: specificTask.taskDescription!,
            scheduledStartTime: "",
            scheduledEndTime: "",
            sheduledDate: "(\(specificTask.duration / 60) ч, \(specificTask.duration % 60) мин)",
            skipped: false,
            tags: tags
        )
        
        return specificTaskDto
    }
    
    func toggleTaskComplete(index: Int) {
        let task = tasks[index]
        task.isCompleted = !task.isCompleted
        
        taskRepository.updateTask(
            id: task.id!,
            name: task.name!,
            isCompleted: task.isCompleted,
            taskDescription: task.taskDescription!,
            tags: task.tags ?? NSSet(),
            duration: task.duration,
            scheduledDate: task.scheduledDate,
            generalTask: task.generalTask
        )
    }
    
    func deleteTask(taskId: UUID) {
        taskRepository.deleteTask(id: taskId)
    }
}
