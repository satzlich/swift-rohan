// Copyright 2024-2025 Lie Yan

import Cocoa
import SwiftRohan

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    setupStyleMenu()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: - Styles

  private func setupStyleMenu() {
    let fontSize = FontSize(12)
    let items: [(String, StyleSheet)] = StyleSheets.allCases.map { ($0, $1(fontSize)) }

    guard let mainMenu = NSApp.mainMenu,
      let formatMenu = mainMenu.item(withTitle: "Format")?.submenu
    else { return }
    let submenu = NSMenu(title: "Style")

    for (name, stylesheet) in items {
      let menuItem = NSMenuItem(
        title: name, action: #selector(handleStyleAction(_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = stylesheet
      submenu.addItem(menuItem)
    }

    let submenuItem = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
    submenuItem.submenu = submenu
    formatMenu.addItem(submenuItem)
  }

  @objc func handleStyleAction(_ sender: NSMenuItem) {
    if let style = sender.representedObject as? StyleSheet,
      let currentDocument = NSApp.mainWindow?.windowController?.document as? Document
    {
      currentDocument.setStyle(style)
    }
  }
}
