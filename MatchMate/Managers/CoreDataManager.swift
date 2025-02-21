//
//  CoreDataManager.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "MatchMate")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        removeDuplicates()
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // Creates a new UserProfile from a User object
    func createUserProfile(_ user: User) -> UserProfile {
        let profile = UserProfile(context: context)
        profile.id = user.id
        profile.name = "\(user.name.first) \(user.name.last)"
        profile.age = Int16(user.dob.age)
        profile.imageUrl = user.picture.large
        profile.status = "None"
        profile.city = user.location.city
        profile.country = user.location.country
        return profile
    }
    
    // Fetches a user profile by ID
    func fetchUser(by id: UUID) -> UserProfile? {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return try? context.fetch(fetchRequest).first
    }
    
    // Fetches all user profiles from Core Data
    func fetchUsers() -> [UserProfile] {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    // Saves a new user to Core Data, avoiding duplicates
    func saveUser(_ user: User) {
        // Check if the user already exists
        if fetchUser(by: user.id) != nil {
            print("User with id \(user.id) already exists. Skipping save.")
            return
        }
        
        let profile = UserProfile(context: context)
        profile.id = user.id
        profile.name = "\(user.name.first) \(user.name.last)"
        profile.age = Int16(user.dob.age)
        profile.imageUrl = user.picture.large
        profile.status = "None" // Default status
        profile.city = user.location.city
        profile.country = user.location.country
        saveContext()
    }
    
    // Updates the status of a user by ID
    func updateUserStatus(userId: UUID, status: String) {
        let users = fetchUsers()
        if let user = users.first(where: { $0.id == userId }) {
            user.status = status
            saveContext()
        }
    }
    
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save Core Data context: \(error)")
        }
    }
    
    // Removes duplicate user profiles from Core Data
    func removeDuplicates() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            let allUsers = try context.fetch(fetchRequest)
            var seenIds = Set<UUID>()
            for user in allUsers {
                if let id = user.id {
                    if seenIds.contains(id) {
                        context.delete(user) // Delete duplicate
                    } else {
                        seenIds.insert(id)
                    }
                }
            }
            saveContext()
        } catch {
            print("Failed to remove duplicates: \(error.localizedDescription)")
        }
    }
    
}
