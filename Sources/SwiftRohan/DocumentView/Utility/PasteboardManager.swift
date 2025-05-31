// Copyright 2024-2025 Lie Yan

import AppKit
import UniformTypeIdentifiers

internal enum PasteResult {
  case success
  case successWithoutChange
  case failure
}

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
  func readSelection(from pboard: NSPasteboard) -> PasteResult
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

  private let textView: DocumentView

  init(_ textView: DocumentView) {
    self.textView = textView
  }

  func writeSelection(to pboard: NSPasteboard) -> Bool {
    let documentManager = textView.documentManager
    guard let range = documentManager.textSelection?.textRange,
      let data = documentManager.jsonData(for: range)
    else { return false }
    pboard.setData(data, forType: type)
    return true
  }

  func readSelection(from pboard: NSPasteboard) -> PasteResult {
    guard let data = pboard.data(forType: type) else { return .failure }
    do {
      // decode nodes
      let nodes: [Node] = try NodeSerdeUtils.decodeListOfNodes(from: data)

      // obtain selection range
      guard let selection = textView.documentManager.textSelection?.textRange
      else { return .failure }

      // replace selected content with nodes
      let result = textView.replaceContentsForEdit(in: selection, with: nodes)
      switch result {
      case .internalError:
        assertionFailure("Internal error")
        return .failure
      case .userError:
        return .successWithoutChange
      case .success:
        return .success
      }
    }
    catch {
      assertionFailure("Failed to decode nodes: \(error)")
      return .failure
    }
  }
}

@MainActor
final class StringPasteboardManager: PasteboardManager {
  let type: NSPasteboard.PasteboardType = .string
  let dataType: String = UTType.plainText.identifier

  private let textView: DocumentView

  init(_ textView: DocumentView) {
    self.textView = textView
  }

  func writeSelection(to pboard: NSPasteboard) -> Bool {
    let documentManager = textView.documentManager
    guard let range = documentManager.textSelection?.textRange,
      let string = documentManager.getLaTeXContent(for: range)
    else { return false }
    pboard.setString(String(string), forType: type)
    return true
  }

  func readSelection(from pboard: NSPasteboard) -> PasteResult {
    guard let string = pboard.string(forType: type),
      !string.isEmpty
    else { return .failure }

    // obtain selection range
    guard let selection = textView.documentManager.textSelection?.textRange
    else { return .failure }

    // insert nodes/string
    let result: EditResult
    if let nodes = StringUtils.getNodes(fromRaw: string) {
      result = textView.replaceContentsForEdit(in: selection, with: nodes)
    }
    else {
      result = textView.replaceCharactersForEdit(in: selection, with: string)
    }

    switch result {
    case .internalError:
      assertionFailure("Internal error")
      return .failure
    case .userError:
      return .successWithoutChange
    case .success:
      return .success
    }
  }
}
