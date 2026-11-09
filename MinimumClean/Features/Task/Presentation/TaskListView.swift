//
//  TaskListView.swift
//  MinimumClean
//
//  Presentation Layer: View.
//  Accesses to and receives data from ViewModel.
//

import SwiftUI

public struct TaskListView: View {
    @State private var viewModel: TaskViewModel
    @State private var isShowingAddSheet = false
    @State private var newTitle = ""
    @State private var newCategory = "Development"
    @State private var newPriority: TaskItem.Priority = .medium

    public init(viewModel: TaskViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Architecture Layer Indicator
                architectureOverviewCard
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Filter Selector
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(TaskViewModel.FilterOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                // Task List Content
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    Spacer()
                    ProgressView("Fetching tasks...")
                        .tint(.accentColor)
                    Spacer()
                } else if viewModel.filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskList
                }
            }
            .navigationTitle("Clean Architecture")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .task {
                if viewModel.tasks.isEmpty {
                    await viewModel.loadTasks()
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                addTaskSheet
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Subviews

    private var architectureOverviewCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Architecture Flow", systemImage: "square.3.layers.3d.down.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Isolated Domain")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }

            HStack(spacing: 4) {
                architectureBadge(name: "Data", sub: "Repo + Mapper", color: .purple)
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                architectureBadge(name: "Domain", sub: "Protocol + Struct", color: .blue)
                Image(systemName: "arrow.left")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                architectureBadge(name: "Presentation", sub: "VM + View", color: .green)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func architectureBadge(name: String, sub: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(sub)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                taskRow(task)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.loadTasks()
        }
    }

    private func taskRow(_ task: TaskItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                Task {
                    await viewModel.toggleTask(id: task.id)
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    Text(task.category)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())

                    Label(task.dueDateFormatted, systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Label(task.priority.rawValue, systemImage: task.priority.systemImage)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(priorityColor(for: task.priority))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checklist.checked")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No tasks found")
                .font(.headline)
            Text("Add a new task or change the filter to see items.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var addTaskSheet: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $newTitle)
                    TextField("Category", text: $newCategory)
                }

                Section("Priority") {
                    Picker("Priority", selection: $newPriority) {
                        ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                            Label(priority.rawValue, systemImage: priority.systemImage)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Text("Flow: Adding a task creates a raw TaskDTO in the Repository, converts it via TaskMapper to a TaskItem UI Struct, and updates the ViewModel.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }
                        let category = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
                        Task {
                            await viewModel.addTask(
                                title: trimmedTitle,
                                category: category.isEmpty ? "General" : category,
                                priority: newPriority
                            )
                            newTitle = ""
                            isShowingAddSheet = false
                        }
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func priorityColor(for priority: TaskItem.Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

#Preview {
    TaskListView(
        viewModel: TaskViewModel(
            repository: TaskRepository(seedDummyData: true)
        )
    )
}
