//
//  TaskRepositoryProtocol.swift
//  MinimumClean
//
//  Domain Layer: Repository protocol (isolated layer).
//  The domain defines what data operations exist without knowing
//  the concrete data source (CloudKit, local DB, memory, etc.).
//

import Foundation

public protocol TaskRepositoryProtocol: Sendable {
    /// Fetches tasks and returns mapped UI structs directly to the caller.
    func fetchTasks() async throws -> [TaskItem]

    /// Toggles the completion state of a task and returns the updated UI struct.
    func toggleTask(id: String) async throws -> TaskItem

    /// Adds a new task and returns the newly created UI struct.
    func addTask(title: String, category: String, priority: TaskItem.Priority) async throws -> TaskItem
}
