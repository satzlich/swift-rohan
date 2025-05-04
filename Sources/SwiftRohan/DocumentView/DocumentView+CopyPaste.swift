// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import Foundation
import UniformTypeIdentifiers

extension DocumentView: @preconcurrency NSServicesMenuRequestor {
  private var pasteboardManagers: [PasteboardManager] { _pasteboardManagers }

  @objc public func copy(_ sender: Any?) {
    let types = pasteboardManagers.map(\.type)
    _ = writeSelection(to: NSPasteboard.general, types: types)
  }

  @objc public func paste(_ sender: Any?) {
    _ = readSelection(from: NSPasteboard.general)
  }

  @objc public func cut(_ sender: Any?) {
    copy(sender)
    delete(sender)
  }

  @objc public func delete(_ sender: Any?) {
    insertText("", replacementRange: .notFound)
  }

  // MARK: - Pasteboard

  /// Read the selection from the pasteboard.
  /// - Returns: true if the selection is successfully read from the pasteboard.
  public func readSelection(from pboard: NSPasteboard) -> Bool {
    for pasteboardManager in pasteboardManagers {
      guard pboard.types?.contains(pasteboardManager.type) == true,
        pboard.canReadItem(withDataConformingToTypes: [pasteboardManager.dataType])
      else { continue }

      beginEditing()
      defer { endEditing() }
      if pasteboardManager.readSelection(from: pboard) {
        return true
      }
    }
    return false
  }

  public func writeSelection(
    to pboard: NSPasteboard, types: [NSPasteboard.PasteboardType]
  ) -> Bool {
    let activeManagers = pasteboardManagers.filter { types.contains($0.type) }
    guard activeManagers.isEmpty == false else { return false }

    // clear pasteboard before writing
    pboard.clearContents()
    // write to pasteboard
    var successful = false
    for pasteboardManager in activeManagers {
      // due to shortcut of logical OR, action must be evaluated first
      successful = pasteboardManager.writeSelection(to: pboard) || successful
    }
    return successful
  }
}
