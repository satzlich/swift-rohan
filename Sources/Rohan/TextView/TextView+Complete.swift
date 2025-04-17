// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation

extension TextView {
  private var maxResults: Int { 512 }

  public override func complete(_ sender: Any?) {
    let okay = triggerCompositorWindow()
    if !okay { notifyOperationRejected() }
  }

  public override func cancelOperation(_ sender: Any?) {
    self.complete(sender)
  }

  /// Trigger the compositor window.
  /// - Returns: false if the operation is rejected.
  internal func triggerCompositorWindow() -> Bool {
    guard let selection = documentManager.textSelection?.textRange,
      selection.isEmpty,
      let window = self.window
    else { return false }

    // scroll to insertion point
    self.forceUpdate(scroll: true)

    guard
      let (normalPosition, invertedPosition) = getCompositorPositions(selection, window)
    else {
      // fail to get segment frame is not operation rejected
      return true
    }

    // compute completions
    let completions = getCompletions(for: "", location: selection.location)

    // create view controller
    let viewController = CompositorViewController()
    viewController.items = completions

    // create window controller
    let windowController = CompositorWindowController(viewController, window)
    windowController.delegate = self

    let screen = NSScreen.main?.frame ?? .zero

    if normalPosition.y - screen.height / 3 > 0 {
      let compositorMode = CompositorMode.normal
      viewController.compositorMode = compositorMode
      windowController.showModal(at: normalPosition, mode: compositorMode)
    }
    else {
      let compositorMode = CompositorMode.inverted
      viewController.compositorMode = compositorMode
      windowController.showModal(at: invertedPosition, mode: compositorMode)
    }
    return true
  }

  /// Compute the compositor positions for the given range.
  private func getCompositorPositions(
    _ range: RhTextRange, _ window: NSWindow
  ) -> (normal: CGPoint, inverted: CGPoint)? {
    let segmentFrame = documentManager.textSegmentFrame(in: range, type: .standard)
    guard let segmentFrame else { return nil }

    func windowPosition(for point: CGPoint) -> CGPoint {
      let shifted = point.with(xDelta: -CompositorStyle.textFieldXOffset)
      return window.convertPoint(toScreen: contentView.convert(shifted, to: nil))
    }

    let normal = windowPosition(for: segmentFrame.origin.with(y: segmentFrame.maxY))
    let inverted = windowPosition(for: segmentFrame.origin.with(y: segmentFrame.minY))

    return (normal, inverted)
  }

  private func getCompletions(
    for query: String, location: TextLocation
  ) -> [CompletionItem] {
    guard let provider = self.completionProvider else { return [] }
    guard let container = documentManager.containerCategory(for: location)
    else {
      assertionFailure("container category is nil")
      return []
    }
    let results = provider.getCompletions(query, container, maxResults)
    return results.map {
      CompletionItem(id: UUID().uuidString, $0, query)
    }
  }
}

extension TextView: CompositorWindowDelegate {
  func commandDidChange(_ text: String, _ controller: CompositorWindowController) {
    guard let selection = documentManager.textSelection?.textRange,
      selection.isEmpty
    else { return }

    if let triggerKey = triggerKey,
      String(triggerKey) == text
    {
      let result = replaceCharactersForEdit(in: selection, with: text)
      assert(result.isInternalError == false)
      controller.dismiss()
    }
    else {
      let completions = getCompletions(for: text, location: selection.location)
      controller.compositorViewController.items = completions
    }
  }

  func commitSelection(_ item: CompletionItem, _ controller: CompositorWindowController) {
    guard let selection = documentManager.textSelection?.textRange,
      selection.isEmpty
    else { return }

    let record = item.record

    switch record.content {
    case .plaintext(let string):
      let result = replaceCharactersForEdit(in: selection, with: string)
      assert(result.isInternalError == false)

    case .other(let exprs):
      let content = NodeUtils.convertExprs(exprs)
      let result = replaceContentsForEdit(in: selection, with: content)
      assert(result.isInternalError == false)
    }

    for _ in 0..<record.backwardMoves {
      self.moveBackward(nil)
    }
  }
}
