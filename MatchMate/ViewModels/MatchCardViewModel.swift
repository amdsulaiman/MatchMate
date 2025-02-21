//
//  MatchCardViewModel.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.
//

import SwiftUI
import Combine
import Network

class MatchCardViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isConnected = true  // Network connectivity status
    
    private let coreDataManager = CoreDataManager.shared
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables: Set<AnyCancellable> = []
    
    private var unsyncedActions: [UUID: String] = [:]  // Queue for offline actions
    private var currentPage = 1
     var isFetching = false
    private var hasMorePages = true
    
    init() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                if isConnected {
                    self?.syncUnsyncedActions()  // Sync offline actions when back online
                }
            }
            .store(in: &cancellables)
    }
    
    /// Load users from API or Core Data (offline mode)
    func loadUsers(isInitialLoad: Bool = false) {
        guard !isFetching && hasMorePages else { return }
        isFetching = true
        isLoading = true
        
        if !isConnected {
            loadFromCoreData()
            return
        }
        
        NetworkManager.shared.fetchUsers(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetching = false
                self.isLoading = false
                
                switch result {
                case .success(let fetchedUsers):
                    if fetchedUsers.isEmpty {
                        self.hasMorePages = false
                    } else {
                        self.mergeAPIDataWithLocalData(fetchedUsers)
                        self.currentPage += 1
                    }
                case .failure:
                    self.errorMessage = "Unable to load data. Showing cached results."
                    self.loadFromCoreData()
                }
            }
        }
    }
    
    /// Load cached users from Core Data when offline
    private func loadFromCoreData() {
        let savedUsers = coreDataManager.fetchUsers()
        DispatchQueue.main.async {
            if savedUsers.isEmpty {
                self.errorMessage = "Offline mode: No cached data available."
            } else {
                self.users = savedUsers
            }
            self.isFetching = false
            self.isLoading = false
        }
    }
    

    private func mergeAPIDataWithLocalData(_ fetchedUsers: [User]) {
        let savedUsers = coreDataManager.fetchUsers()
        let savedUsersDict = Dictionary(uniqueKeysWithValues: savedUsers.map { ($0.id, $0) })

        var newUsers: [UserProfile] = []

        for apiUser in fetchedUsers {
            if let savedUser = savedUsersDict[apiUser.id] {
                savedUser.status = savedUser.status
                savedUser.name = "\(apiUser.name.first) \(apiUser.name.last)"
                savedUser.age = Int16(apiUser.dob.age)
                savedUser.imageUrl = apiUser.picture.large

                if savedUser.localImagePath == nil {
                    saveImageToDisk(from: apiUser.picture.large, for: apiUser.id) { localPath in
                        DispatchQueue.main.async {
                            savedUser.localImagePath = localPath
                        }
                    }
                }

                newUsers.append(savedUser)
            } else {
                let newUser = coreDataManager.createUserProfile(apiUser)
                saveImageToDisk(from: apiUser.picture.large, for: apiUser.id) { localPath in
                    DispatchQueue.main.async {
                        newUser.localImagePath = localPath
                    }
                }
                newUsers.append(newUser)
            }
        }

        DispatchQueue.main.async {
            self.users = newUsers
        }
    }

    
    
    /// Accept user & update Core Data & UI
    func acceptUser(_ user: UserProfile) {
        updateUserStatus(user, status: "Accepted")
    }
    
    ///Decline user & update Core Data & UI
    func declineUser(_ user: UserProfile) {
        updateUserStatus(user, status: "Declined")
    }
    
    ///Update user status & ensure UI updates immediately
    private func updateUserStatus(_ user: UserProfile, status: String) {
        coreDataManager.updateUserStatus(userId: user.id ?? UUID(), status: status)
        
        DispatchQueue.main.async {
            if let index = self.users.firstIndex(where: { $0.id == user.id }) {
                self.users[index].status = status  // UI updates immediately
                self.objectWillChange.send()  // SwiftUI refresh
            }
        }
        
        // If offline, queue for syncing later
        if !isConnected {
            unsyncedActions[user.id ?? UUID()] = status
        } else {
            syncUserStatus(userId: user.id ?? UUID(), status: status)
        }
    }
    
    ///Sync offline actions when back online
    private func syncUnsyncedActions() {
        for (userId, status) in unsyncedActions {
            syncUserStatus(userId: userId, status: status)
        }
        unsyncedActions.removeAll()
    }
    
    /// Placeholder: Sync user status to server (implement if API available)
    private func syncUserStatus(userId: UUID, status: String) {
        print("Syncing status \(status) for user \(userId)")
        // If API exists, send status update request
    }
    
    
    private func saveImageToDisk(from url: String, for userId: UUID?, completion: @escaping (String?) -> Void) {
        guard let userId = userId, let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }

        let fileManager = FileManager.default
        let fileName = "\(userId).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        //Download Image Asynchronously
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to download image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .background).async {
                do {
                    try data.write(to: fileURL)
                    DispatchQueue.main.async {
                        completion(fileURL.path)  // Return local path for Core Data storage
                    }
                } catch {
                    print("Failed to save image to disk: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
}
