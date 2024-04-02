//
//  CalendarManager.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 26.03.2024.
//

import EventKit

internal final class CalendarManager: CalendarManaging {
    private let eventStore : EKEventStore = EKEventStore()
    
    func create(eventModel: CalendarEventModel) -> Bool {
        var result: Bool = false
        let group = DispatchGroup()
        group.enter()
        create(eventModel: eventModel) { isCreated in
            result = isCreated
            group.leave()
        }
        group.wait()
        return result
    }
    
    func create(eventModel: CalendarEventModel, completion: ((Bool) -> Void)?) {
        let createEvent: EKEventStoreRequestAccessCompletionHandler = { [weak self] (granted, error) in
            guard granted, error == nil, let self else {
                completion?(false)
                return
            }
            let event: EKEvent = EKEvent(eventStore: self.eventStore)
            event.title = eventModel.title
            event.startDate = eventModel.startDate
            event.endDate = eventModel.startDate
            event.isAllDay = true
            var alarm: EKAlarm = EKAlarm(relativeOffset: -24 * 3600)
            if let date = eventModel.endDate {
                event.endDate = date
                alarm = EKAlarm(relativeOffset: -15 * 60)
                event.isAllDay = false
            }
            event.notes = eventModel.note
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            event.addAlarm(alarm)
            do {
                try self.eventStore.save(event, span: .thisEvent)
            } catch let error as NSError {
                print("failed to save event with error : \(error)")
                completion?(false)
                return
            }
            completion?(true)
        }
        
        eventStore.requestFullAccessToEvents(completion: createEvent)
    }
}
