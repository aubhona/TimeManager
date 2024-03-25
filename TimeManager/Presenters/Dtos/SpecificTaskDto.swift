//
//  SpecificTaskDto.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//

import Foundation

class SpecificTaskDto {
    public var name: String
    public var isCompleted: Bool
    public var taskDescription: String
    public var scheduledStartTime: String
    public var scheduledEndTime: String
    public var scheduledDate: String
    
    init(name: String, isCompleted: Bool, taskDescription: String, scheduledStartTime: String, scheduledEndTime: String, sheduledDate: String) {
        self.name = name
        self.isCompleted = isCompleted
        self.taskDescription = taskDescription
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.scheduledDate = sheduledDate
    }
}
