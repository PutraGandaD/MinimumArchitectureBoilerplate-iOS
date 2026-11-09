//
//  TaskItem.swift
//  MinimumClean
//
//  Domain Layer: Isolated UI struct representing the domain/UI model.
//

import Foundation

public struct TaskItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let dueDateFormatted: String
    public let priority: Priority
    public var isCompleted: Bool

    public enum Priority: String, CaseIterable, Sendable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"

        public var systemImage: String {
            switch self {
            case .low: return "arrow.down.circle"
            case .medium: return "minus.circle"
            case .high: return "exclamationmark.circle"
            }
        }
    }

    public nonisolated init(
        id: String,
        title: String,
        category: String,
        dueDateFormatted: String,
        priority: Priority,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dueDateFormatted = dueDateFormatted
        self.priority = priority
        self.isCompleted = isCompleted
    }
}
