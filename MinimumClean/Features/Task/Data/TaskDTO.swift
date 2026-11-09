//
//  TaskDTO.swift
//  MinimumClean
//
//  Data Layer: Raw Data Model / DTO.
//  Represents raw records from data sources like CloudKit CKRecord or APIs.
//

import Foundation

public struct TaskDTO: Sendable {
    public let recordId: String
    public let recordTitle: String?
    public let recordCategory: String?
    public let timestampEpochSeconds: TimeInterval?
    public let rawPriorityLevel: Int? // 1: Low, 2: Medium, 3: High
    public let isFlaggedDone: Int?     // 0: false, 1: true

    public nonisolated init(
        recordId: String,
        recordTitle: String?,
        recordCategory: String?,
        timestampEpochSeconds: TimeInterval?,
        rawPriorityLevel: Int?,
        isFlaggedDone: Int?
    ) {
        self.recordId = recordId
        self.recordTitle = recordTitle
        self.recordCategory = recordCategory
        self.timestampEpochSeconds = timestampEpochSeconds
        self.rawPriorityLevel = rawPriorityLevel
        self.isFlaggedDone = isFlaggedDone
    }
}
