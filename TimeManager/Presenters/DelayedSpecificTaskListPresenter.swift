//
//  DelayedSpecificTaskListPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import Foundation

internal final class DelayedSpecificTaskListPresenter: TagFilterPresenter {
    private var tasks: [SpecificTask] = [SpecificTask]()
    private weak var view: DelayedSpecificTaskListViewController?
    private var taskRepository: SpecificTaskRepository
    private var tagRepository: TagRepository
    var tags: [TagDto]
    
    init(_ view: DelayedSpecificTaskListViewController?, _ taskRepository: SpecificTaskRepository, _ tagRepository: TagRepository) {
        self.view = view
        self.taskRepository = taskRepository
        self.tagRepository = tagRepository
        tasks = taskRepository.getDelayedTasks()
        tags = []
        setUnqueTags()
    }
    
    func setUnqueTags() {
        var uniqueTagsSet = Set<Tag>()
        for task in tasks {
            if let taskTags = task.tags as? Set<Tag> {
                uniqueTagsSet.formUnion(taskTags)
            }
        }
        
        tags = uniqueTagsSet.compactMap({ TagDto(id: $0.id!, name: $0.name!, color: $0.color!) })
        filterTasksByTagIDs()
    }
    
    func checkTags() {
        tags = tags.filter { tagRepository.getTagById(id: $0.id) != nil }
    }
    
    func filterTasksByTagIDs() {
        if (tags.isEmpty) {
            tasks = taskRepository.getDelayedTasks()
            return
        }
        let tagIDs = Set(tags.map { $0.id })
        tasks = tasks.filter { task in
            guard let taskTags = task.tags as? Set<Tag> else { return false }
            
            return taskTags.contains(where: { tag in
                tagIDs.contains(tag.id ?? UUID())
            })
        }
    }
    
    func getTasksCount() -> Int {
        tasks = taskRepository.getDelayedTasks()
        filterTasksByTagIDs()
        
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
            sheduledDate: "\(specificTask.duration / 60) ч, \(specificTask.duration % 60) мин",
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
