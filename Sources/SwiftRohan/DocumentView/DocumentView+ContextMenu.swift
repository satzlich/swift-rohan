// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView: NSMenuItemValidation {
  public override func menu(for event: NSEvent) -> NSMenu? {
    let menu = NSMenu()

    menu.addItem(withTitle: "Cut", action: #selector(cut(_:)), keyEquivalent: "x")
    menu.addItem(withTitle: "Copy", action: #selector(copy(_:)), keyEquivalent: "c")
    menu.addItem(withTitle: "Paste", action: #selector(paste(_:)), keyEquivalent: "v")

    appendMenuItems(menu)

    return menu
  }

  private func appendMenuItems(_ menu: NSMenu) {
    guard let textRange = documentManager.textSelection?.textRange,
      textRange.isEmpty,
      let (node, _) = documentManager.contextualNode(for: textRange.location)
    else { return }

    switch node {
    case let node as _GridNode:
      appendMenuItems_EditGrid(menu, node)
    case let node as AttachNode:
      appendMenuItems_EditAttach(menu, node)
    default:
      break
    }
  }

  private func appendMenuItems_EditAttach(_ menu: NSMenu, _ node: AttachNode) {
    let components = node.enumerateComponents().map(\.index)
    guard components.contains(where: { $0 != .nuc })
    else { return }

    menu.addItem(NSMenuItem.separator())
    for component in components {
      switch component {
      case .sub:
        menu.addItem(
          withTitle: "Remove Subscript", action: #selector(removeSubscript(_:)),
          keyEquivalent: "")

      case .sup:
        menu.addItem(
          withTitle: "Remove Superscript", action: #selector(removeSuperscript(_:)),
          keyEquivalent: "")

      default:
        continue
      }
    }
  }

  private func appendMenuItems_EditGrid(_ menu: NSMenu, _ node: _GridNode) {
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
      if node.rowCount > 1 {
        deleteSubmenu.addItem(
          withTitle: "Delete Row", action: #selector(deleteRow(_:)), keyEquivalent: "")
      }
      if node.columnCount > 1 {
        deleteSubmenu.addItem(
          withTitle: "Delete Column", action: #selector(deleteColumn(_:)),
          keyEquivalent: "")
      }
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
}
