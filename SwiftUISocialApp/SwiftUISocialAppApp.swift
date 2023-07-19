//
//  SwiftUISocialAppApp.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import SwiftUI
import Firebase
@main
struct SwiftUISocialAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
