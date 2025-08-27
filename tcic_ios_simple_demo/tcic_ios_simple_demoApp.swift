//
//  tcic_ios_simple_demoApp.swift
//  tcic_ios_simple_demo
//
//  Created by joyxian on 2025/8/27.
//

import SwiftUI
import tcic_ios

@main
struct tcic_ios_simple_demoApp: App {
    init() {
        TCICManager.shared.initialize();
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
