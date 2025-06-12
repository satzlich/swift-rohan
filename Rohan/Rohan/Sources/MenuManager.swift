// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import SwiftRohan

final class MenuManager {
  static let shared = MenuManager()

  func setupThemeMenu() {
    guard let mainMenu = NSApp.mainMenu,
      let formatMenu = mainMenu.item(withTitle: "Theme")?.submenu
    else { return }
    do {
      let submenu = NSMenu(title: "Style")

      for item in StyleSheets.allRecords {
        let menuItem = NSMenuItem(
          title: item.name, action: #selector(setStyle(_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = item
        submenu.addItem(menuItem)
      }

      let submenuItem = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
      submenuItem.submenu = submenu
      formatMenu.addItem(submenuItem)
    }
    do {
      let submenu = NSMenu(title: "Text Size")

      for item in StyleSheets.textSizes {
        let menuItem = NSMenuItem(
          title: "\(Int(item.floatValue)) pt",
          action: #selector(setTextSize(_:)),
          keyEquivalent: "")

        menuItem.target = self
        menuItem.representedObject = item
        submenu.addItem(menuItem)
      }

      let submenuItem = NSMenuItem(title: "Text Size", action: nil, keyEquivalent: "")
      submenuItem.submenu = submenu
      formatMenu.addItem(submenuItem)
    }
  }

  @objc func setStyle(_ sender: NSMenuItem) {
    if let style = sender.representedObject as? StyleSheets.Record,
      let currentDocument = NSApp.mainWindow?.windowController?.document as? Document
    {
      currentDocument.setStyle(style)
    }
  }

  @objc func setTextSize(_ sender: NSMenuItem) {
    if let size = sender.representedObject as? FontSize,
      let currentDocument = NSApp.mainWindow?.windowController?.document as? Document
    {
      currentDocument.setTextSize(size)
    }
  }
}
