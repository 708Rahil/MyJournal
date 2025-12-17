//
//  MyJournalApp.swift
//  MyJournal
//
//  Created by Rahil Gandhi on 2025-12-16.
//

import SwiftUI
import CoreData


@main
struct MyJournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
