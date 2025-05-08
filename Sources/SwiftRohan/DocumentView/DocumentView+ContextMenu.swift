// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView: NSMenuItemValidation {
  public override func menu(for event: NSEvent) -> NSMenu? {
    let menu = NSMenu()

    menu.addItem(withTitle: "Cut", action: #selector(cut(_:)), keyEquivalent: "x")
    menu.addItem(withTitle: "Copy", action: #selector(copy(_:)), keyEquivalent: "c")
    menu.addItem(withTitle: "Paste", action: #selector(paste(_:)), keyEquivalent: "v")

    appendMenuItem_EditMath(menu)

    return menu
  }

  private func appendMenuItem_EditMath(_ menu: NSMenu) {
    appendMenuItems_EditMatrix(menu)
  }

  private func appendMenuItem_EditAttach(_ menu: NSMenu) {

  }

  private func appendMenuItems_EditMatrix(_ menu: NSMenu) {
    guard canEditMatrix() else { return }

    menu.addItem(NSMenuItem.separator())
    do {
      let insertMenuItem = NSMenuItem(title: "Insert", action: nil, keyEquivalent: "")
      let insertSubmenu = NSMenu()
      insertSubmenu.addItem(
        withTitle: "Insert Row before", action: #selector(insertRowBefore(_:)),
        keyEquivalent: "")
      insertSubmenu.addItem(
        withTitle: "Insert Row after", action: #selector(insertRowAfter(_:)),
        keyEquivalent: "")
      insertSubmenu.addItem(
        withTitle: "Insert Column before", action: #selector(insertColumnBefore(_:)),
        keyEquivalent: "")
      insertSubmenu.addItem(
        withTitle: "Insert Column after", action: #selector(insertColumnAfter(_:)),
        keyEquivalent: "")
      if insertSubmenu.items.count > 0 {
        insertMenuItem.submenu = insertSubmenu
        menu.addItem(insertMenuItem)
      }
    }

    do {
      let deleteMenuItem = NSMenuItem(title: "Delete", action: nil, keyEquivalent: "")
      let deleteSubmenu = NSMenu()
      deleteSubmenu.addItem(
        withTitle: "Delete Row", action: #selector(deleteRow(_:)), keyEquivalent: "")
      deleteSubmenu.addItem(
        withTitle: "Delete Column", action: #selector(deleteColumn(_:)),
        keyEquivalent: "")
      if deleteSubmenu.items.count > 0 {
        deleteMenuItem.submenu = deleteSubmenu
        menu.addItem(deleteMenuItem)
      }
    }
  }

  public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    switch menuItem.action {
    case #selector(cut(_:)):
      return canCut()
    case #selector(copy(_:)):
      return canCopy()
    case #selector(paste(_:)):
      return canPaste()
    default:
      return true
    }
  }

  private func canCopy() -> Bool {
    documentManager.textSelection?.textRange.isEmpty == false
  }

  private func canPaste() -> Bool {
    return true
  }

  private func canCut() -> Bool {
    return canCopy()
  }

  private func canEditMatrix() -> Bool {
    true
  }
}
