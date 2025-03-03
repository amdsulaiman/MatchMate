//
//  MatchListView.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.

import SwiftUI

struct MatchListView: View {
    @StateObject private var viewModel = MatchCardViewModel()
    @State private var lastVisibleId: UUID? = nil // Track the last visible user ID

    var body: some View {
        NavigationView {
            ScrollViewReader { scrollViewProxy in
                contentView
                    .navigationTitle("Matches")
                    .onAppear {
                        viewModel.loadUsers(isInitialLoad: true)
                    }
                    .onChange(of: viewModel.users.last?.id) { newId in
                        if let lastVisibleId = lastVisibleId {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastVisibleId, anchor: .bottom)
                            }
                        }
                    }
            }
        }
    }

    // Main content of the view
    private var contentView: some View {
        Group {
            if viewModel.isLoading && viewModel.users.isEmpty {
                loadingView
            } else if viewModel.users.isEmpty {
                emptyStateView
            } else {
                userListView
            }
        }
    }

    // Loading spinner for initial data load
    private var loadingView: some View {
        VStack {
            ProgressView("Loading users...")
                .padding()
            Text("Fetching the latest matches. Please wait!")
                .foregroundColor(.gray)
        }
    }

    // View to display when there are no users available
    private var emptyStateView: some View {
        VStack {
            Text(viewModel.errorMessage ?? "No users available.")
                .foregroundColor(.red)
                .padding()
            Image(systemName: "person.3")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
        }
    }

    // Updated List of User Cards with Offline Support
    private var userListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.users, id: \.id) { user in
                    MatchCardView(
                        user: user,
                        isOffline: !viewModel.isConnected,
                        onAccept: {
                            viewModel.acceptUser(user)
                        },
                        onDecline: {
                            viewModel.declineUser(user)
                        }
                    )
                    .id(user.id) // Set the ID for scrolling
                    .onAppear {
                        // Check if the current user is the last one in the list
                        if user == viewModel.users.last && !viewModel.isFetching {
                            lastVisibleId = user.id // Update the last visible ID
                            viewModel.loadUsers()
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView("Loading more users...")
                        .padding()
                }
            }
            .padding(.top, 16)
        }
    }
}
