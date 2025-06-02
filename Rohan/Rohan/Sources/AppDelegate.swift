// Copyright 2024-2025 Lie Yan

import Cocoa
import SwiftRohan

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    FontLoader.registerFonts()
    MenuManager.shared.setupThemeMenu()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
