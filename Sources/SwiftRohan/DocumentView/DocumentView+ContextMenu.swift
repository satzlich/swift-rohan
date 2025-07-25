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
      let (node, _, _) = documentManager.contextualNode(for: textRange.location)
    else { return }

    switch node {
    case let node as ArrayNode:
      appendMenuItems_EditGrid(menu, node)
    case let node as AttachNode:
      appendMenuItems_EditAttach(menu, node)
    case let node as RadicalNode:
      appendMenuItems_EditRadical(menu, node)
    default:
      break
    }
  }

  private func appendMenuItems_EditAttach(_ menu: NSMenu, _ node: AttachNode) {
    let components = node.enumerateComponents().map(\.index)
    let scripts: Array<MathIndex> = [.lsub, .lsup, .sub, .sup]
    let complements = scripts.filter { !components.contains($0) }

    menu.addItem(NSMenuItem.separator())
    do {
      do {
        let addMenuItem = NSMenuItem(title: "Add", action: nil, keyEquivalent: "")
        let addSubmenu = NSMenu()
        for component in complements {
          switch component {
          case .lsub:
            addSubmenu.addItem(
              withTitle: "Add Left Subscript",
              action: #selector(addLeftSubscript(_:)),
              keyEquivalent: "")

          case .lsup:
            addSubmenu.addItem(
              withTitle: "Add Left Superscript",
              action: #selector(addLeftSuperscript(_:)),
              keyEquivalent: "")

          case .sub:
            addSubmenu.addItem(
              withTitle: "Add Subscript", action: #selector(addSubscript(_:)),
              keyEquivalent: "")

          case .sup:
            addSubmenu.addItem(
              withTitle: "Add Superscript", action: #selector(addSuperscript(_:)),
              keyEquivalent: "")

          default:
            continue
          }
        }
        if addSubmenu.items.count > 0 {
          addMenuItem.submenu = addSubmenu
          menu.addItem(addMenuItem)
        }
      }
    }
    do {
      let removeMenuItem = NSMenuItem(title: "Remove", action: nil, keyEquivalent: "")
      let removeSubmenu = NSMenu()
      for component in components {
        switch component {
        case .lsub:
          removeSubmenu.addItem(
            withTitle: "Remove Left Subscript",
            action: #selector(removeLeftSubscript(_:)),
            keyEquivalent: "")

        case .lsup:
          removeSubmenu.addItem(
            withTitle: "Remove Left Superscript",
            action: #selector(removeLeftSuperscript(_:)),
            keyEquivalent: "")

        case .sub:
          removeSubmenu.addItem(
            withTitle: "Remove Subscript", action: #selector(removeSubscript(_:)),
            keyEquivalent: "")

        case .sup:
          removeSubmenu.addItem(
            withTitle: "Remove Superscript", action: #selector(removeSuperscript(_:)),
            keyEquivalent: "")

        default:
          continue
        }
      }
      if removeSubmenu.items.count > 0 {
        removeMenuItem.submenu = removeSubmenu
        menu.addItem(removeMenuItem)
      }
    }
  }

  private func appendMenuItems_EditRadical(_ menu: NSMenu, _ node: RadicalNode) {
    let components = node.enumerateComponents().map(\.index)

    menu.addItem(NSMenuItem.separator())

    if components.contains(.index) {
      menu.addItem(
        withTitle: "Remove Degree", action: #selector(removeDegree(_:)),
        keyEquivalent: "")
    }
    else {
      menu.addItem(
        withTitle: "Add Degree", action: #selector(addDegree(_:)),
        keyEquivalent: "")
    }
  }

  private func appendMenuItems_EditGrid(_ menu: NSMenu, _ node: ArrayNode) {
    menu.addItem(NSMenuItem.separator())

    let isMultiColumnEnabled = node.isMultiColumnEnabled

    do {
      let insertMenuItem = NSMenuItem(title: "Insert", action: nil, keyEquivalent: "")
      let insertSubmenu = NSMenu()
      insertSubmenu.addItem(
        withTitle: "Insert Row before", action: #selector(insertRowBefore(_:)),
        keyEquivalent: "")
      insertSubmenu.addItem(
        withTitle: "Insert Row after", action: #selector(insertRowAfter(_:)),
        keyEquivalent: "")

      if isMultiColumnEnabled {
        insertSubmenu.addItem(
          withTitle: "Insert Column before", action: #selector(insertColumnBefore(_:)),
          keyEquivalent: "")
        insertSubmenu.addItem(
          withTitle: "Insert Column after", action: #selector(insertColumnAfter(_:)),
          keyEquivalent: "")
      }
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
