// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation

extension TextView {
  private var maxResults: Int { 512 }

  public override func complete(_ sender: Any?) {
    guard let range = self.documentManager.textSelection?.effectiveRange,
      range.isEmpty
    else {
      Rohan.logger.debug("complete: location is not empty")
      self.notifyOperationRejected()
      return
    }

    showCompositorWindow()
  }

  public override func cancelOperation(_ sender: Any?) {
    self.complete(sender)
  }

  /// Show the compositor window.
  private func showCompositorWindow() {
    // scroll to the current location to make sure the insertion point is visible
    self.forceUpdate(scroll: true)

    guard let window = self.window,
      let selection = documentManager.textSelection?.effectiveRange,
      selection.isEmpty,
      let (normalPosition, invertedPosition) = getCompositorPositions(selection, window)
    else { return }

    // compute completions
    let completions = getCompletions(for: "", location: selection.location)

    // create view controller
    let viewController = CompositorViewController()
    viewController.items = completions

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
  }

  /// Compute the top and bottom positions (screen coordinates) of the compositor window
  private func getCompositorPositions(
    _ range: RhTextRange, _ window: NSWindow
  ) -> (normal: CGPoint, inverted: CGPoint)? {
    let segmentFrame = documentManager.textSegmentFrame(in: range, type: .standard)
    guard let segmentFrame else { return nil }

    let normalPosition = {
      let point = segmentFrame.origin
        .with(y: segmentFrame.maxY)
        .with(xDelta: -CompositorStyle.textFieldXOffset)
      return window.convertPoint(toScreen: contentView.convert(point, to: nil))
    }()

    let invertedPosition = {
      let point = segmentFrame.origin
        .with(y: segmentFrame.minY)
        .with(xDelta: -CompositorStyle.textFieldXOffset)
      return window.convertPoint(toScreen: contentView.convert(point, to: nil))
    }()

    return (normalPosition, invertedPosition)
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
    guard let selection = documentManager.textSelection?.effectiveRange,
      selection.isEmpty
    else { return }
    let completions = getCompletions(for: text, location: selection.location)
    controller.compositorViewController.items = completions
  }

  func commitSelection(_ item: CompletionItem, _ controller: CompositorWindowController) {
    guard let selection = documentManager.textSelection?.effectiveRange
    else { return }

    switch item.record.content {
    case .plaintext(let string):
      let result = replaceCharactersForEdit(in: selection, with: string)
      assert(result.isInternalError == false)

    case .other(let exprs):
      let content = NodeUtils.convertExprs(exprs)
      let result = replaceContentsForEdit(in: selection, with: content)
      assert(result.isInternalError == false)
    }
  }
}
