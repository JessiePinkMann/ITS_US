//
//  it_s_USApp.swift
//  it's US
//
//  Created by Egor Zheliba on 02.05.2025.
//

import SwiftUI
import FirebaseCore

@main
struct it_s_USApp: App {
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            CategoryListView()
        }
    }
}
