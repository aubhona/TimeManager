//
//  GeneralTaskSearchPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import Foundation

internal final class GeneralTaskSearchPresenter {
    private weak var view: GeneralTaskSearchViewController?
    private var taskRepository: GeneralTaskRepository
    private var tasks: [GeneralTask] = [GeneralTask]()
    
    init(_ view: GeneralTaskSearchViewController? = nil, _ taskRepository: GeneralTaskRepository) {
        self.view = view
        self.taskRepository = taskRepository
    }
    
    public func filterTask(searchName: String) {
        tasks = taskRepository.getTasksByName(name: searchName)
    }
    
    public func getFoundTaskCount() -> Int {
        return tasks.count
    }
    
    public func getFoundTask(index: Int) -> GeneralTaskDto {
        let generalTask = tasks[index]
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        let tags = (generalTask.tags!.allObjects as! [Tag]).compactMap { TagDto(id: $0.id!, name: $0.name!, color: $0.color!) }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
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
        
        return taskDto
    }
}
