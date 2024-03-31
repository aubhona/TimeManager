//
//  GeneralTaskDescriptionPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 30.03.2024.
//

import Foundation

internal final class GeneralTaskDescriptionPresenter {
    
    private var tasks: [SpecificTask] = [SpecificTask]()
    private weak var view: GeneralTaskDescriptionViewController?
    private var generalTaskRepository: GeneralTaskRepository
    private var specificTaskRepository: SpecificTaskRepository
    private var generalTaskDto: GeneralTaskDto
    
    init(_ view: GeneralTaskDescriptionViewController?, _ generalTaskRepository: GeneralTaskRepository, _ specificTaskRepository: SpecificTaskRepository, _ generalTaskDto: GeneralTaskDto) {
        self.view = view
        self.generalTaskRepository = generalTaskRepository
        self.specificTaskRepository = specificTaskRepository
        self.generalTaskDto = generalTaskDto
        tasks = generalTaskRepository.getTaskById(id: generalTaskDto.id)?.specificTasks?.allObjects.compactMap { $0 as? SpecificTask } ?? []
    }
    
    public func updateViewGeneralTask() {
        if let task = view?.task {
            guard let generalTask = generalTaskRepository.getTaskById(id: task.id) else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
            let tags = (generalTask.tags!.allObjects as! [Tag]).compactMap { TagDto(id: $0.id!, name: $0.name!, color: $0.color!) }
            let specificTasks = generalTask.specificTasks!.allObjects.compactMap { $0 as? SpecificTask }
            let taskDto = GeneralTaskDto(
                id: generalTask.id!,
                name: generalTask.name!,
                isCompleted: generalTask.isCompleted,
                taskDescription: generalTask.taskDescription!,
                deadlineDate: dateFormatter.string(from: generalTask.deadlineDate!),
                skipped: generalTask.deadlineDate! < Date(),
                tags: tags,
                isFire: calendar.startOfDay(for: generalTask.deadlineDate!) == calendar.startOfDay(for: Date()),
                doneCount: specificTasks.filter { $0.isCompleted }.count,
                generalCount: specificTasks.count)
            
            view?.task = taskDto
            view?.updateInputs()
        }
    }
    
    public func getSpecificTasksCount() -> Int {
        tasks = generalTaskRepository.getTaskById(id: generalTaskDto.id)?.specificTasks?.allObjects.compactMap { $0 as? SpecificTask } ?? []
        
        return tasks.count
    }
    
    public func getSpecificTask(index: Int) -> SpecificTaskDto {
        let specificTask = tasks[index]
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        
        let endDate = (specificTask.scheduledDate?.addingTimeInterval(Double(specificTask.duration) * 60))!
        let tags = (specificTask.tags!.allObjects as! [Tag]).compactMap { TagDto(id: $0.id!, name: $0.name!, color: $0.color!) }
        let specificTaskDto = SpecificTaskDto(
            id: specificTask.id!,
            name: specificTask.name!,
            isCompleted: specificTask.isCompleted,
            taskDescription: specificTask.taskDescription!,
            scheduledStartTime: timeFormatter.string(from: specificTask.scheduledDate!),
            scheduledEndTime: timeFormatter.string(from: endDate),
            sheduledDate: dateFormatter.string(from: specificTask.scheduledDate!) + " (\(specificTask.duration / 60) ч, \(specificTask.duration % 60) мин)",
            skipped: endDate < Date(),
            tags: tags
        )
        if let generalTask = specificTask.generalTask {
            let specificTasks = generalTask.specificTasks!.allObjects.compactMap { $0 as? SpecificTask }
            specificTaskDto.generalTask = GeneralTaskDto(
                id: generalTask.id!,
                name: generalTask.name!,
                isCompleted: generalTask.isCompleted,
                taskDescription: generalTask.taskDescription!,
                deadlineDate: dateFormatter.string(from: generalTask.deadlineDate!),
                skipped: generalTask.deadlineDate! < Date(),
                tags: tags,
                isFire: calendar.startOfDay(for: generalTask.deadlineDate!) == calendar.startOfDay(for: Date()),
                doneCount: specificTasks.filter { $0.isCompleted }.count,
                generalCount: specificTasks.count)
        }
        
        return specificTaskDto
    }
    
    public func toggleSpecificTaskComplete(index: Int) {
        let task = tasks[index]
        task.isCompleted = !task.isCompleted
        
        specificTaskRepository.updateTask(
            id: task.id!,
            name: task.name!,
            isCompleted: task.isCompleted,
            taskDescription: task.taskDescription!,
            tags: task.tags ?? NSSet(),
            duration: task.duration,
            scheduledDate: task.scheduledDate,
            generalTask: task.generalTask
        )
        if let generalTask = generalTaskRepository.getTaskById(id: task.generalTask?.id ?? UUID()) {
            guard let specificTasks = generalTask.specificTasks?.allObjects as? [SpecificTask] else { return }
            let oldValue = generalTask.isCompleted
            generalTask.isCompleted = specificTasks.allSatisfy{ $0.isCompleted }
            if  (oldValue != generalTask.isCompleted) {
                generalTaskRepository.updateTask(
                    id: generalTask.id!,
                    name: generalTask.name!,
                    isCompleted: generalTask.isCompleted,
                    taskDescription: generalTask.taskDescription!,
                    tags: generalTask.tags ?? NSSet(),
                    deadlineDate: generalTask.deadlineDate!,
                    specificTasks: generalTask.specificTasks
                )
            }
        }
    }
    
    public func deleteSpecificTask(taskId: UUID) {
        specificTaskRepository.deleteTask(id: taskId)
    }
}
