// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
private protocol PasteboardManager {
  var type: NSPasteboard.PasteboardType { get }
  // UTType identifier
  var dataType: String { get }
  // return true if writing is successful
  func writeSelection(to pboard: NSPasteboard) -> Bool
  // return true if reading is successful
  func readSelection(from pboard: NSPasteboard) -> Bool
}

extension TextView: @preconcurrency NSServicesMenuRequestor {
  fileprivate var pasteboardManagers: [PasteboardManager] {
    // order matters: prefer rohan type over string type
    [RohanPasteboardManager(self), StringPasteboardManager(self)]
  }

  @objc public func copy(_ sender: Any?) {
    _ = writeSelection(to: NSPasteboard.general, types: pasteboardManagers.map(\.type))
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

  public func readSelection(from pboard: NSPasteboard) -> Bool {
    for pasteboardManager in pasteboardManagers {
      guard pboard.types?.contains(pasteboardManager.type) == true,
        pboard.canReadItem(withDataConformingToTypes: [pasteboardManager.dataType])
      else { continue }

      if pasteboardManager.readSelection(from: pboard) { return true }
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

extension NSPasteboard.PasteboardType {
  // "rohan" for internal use, "noor" for external use
  static let rohan = NSPasteboard.PasteboardType("x-noor-nodes")
}

@MainActor
private struct RohanPasteboardManager: PasteboardManager {
  let type: NSPasteboard.PasteboardType = .rohan
  let dataType: String = UTType.data.identifier

  private let textView: TextView

  init(_ textView: TextView) {
    self.textView = textView
  }

  func writeSelection(to pboard: NSPasteboard) -> Bool {
    let documentManager = textView.documentManager
    guard let range = documentManager.textSelection?.effectiveRange,
      let data = documentManager.jsonData(for: range)
    else { return false }
    pboard.setData(data, forType: type)
    return true
  }

  func readSelection(from pboard: NSPasteboard) -> Bool {
    guard let data = pboard.data(forType: type) else { return false }
    do {
      let nodes: [Node] = try NodeSerdeUtils.decodeListOfNodes(from: data)
      let documentManager = textView.documentManager
      guard let selection = documentManager.textSelection?.effectiveRange
      else { return false }
      let result = documentManager.replaceContents(in: selection, with: nodes)
      switch result {
      case .success(let range):
        documentManager.textSelection = RhTextSelection(range.endLocation)
        return true
      case .failure(let error):
        return error.code == .ContentToInsertIsIncompatible
      }
    }
    catch {
      return false
    }
  }
}

@MainActor
private struct StringPasteboardManager: PasteboardManager {
  let type: NSPasteboard.PasteboardType = .string
  let dataType: String = UTType.plainText.identifier

  private let textView: TextView

  init(_ textView: TextView) {
    self.textView = textView
  }

  func writeSelection(to pboard: NSPasteboard) -> Bool {
    let documentManager = textView.documentManager
    guard let range = documentManager.textSelection?.effectiveRange,
      let string = documentManager.lossyString(for: range)
    else { return false }
    pboard.setString(String(string), forType: type)
    return true
  }

  func readSelection(from pboard: NSPasteboard) -> Bool {
    guard let string = pboard.string(forType: type),
      !string.isEmpty
    else { return false }

    // split by newline except for "line separator"
    let parts = string.split { char in char.isNewline && char == "\u{2028}" }
    if parts.count == 1 {
      textView.insertText(string, replacementRange: .notFound)
      return true
    }
    assert(parts.count > 1)
    let nodes = {
      let textNodes = parts.map({ s in TextNode(s) })
      let pairs = textNodes.dropLast()
        .flatMap { textNode in [textNode, LinebreakNode()] }
      return pairs + [textNodes.last!]
    }()

    let documentManager = textView.documentManager
    guard let selection = documentManager.textSelection?.effectiveRange
    else { return false }
    let result = documentManager.replaceContents(in: selection, with: nodes)
    switch result {
    case .success(let range):
      documentManager.textSelection = RhTextSelection(range.endLocation)
      return true
    case .failure(let error):
      return error.code == .ContentToInsertIsIncompatible
    }
  }
}
