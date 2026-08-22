//
//  PDDropDownSwitfUIApp.swift
//  PDDropDownSwitfUI
//
//  Created by pavan dhakar on 22/08/26.
//

import SwiftUI
import CoreData

@main
struct PDDropDownSwitfUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
