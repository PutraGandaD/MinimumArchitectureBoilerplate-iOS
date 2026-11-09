//
//  ContentView.swift
//  MinimumClean
//
//  Created by Putra Ganda Dewata on 09/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel: TaskViewModel

    init(repository: (any TaskRepositoryProtocol)? = nil) {
        let repo = repository ?? TaskRepository(seedDummyData: true)
        _viewModel = State(initialValue: TaskViewModel(repository: repo))
    }

    var body: some View {
        TaskListView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
