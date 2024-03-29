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
    private var specificTaskRepository: SpecificTaskRepository
    private var generalTaskRepository: GeneralTaskRepository
    private var reminderManager: ReminderManaging
    private var calendarManager: CalendarManaging
    private var tagRepository: TagRepository
    private var tags: [Tag]
    private var task: SpecificTaskDto?
    
    init(_ view: AddSpecificTaskViewController, _ specificTaskRepository: SpecificTaskRepository, _ generalTaskRepository: GeneralTaskRepository, _ reminderManager: ReminderManaging, _ calendarManager: CalendarManaging, _ tagRepository: TagRepository) {
        self.view = view
        self.specificTaskRepository = specificTaskRepository
        self.generalTaskRepository = generalTaskRepository
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
    
    public func fillInputFileds(task: SpecificTaskDto, generalTaskDto: GeneralTaskDto? = nil) {
        self.task = task
        guard let specificTask = specificTaskRepository.getTaskById(id: task.id) else { return }
        let selectedTagsIndexes = task.tags.compactMap { tag in
            tags.firstIndex(where: { $0.id == tag.id })
        }
        view?.setInputFields(
            name: task.name,
            description: task.taskDescription,
            date: specificTask.scheduledDate ?? Date(),
            hourDuration: String(specificTask.duration / 60),
            minuteDuration: String(specificTask.duration % 60), 
            generalTask: generalTaskDto,
            selectedTagsIndexes: selectedTagsIndexes
        )
    }
    
    public func addTask(name: String, description: String, scheduledDate: Date, duration: Int64, addToReminder: Bool, addToCalendar: Bool, generalTaskId: UUID? = nil, tagsIndexes: [Int]) throws  {
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
        var generalTask: GeneralTask? = nil
        if let generalTaskId = generalTaskId {
            generalTask = generalTaskRepository.getTaskById(id: generalTaskId)
        }
        
        if (task != nil) {
            specificTaskRepository.updateTask(id: task!.id, name: name, isCompleted: generalTask?.isCompleted ?? false, taskDescription: description, tags: tagsSet, duration: duration, scheduledDate: scheduledDate, generalTask: generalTask)
            return
        }
        let id = UUID()
        specificTaskRepository.createTask(id: id, name: name, isCompleted: generalTask?.isCompleted ?? false, taskDescription: description, tags: tagsSet, duration: duration, scheduledDate: scheduledDate, generalTask: generalTask)
    }
}
