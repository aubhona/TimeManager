//
//  TagDto.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 26.03.2024.
//

import Foundation

public struct TagDto: Hashable {
    var id: UUID
    var name: String
    var color: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func ==(lhs: TagDto, rhs: TagDto) -> Bool {
        return lhs.id == rhs.id
    }
}
