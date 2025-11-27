//
//  tcic_ios_simple_demoApp.swift
//  tcic_ios_simple_demo
//
//  Created by joyxian on 2025/8/27.
//

import SwiftUI
import tcic_ios

// 添加 AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // 返回当前 TCICViewController 设置的方向
        return TCICViewController.currentOrientationLock
    }
}

@main
struct tcic_ios_simple_demoApp: App {
    init() {
        TCICManager.shared.initialize();
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
