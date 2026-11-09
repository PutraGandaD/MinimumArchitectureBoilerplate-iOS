//
//  TaskRepository.swift
//  MinimumClean
//
//  Data Layer: Repository Implementation (2).
//  Implements TaskRepositoryProtocol (1). Fetches raw records (e.g. from CloudKit
//  or simulated CloudKit/dummy storage), then uses TaskMapper (3) to return
//  UI structs (4) to the caller.
//

import Foundation

public actor TaskRepository: TaskRepositoryProtocol {
    private let mapper: TaskMapper
    private var rawRecords: [TaskDTO]

    public init(mapper: TaskMapper = TaskMapper(), seedDummyData: Bool = true) {
        self.mapper = mapper
        if seedDummyData {
            let now = Date().timeIntervalSince1970
            self.rawRecords = [
                TaskDTO(
                    recordId: "CK_REC_101",
                    recordTitle: "Define Domain Repository Protocol",
                    recordCategory: "Architecture",
                    timestampEpochSeconds: now + 3600,
                    rawPriorityLevel: 3,
                    isFlaggedDone: 1
                ),
                TaskDTO(
                    recordId: "CK_REC_102",
                    recordTitle: "Build Mapper to Convert Raw DTO to UI Struct",
                    recordCategory: "Data Layer",
                    timestampEpochSeconds: now + 7200,
                    rawPriorityLevel: 3,
                    isFlaggedDone: 1
                ),
                TaskDTO(
                    recordId: "CK_REC_103",
                    recordTitle: "Implement Real / Dummy Repository with CloudKit simulation",
                    recordCategory: "Data Layer",
                    timestampEpochSeconds: now + 14400,
                    rawPriorityLevel: 2,
                    isFlaggedDone: 0
                ),
                TaskDTO(
                    recordId: "CK_REC_104",
                    recordTitle: "Connect Presentation ViewModel via Protocol",
                    recordCategory: "Presentation",
                    timestampEpochSeconds: now + 86400,
                    rawPriorityLevel: 1,
                    isFlaggedDone: 0
                )
            ]
        } else {
            self.rawRecords = []
        }
    }

    /// Fetches raw records and maps them to UI structs using the mapper.
    public func fetchTasks() async throws -> [TaskItem] {
        // Simulates network / CloudKit query latency
        try await Task.sleep(nanoseconds: 300_000_000)
        return mapper.mapList(from: rawRecords)
    }

    /// Toggles the completion state in raw storage and returns mapped UI struct.
    public func toggleTask(id: String) async throws -> TaskItem {
        guard let index = rawRecords.firstIndex(where: { $0.recordId == id }) else {
            throw RepositoryError.taskNotFound
        }

        let existing = rawRecords[index]
        let toggledDone = (existing.isFlaggedDone == 1) ? 0 : 1
        let updatedDTO = TaskDTO(
            recordId: existing.recordId,
            recordTitle: existing.recordTitle,
            recordCategory: existing.recordCategory,
            timestampEpochSeconds: existing.timestampEpochSeconds,
            rawPriorityLevel: existing.rawPriorityLevel,
            isFlaggedDone: toggledDone
        )
        rawRecords[index] = updatedDTO
        return mapper.map(from: updatedDTO)
    }

    /// Appends a new raw DTO and returns the mapped UI struct.
    public func addTask(title: String, category: String, priority: TaskItem.Priority) async throws -> TaskItem {
        let rawPriority: Int
        switch priority {
        case .high: rawPriority = 3
        case .medium: rawPriority = 2
        case .low: rawPriority = 1
        }

        let newDTO = TaskDTO(
            recordId: "CK_REC_\(UUID().uuidString.prefix(6))",
            recordTitle: title,
            recordCategory: category,
            timestampEpochSeconds: Date().timeIntervalSince1970 + 86400,
            rawPriorityLevel: rawPriority,
            isFlaggedDone: 0
        )
        rawRecords.append(newDTO)
        return mapper.map(from: newDTO)
    }

    public enum RepositoryError: LocalizedError {
        case taskNotFound

        public var errorDescription: String? {
            switch self {
            case .taskNotFound:
                return "The requested task was not found in the repository."
            }
        }
    }
}
