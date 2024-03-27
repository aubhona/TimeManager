//
//  AddSpecificTaskPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 15.03.2024.
//

import Foundation
import EventKit

public final class AddSpecificTaskPresenter {
    private weak var view: AddSpecificTaskViewController?
    private var taskRepository: SpecificTaskRepository
    private var reminderManager: ReminderManaging
    private var calendarManager: CalendarManaging
    private var tagRepository: TagRepository
    private var tags: [Tag]
    
    init(_ view: AddSpecificTaskViewController, _ taskRepository: SpecificTaskRepository, _ reminderManager: ReminderManaging, _ calendarManager: CalendarManaging, _ tagRepository: TagRepository) {
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
        
        return TagDto(name: tag.name!, color: tag.color!)
    }
        
    public func addTask(name: String, description: String, scheduledDate: Date, duration: Int64, addToReminder: Bool, addToCalendar: Bool, tagsIndexes: [Int]) throws  {
        let id = UUID()
        let selectedTags = tagsIndexes.map { tags[$0] }
        let tagsSet = NSSet(array: selectedTags)
        let endDate = scheduledDate.addingTimeInterval(Double(duration) * 60)
        if (addToCalendar) {
            if (!calendarManager.create(eventModel: CalendarEventModel(title: name, startDate: scheduledDate, endDate: endDate, note: description))) {
                let error = NSError(domain: "EventKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка добавления в календарь. Разрешите добавление в календарь и попробуйте снова."])
                throw error
            }
        }
        if (addToReminder) {
            if (!reminderManager.create(reminderModel: ReminderEventModel(title: name, startDate: scheduledDate, dueDate: endDate, note: description))) {
                let error = NSError(domain: "EventKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка добавления в напоминания. Разрешите добавление в напоминания и попробуйте снова."])
                throw error
            }
        }
        taskRepository.createTask(id: id, name: name, isCompleted: false, taskDescription: description, tags: tagsSet, duration: duration, scheduledDate: scheduledDate, generalTask: nil)
    }
}
