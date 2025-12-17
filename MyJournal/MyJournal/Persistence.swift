//
//  Persistence.swift
//  MyJournal
//
//  Created by Rahil Gandhi on 2025-12-16.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // The container that loads the model and manages saving
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "JournalModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
