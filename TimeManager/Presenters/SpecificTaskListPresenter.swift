//
//  SpecificTaskListPresenter.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import Foundation

public final class SpecificTaskListPresenter {
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
    
    private var firstWeekDay: Date = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let currentDate = Date()
        if let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) {
            let sundayStartOfDay = calendar.startOfDay(for: sunday)
            
            if let firstWeekDay = calendar.date(byAdding: .day, value: 1, to: sundayStartOfDay) {
                return firstWeekDay
            }
        }
        
        return calendar.startOfDay(for: currentDate)
    }()
    
    private var selectedDay: Date = Date.now
    private var tasks: [SpecificTask] = [SpecificTask]()
    private weak var view: SpecificTaskListViewController?
    private var taskRepository: SpecificTaskRepository
    
    init(_ view: SpecificTaskListViewController, _ taskRepository: SpecificTaskRepository) {
        self.view = view
        self.taskRepository = taskRepository
        tasks = taskRepository.getTasksByDate(date: selectedDay)
        tasks.sort(by: { return $0.scheduledDate ?? Date() < $1.scheduledDate ?? Date() })
    }
    
    func setCurrentMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Constants.identidier)
        dateFormatter.setLocalizedDateFormatFromTemplate(Constants.monthFormat)
        let monthName = dateFormatter.string(from: selectedDay).capitalized
        dateFormatter.dateFormat = Constants.yearFormat
        let year = dateFormatter.string(from: selectedDay)
        
        view?.displayCurrentMonth(date: "\(monthName.capitalized), \(year)")
    }
    
    func getWeeksCount() -> Int {
        return Constants.weeksCount
    }
    
    func getStartWeek() -> Int {
        return Constants.startWeek
    }
    
    func getWeek(weekIndex: Int) -> [(Int, String)] {
        var days = [(Int, String)]()
        var calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Constants.identidier)
        dateFormatter.dateFormat = Constants.weekFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let weeksDifference = weekIndex - getStartWeek()
        
        guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: weeksDifference, to: firstWeekDay) else {
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
    
    func getSelectedDay() -> Int {
        let weekDay = Calendar.current.component(.weekday, from: selectedDay) - Constants.weekOffset
        return weekDay >= 0 ? weekDay : weekDay + Constants.daysOfWeek
    }
    
    func setSelectedDay(weekDay: Int) {
        let calendar = Calendar.current
        let currentWeekday = getSelectedDay()
        let dayOffset = weekDay - currentWeekday
        
        if let newSelectedDay = calendar.date(byAdding: .day, value: dayOffset, to: selectedDay) {
            selectedDay = newSelectedDay
        }
    }
    
    func addWeekToSelectedDay(weekIndex: Int) {
        let weeksDifference = weekIndex - getStartWeek()
        guard let weekStartDate = Calendar.current.date(byAdding: .weekOfYear, value: weeksDifference, to: firstWeekDay) else {
            return
        }
        
        if let newSelectedDay = Calendar.current.date(byAdding: .day, value: weekStartDate < selectedDay ? -Constants.daysOfWeek : Constants.daysOfWeek, to: selectedDay) {
            selectedDay = newSelectedDay
        }
    }
    
    func getTasksCount() -> Int {
        tasks = taskRepository.getTasksByDate(date: selectedDay)
        tasks.sort(by: { return $0.scheduledDate ?? Date() < $1.scheduledDate ?? Date() })
        
        return tasks.count
    }
    
    func getTask(index: Int) -> SpecificTaskDto {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = Constants.timeFormat
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        
        let specificTask = tasks[index]
        
        let endDate = (specificTask.scheduledDate?.addingTimeInterval(Double(specificTask.duration) * Constants.minutesCount))!
        let tags = (specificTask.tags!.allObjects as! [Tag]).compactMap { TagDto(name: $0.name!, color: $0.color!) }
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
        
        return specificTaskDto
    }
    
    func completeTask(index: Int) {
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
}
