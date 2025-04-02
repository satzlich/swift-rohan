// Copyright 2024-2025 Lie Yan

import AppKit
import UniformTypeIdentifiers

@MainActor
internal protocol PasteboardManager {
  /// Pasteboard type
  var type: NSPasteboard.PasteboardType { get }
  /// UTType identifier
  var dataType: String { get }
  /// Write selection to pasteboard
  /// - Returns: true if writing is successful
  func writeSelection(to pboard: NSPasteboard) -> Bool
  /// Read selection from pasteboard
  /// - Returns: true if reading is successful
  func readSelection(from pboard: NSPasteboard) -> Bool
}

extension NSPasteboard.PasteboardType {
  /// Custom pasteboard type for Rohan nodes
  static let rohan = NSPasteboard.PasteboardType("x-rohan-nodes")
}

// MARK: - Implementations

@MainActor
final class RohanPasteboardManager: PasteboardManager {
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
      // decode nodes
      let nodes: [Node] = try NodeSerdeUtils.decodeListOfNodes(from: data)

      // obtain selection range
      let documentManager = textView.documentManager
      guard let selection = documentManager.textSelection?.effectiveRange
      else { return false }

      // replace selected content with nodes
      let result = textView.replaceContentsForEdit(in: selection, with: nodes)
      assert(result.isInternalError == false)
      return true
    }
    catch {
      assertionFailure("Failed to decode nodes: \(error)")
      Rohan.logger.error("Failed to decode nodes: \(error)")
      return false
    }
  }
}

@MainActor
final class StringPasteboardManager: PasteboardManager {
  let type: NSPasteboard.PasteboardType = .string
  let dataType: String = UTType.plainText.identifier

  private let textView: TextView

  init(_ textView: TextView) {
    self.textView = textView
  }

  func writeSelection(to pboard: NSPasteboard) -> Bool {
    let documentManager = textView.documentManager
    guard let range = documentManager.textSelection?.effectiveRange,
      let string = documentManager.stringify(for: range)
    else { return false }
    pboard.setString(String(string), forType: type)
    return true
  }

  func readSelection(from pboard: NSPasteboard) -> Bool {
    guard let string = pboard.string(forType: type),
      !string.isEmpty
    else { return false }

    // obtain selection range
    let documentManager = textView.documentManager
    guard let selection = documentManager.textSelection?.effectiveRange
    else { return false }

    if let nodes = StringUtils.getNodes(fromRaw: string) {
      let result = textView.replaceContentsForEdit(in: selection, with: nodes)
      assert(result.isInternalError == false)
      return true
    }
    else {
      let result = textView.replaceCharactersForEdit(in: selection, with: string)
      assert(result.isInternalError == false)
      return true
    }
  }
}
