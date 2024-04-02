//
//  SpecificTaskDto.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//

import Foundation

internal final class SpecificTaskDto {
    public var id: UUID
    public var name: String
    public var isCompleted: Bool
    public var taskDescription: String
    public var scheduledStartTime: String
    public var scheduledEndTime: String
    public var scheduledDate: String
    public var skipped: Bool
    public var generalTask: GeneralTaskDto?
    public var tags: [TagDto]
    
    init(id: UUID, name: String, isCompleted: Bool, taskDescription: String, scheduledStartTime: String, scheduledEndTime: String, sheduledDate: String, skipped: Bool, tags: [TagDto]) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.taskDescription = taskDescription
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.scheduledDate = sheduledDate
        self.skipped = skipped
        self.tags = tags
    }
}
