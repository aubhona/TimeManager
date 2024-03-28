//
//  GeneralTaskDto.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 28.03.2024.
//
import Foundation

public final class GeneralTaskDto {
    public var id: UUID
    public var name: String
    public var isCompleted: Bool
    public var taskDescription: String
    public var deadlineDate: String
    public var skipped: Bool
    public var tags: [TagDto]
    public var isFire: Bool
    public var doneCount: Int
    public var generalCount: Int
    
    init(id: UUID, name: String, isCompleted: Bool, taskDescription: String, deadlineDate: String, skipped: Bool, tags: [TagDto], isFire: Bool, doneCount: Int, generalCount: Int) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.taskDescription = taskDescription
        self.deadlineDate = deadlineDate
        self.skipped = skipped
        self.tags = tags
        self.isFire = isFire
        self.doneCount = doneCount
        self.generalCount = generalCount
    }
}

