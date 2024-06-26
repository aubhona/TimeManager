//
//  ReminderManager.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 26.03.2024.
//

import EventKit

internal final class ReminderManager: ReminderManaging {
    private let eventStore = EKEventStore()
    
    func create(reminderModel: ReminderEventModel) -> Bool {
        var result: Bool = false
        let group = DispatchGroup()
        group.enter()
        create(reminderModel: reminderModel) { isCreated in
            result = isCreated
            group.leave()
        }
        group.wait()
        return result
    }
    
    func create(reminderModel: ReminderEventModel, completion: ((Bool) -> Void)?) {
        let createEvent: EKEventStoreRequestAccessCompletionHandler = { [weak self] (granted, error) in
            guard granted, error == nil, let self else {
                completion?(false)
                return
            }
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = reminderModel.title
            reminder.notes = reminderModel.note
            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            var alarm: EKAlarm = EKAlarm(relativeOffset: -24 * 3600)
            if let date = reminderModel.startDate {
                let startDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                reminder.startDateComponents = startDateComponents
                alarm = EKAlarm(relativeOffset: -15 * 60)
            }
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderModel.dueDate)
            reminder.dueDateComponents = dueDateComponents
            reminder.addAlarm(alarm)
            do {
                try self.eventStore.save(reminder, commit: true)
            } catch let error as NSError {
                print("failed to save event with error : \(error)")
                completion?(false)
                return
            }
            completion?(true)
        }
        
        eventStore.requestFullAccessToReminders(completion: createEvent)
    }
}
