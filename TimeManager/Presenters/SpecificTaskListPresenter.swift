//
//  SpecificTaskListPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import Foundation

internal final class SpecificTaskListPresenter : Presenter {
    private enum Constants {
        static let identidier: String = "ru"
        
        static let monthFormat: String = "MMMM"
        static let yearFormat: String = "yyyy"
        static let weekFormat: String = "E"
        static let timeFormat: String = "HH:mm"
        
        static let weeksCount: Int = 10000
        static let minutesCount: Double = 60
        
        static let startWeek: Int = 5000
        static let daysOfWeek: Int = 7
        static let weekOffset: Int = 2
    }
    
    var tags: [TagDto]
    private(set) public var selectedDay: Date = Date.now
    private(set) public var currentWeekIndex: Int = Constants.startWeek
    private var tasks: [SpecificTask] = [SpecificTask]()
    private weak var view: SpecificTaskListViewController?
    private var taskRepository: SpecificTaskRepository
    
    init(_ view: SpecificTaskListViewController, _ taskRepository: SpecificTaskRepository) {
        self.view = view
        self.taskRepository = taskRepository
        tasks = taskRepository.getTasksByDate(date: selectedDay)
        tasks.sort(by: { return $0.scheduledDate ?? Date() < $1.scheduledDate ?? Date() })
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
    
    func filterTasksByTagIDs() {
        let tagIDs = Set(tags.map { $0.id })
        tasks = tasks.filter { task in
            guard let taskTags = task.tags as? Set<Tag> else { return false }
            
            return taskTags.contains(where: { tag in
                tagIDs.contains(tag.id ?? UUID())
            })
        }
    }
    
    func setCurrentMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Constants.identidier)
        dateFormatter.setLocalizedDateFormatFromTemplate(Constants.monthFormat)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let monthName = dateFormatter.string(from: selectedDay).capitalized
        dateFormatter.dateFormat = Constants.yearFormat
        let year = dateFormatter.string(from: selectedDay)
        
        view?.displayCurrentMonth(date: "\(monthName.capitalized), \(year)")
    }
    
    private func getFirstWeekDay(date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let currentDate = date
        if let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) {
            let sundayStartOfDay = calendar.startOfDay(for: sunday)
            
            if let firstWeekDay = calendar.date(byAdding: .day, value: 1, to: sundayStartOfDay) {
                return firstWeekDay
            }
        }
        
        return calendar.startOfDay(for: currentDate)
    }
    
    private func firstWeekDay() -> Date {
        return getFirstWeekDay(date: selectedDay)
    }
    
    func getWeeksCount() -> Int {
        return Constants.weeksCount
    }
    
    func getWeek(weekIndex: Int) -> [(Int, String)] {
        var days = [(Int, String)]()
        var calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Constants.identidier)
        dateFormatter.dateFormat = Constants.weekFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let weeksDifference = weekIndex - currentWeekIndex
        
        guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: weeksDifference, to: firstWeekDay()) else {
            return []
        }
        
        for dayOffset in 0..<Constants.daysOfWeek {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate) {
                let dayNumber = calendar.component(.day, from: date)
                let dayName = dateFormatter.string(from: date)
                days.append((dayNumber, dayName))
            }
        }
        
        return days
    }
    
    func getWeekDay(date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let weekDay = calendar.component(.weekday, from: date) - Constants.weekOffset
        return weekDay >= 0 ? weekDay : weekDay + Constants.daysOfWeek
    }
    
    func getSelectedWeekDay() -> Int {
        return getWeekDay(date: selectedDay)
    }
    
    func setSelectedDay(date: Date) {
        let weekDifference = (Calendar.current.dateComponents([.weekOfYear], from: firstWeekDay(), to: getFirstWeekDay(date: date)).weekOfYear ?? 0)
        addWeekToSelectedDay(weekIndex: currentWeekIndex + weekDifference, getWeekDay(date: date))
        view?.scrollToWeekIndex(weekIndex: currentWeekIndex + weekDifference)
        
    }
    
    func setSelectedDay(weekDay: Int) {
        let calendar = Calendar.current
        let currentWeekday = getSelectedWeekDay()
        let dayOffset = weekDay - currentWeekday
        
        if let newSelectedDay = calendar.date(byAdding: .day, value: dayOffset, to: selectedDay) {
            selectedDay = newSelectedDay
        }
    }
    
    func addWeekToSelectedDay(weekIndex: Int, _ weekday: Int = -1) {
        let weeksDifference = weekIndex - currentWeekIndex
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: weeksDifference, to: firstWeekDay()) else {
            return
        }
        let weekdayOffset = weekday == -1 ? getSelectedWeekDay() : weekday
        if let newSelectedDay = calendar.date(byAdding: .day, value: weekdayOffset, to: weekStartDate) {
            selectedDay = newSelectedDay
            currentWeekIndex = weekIndex
            tasks = taskRepository.getTasksByDate(date: selectedDay)
            tasks.sort(by: { return $0.scheduledDate ?? Date() < $1.scheduledDate ?? Date() })
            filterTasksByTagIDs()
        }
    }
    
    func getTasksCount() -> Int {
        tasks = taskRepository.getTasksByDate(date: selectedDay)
        tasks.sort(by: { return $0.scheduledDate ?? Date() < $1.scheduledDate ?? Date() })
        filterTasksByTagIDs()
        
        return tasks.count
    }
    
    func getTask(index: Int) -> SpecificTaskDto {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = Constants.timeFormat
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        
        let specificTask = tasks[index]
        
        let endDate = (specificTask.scheduledDate?.addingTimeInterval(Double(specificTask.duration) * Constants.minutesCount))!
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
