//
//  GeneralTaskListPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 28.03.2024.
//

import Foundation

internal final class GeneralTaskListPresenter {
    private(set) public var startDate: Date = Date.now
    private var tasks: [Date: [GeneralTask]] = [:]
    private weak var view: GeneralTaskListViewController?
    private var taskRepository: GeneralTaskRepository
    private var uniqueDeadlineDates: [Date] = [Date]()
    private var uniqueDeadlineDatesActivated: [Bool] = [Bool]()
    
    init(_ view: GeneralTaskListViewController? = nil, _ taskRepository: GeneralTaskRepository) {
        self.view = view
        self.taskRepository = taskRepository
        updateTasks()
    }
    
    public func updateTasks() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        tasks = [:]
        let dates = taskRepository.getExistingDates() 
        let filteredDates = dates.filter { calendar.startOfDay(for: $0) >= calendar.startOfDay(for: startDate) }
        let uniqueDates = Set(filteredDates.map { calendar.startOfDay(for: $0) })
        uniqueDeadlineDates = Array(uniqueDates).sorted()
        let oldDeadlineDatesActivated = uniqueDeadlineDatesActivated
        uniqueDeadlineDatesActivated = Array(repeating: false, count: uniqueDeadlineDates.count)
        for i in 0..<min(oldDeadlineDatesActivated.count, uniqueDeadlineDatesActivated.count) {
            uniqueDeadlineDatesActivated[i] = oldDeadlineDatesActivated[i]
        }
        uniqueDeadlineDates.forEach{
            let tasksForDate = taskRepository.getTasksByDate(date: $0)
            
            if tasks[$0] != nil {
                tasks[$0]! += tasksForDate
            } else {
                tasks[$0] = tasksForDate
            }
            tasks[$0]?.sort(by: { (task1, task2) -> Bool in
                return task1.deadlineDate! < task2.deadlineDate!
            })
        }
    }
    
    public func setStartDate(date: Date) {
        startDate = date
        updateTasks()
    }
    
    public func getDatesCount() -> Int {
        return uniqueDeadlineDates.count
    }
    
    public func toggleDate(dateIndex: Int) {
        uniqueDeadlineDatesActivated[dateIndex] = !uniqueDeadlineDatesActivated[dateIndex]
    }
    
    public func getTaskCountByDate(dateIndex: Int) -> Int {
        return uniqueDeadlineDatesActivated[dateIndex] ? tasks[uniqueDeadlineDates[dateIndex]]?.count ?? 0 : 0
    }
    
    public func getTaskByDate(dateIndex: Int, taskIndex: Int) -> GeneralTaskDto? {
        guard let generalTask = tasks[uniqueDeadlineDates[dateIndex]]?[taskIndex] else { return nil }
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
            taskDescription: generalTask.description,
            deadlineDate: dateFormatter.string(from: generalTask.deadlineDate!),
            skipped: generalTask.deadlineDate! < Date(),
            tags: tags,
            isFire: calendar.startOfDay(for: generalTask.deadlineDate!) == calendar.startOfDay(for: Date()),
            doneCount: specificTasks.filter { $0.isCompleted }.count,
            generalCount: specificTasks.count)
        
        return taskDto
    }
    
    public func getDateTitle(dateIndex: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy, EEEE"
        
        return dateFormatter.string(from: uniqueDeadlineDates[dateIndex])
    }
    
    func toggleTaskComplete(dateIndex: Int, taskIndex: Int) {
        let task = tasks[uniqueDeadlineDates[dateIndex]]![taskIndex]
        task.isCompleted = !task.isCompleted
        
        taskRepository.updateTask(
            id: task.id!,
            name: task.name!,
            isCompleted: task.isCompleted,
            taskDescription: task.taskDescription!,
            tags: task.tags ?? NSSet(),
            deadlineDate: task.deadlineDate!,
            specificTasks: task.specificTasks ?? NSSet()
        )
    }
}
