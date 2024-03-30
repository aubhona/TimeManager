//
//  AddGeneralTaskPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 28.03.2024.
//

import Foundation
import EventKit

internal final class AddGeneralTaskPresenter {
    private weak var view: AddGeneralTaskViewController?
    private var taskRepository: GeneralTaskRepository
    private var reminderManager: ReminderManaging
    private var calendarManager: CalendarManaging
    private var tagRepository: TagRepository
    private var tags: [Tag]
    private var task: GeneralTaskDto?
    
    init(_ view: AddGeneralTaskViewController, _ taskRepository: GeneralTaskRepository, _ reminderManager: ReminderManaging, _ calendarManager: CalendarManaging, _ tagRepository: TagRepository) {
        self.view = view
        self.taskRepository = taskRepository
        self.calendarManager = calendarManager
        self.reminderManager = reminderManager
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
    
    public func fillInputFileds(task: GeneralTaskDto) {
        self.task = task
        guard let specificTask = taskRepository.getTaskById(id: task.id) else { return }
        let selectedTagsIndexes = task.tags.compactMap { tag in
            tags.firstIndex(where: { $0.id == tag.id })
        }
        view?.setInputFields(
            name: task.name,
            description: task.taskDescription,
            date: specificTask.deadlineDate ?? Date(),
            selectedTagsIndexes: selectedTagsIndexes
        )
    }
    
    public func addTask(
        name: String,
        description: String,
        deadlineDate: Date,
        addToReminder: Bool,
        addToCalendar: Bool,
        tagsIndexes: [Int]
    ) throws  {
        let selectedTags = tagsIndexes.map { tags[$0] }
        let tagsSet = NSSet(array: selectedTags)
        if (addToCalendar) {
            if (!calendarManager.create(eventModel: CalendarEventModel(title: name, startDate: deadlineDate, endDate: nil, note: description))) {
                let error = NSError(domain: "EventKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка добавления в календарь. Разрешите добавление в календарь и попробуйте снова."])
                throw error
            }
        }
        if (addToReminder) {
            if (!reminderManager.create(reminderModel: ReminderEventModel(title: name, startDate: nil, dueDate: deadlineDate, note: description))) {
                let error = NSError(domain: "EventKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка добавления в напоминания. Разрешите добавление в напоминания и попробуйте снова."])
                throw error
            }
        }
        if (task != nil) {
            let generalTask = taskRepository.getTaskById(id: task!.id)
            taskRepository.updateTask(id: task!.id, name: name, isCompleted: task!.isCompleted, taskDescription: description, tags: tagsSet, deadlineDate: deadlineDate, specificTasks: generalTask?.specificTasks)
            return
        }
        let id = UUID()
        taskRepository.createTask(id: id, name: name, isCompleted: false, taskDescription: description, tags: tagsSet, deadlineDate: deadlineDate, specificTasks: nil)
    }

}
