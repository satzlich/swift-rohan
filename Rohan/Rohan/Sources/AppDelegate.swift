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
    let setA: [(String, StyleSheet)] = StyleSheets.setA.map { ($0, $1(fontSize)) }
    let setB: [(String, StyleSheet)] = StyleSheets.setB.map { ($0, $1(fontSize)) }

    guard let mainMenu = NSApp.mainMenu,
      let formatMenu = mainMenu.item(withTitle: "Format")?.submenu
    else { return }
    let submenu = NSMenu(title: "Style")

    func addSet(_ items: [(String, StyleSheet)]) {
      for (name, stylesheet) in items {
        let menuItem = NSMenuItem(
          title: name, action: #selector(handleStyleAction(_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = stylesheet
        submenu.addItem(menuItem)
      }
    }

    do {
      addSet(setA)
      submenu.addItem(NSMenuItem.separator())
      addSet(setB)
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
