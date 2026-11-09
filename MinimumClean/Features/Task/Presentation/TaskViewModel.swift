//
//  TaskViewModel.swift
//  MinimumClean
//
//  Presentation Layer: View Model.
//  Accesses the repository strictly through the repository protocol
//  from the Domain layer. Manages UI state for the View.
//

import Foundation
import Observation

@Observable
@MainActor
public final class TaskViewModel {
    // Injected repository protocol reference (Domain)
    private let repository: any TaskRepositoryProtocol

    // UI state observable by Views
    public var tasks: [TaskItem] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var selectedFilter: FilterOption = .all

    public enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"

        public var id: String { rawValue }
    }

    public var filteredTasks: [TaskItem] {
        switch selectedFilter {
        case .all:
            return tasks
        case .pending:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }

    public init(repository: any TaskRepositoryProtocol) {
        self.repository = repository
    }

    public func loadTasks() async {
        isLoading = true
        errorMessage = nil
        do {
            tasks = try await repository.fetchTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func toggleTask(id: String) async {
        do {
            let updated = try await repository.toggleTask(id: id)
            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func addTask(title: String, category: String, priority: TaskItem.Priority) async {
        do {
            let created = try await repository.addTask(title: title, category: category, priority: priority)
            tasks.append(created)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
