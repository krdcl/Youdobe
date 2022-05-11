//
//  YoudobeApp.swift
//  Youdobe
//
//  Created by Yurii Samoienko on 28.04.2022.
//

import SwiftUI
import IOSCode

@main
struct IOSYoudobeApp: App {
    let persistenceController = PersistenceController.shared
    
//    let youtubeDLWrapperPl: YoutubeDownloaderPl = YoutubeDownloader()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .on
        }
    }
    
    // MARK: Public Functions
    
    init() {
        
    }
}
