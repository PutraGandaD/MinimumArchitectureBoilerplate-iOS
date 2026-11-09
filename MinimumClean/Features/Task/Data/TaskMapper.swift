//
//  TaskMapper.swift
//  MinimumClean
//
//  Data Layer: Mapper (3).
//  Maps raw data (e.g. CloudKit records / TaskDTO) to Domain UI Struct (4).
//

import Foundation

public struct TaskMapper: Sendable {
    public nonisolated init() {}

    /// Maps a raw TaskDTO into a domain TaskItem UI struct.
    public nonisolated func map(from raw: TaskDTO) -> TaskItem {
        let title = raw.recordTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle: String
        if let title = title, !title.isEmpty {
            resolvedTitle = title
        } else {
            resolvedTitle = "Untitled Task"
        }

        let resolvedCategory = raw.recordCategory ?? "General"

        let formattedDate: String
        if let timestamp = raw.timestampEpochSeconds {
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formattedDate = formatter.string(from: date)
        } else {
            formattedDate = "No Due Date"
        }

        let priority: TaskItem.Priority
        switch raw.rawPriorityLevel {
        case 3:
            priority = .high
        case 2:
            priority = .medium
        default:
            priority = .low
        }

        let isCompleted = (raw.isFlaggedDone == 1)

        return TaskItem(
            id: raw.recordId,
            title: resolvedTitle,
            category: resolvedCategory,
            dueDateFormatted: formattedDate,
            priority: priority,
            isCompleted: isCompleted
        )
    }

    /// Maps an array of raw TaskDTOs into domain TaskItem UI structs.
    public nonisolated func mapList(from rawList: [TaskDTO]) -> [TaskItem] {
        rawList.map { map(from: $0) }
    }
}
