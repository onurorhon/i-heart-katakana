//
//  IHeartKatakanaApp.swift
//  IHeartKatakana
//
//  Created by Onur Orhon on 1/18/26.
//

import SwiftUI
import SwiftData

@main
struct IHeartKatakanaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LikedWord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
