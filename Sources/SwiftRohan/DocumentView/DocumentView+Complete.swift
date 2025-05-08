// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation

extension DocumentView {
  private var maxResults: Int { 1024 }

  /// Action triggered by the Control+Space shortcut.
  public override func complete(_ sender: Any?) {
    let okay = _triggerCompositorWindow()
    if !okay { notifyOperationRejected() }
  }

  /// Action triggered by Escape key.
  public override func cancelOperation(_ sender: Any?) {
    complete(sender)
  }

  /// Trigger the compositor window.
  /// - Returns: false if the operation is rejected.
  private func _triggerCompositorWindow() -> Bool {
    // check preconditions for using the compositor
    guard completionProvider != nil,
      let selection = documentManager.textSelection,
      selection.textRange.isEmpty,
      let window = self.window
    else { return false }

    // scroll to insertion point
    self.forceUpdate(scroll: true)

    guard let positions = _getCompositorPositions(selection, window)
    else {
      // fail to get positions is not operation rejected
      return true
    }

    // compute completions
    let completions = _getCompletions(for: "", location: selection.textRange.location)

    // create view controller
    let viewController = CompositorViewController()
    viewController.items = completions

    // create window controller
    let windowController = CompositorWindowController(viewController, window)
    windowController.delegate = self

    let screen = NSScreen.main?.frame ?? .zero

    if positions.normal.y - screen.height / 3 > 0 {
      let compositorMode = CompositorMode.normal
      viewController.compositorMode = compositorMode
      windowController.showModal(at: positions.normal, mode: compositorMode)
    }
    else {
      let compositorMode = CompositorMode.inverted
      viewController.compositorMode = compositorMode
      windowController.showModal(at: positions.inverted, mode: compositorMode)
    }
    return true
  }

  /// Compute the compositor positions for the given range.
  private func _getCompositorPositions(
    _ selection: RhTextSelection, _ window: NSWindow
  ) -> (normal: CGPoint, inverted: CGPoint)? {
    let options: DocumentManager.SegmentOptions =
      selection.affinity == .upstream ? .upstreamAffinity : []
    guard
      let segmentFrame = documentManager.insertionIndicatorFrame(
        in: selection.textRange, type: .standard, options: options)
    else { return nil }

    let screen = NSScreen.main?.frame ?? .zero

    func windowPosition(for point: CGPoint) -> CGPoint {
      // convert the point before shift to accommodate magnification
      let point = window.convertPoint(toScreen: contentView.convert(point, to: nil))
        .with(xDelta: -CompositorStyle.textFieldXOffset)
      // conduct clamping to avoid going out of screen
      let x = point.x.clamped(0, screen.maxX - CompositorStyle.minFrameWidth)
      return point.with(x: x)
    }

    let normal = windowPosition(for: segmentFrame.origin.with(y: segmentFrame.maxY))
    let inverted = windowPosition(for: segmentFrame.origin.with(y: segmentFrame.minY))

    return (normal, inverted)
  }

  /// Returns the completions for the given query at the given location.
  private func _getCompletions(
    for query: String, location: TextLocation
  ) -> [CompletionItem] {
    guard let provider = self.completionProvider,
      let container = documentManager.containerCategory(for: location)
    else {
      assertionFailure("completion provider or container is nil")
      return []
    }
    let results = provider.getCompletions(query, container, maxResults)
    return results.map { CompletionItem(id: UUID().uuidString, $0, query) }
  }

  /// Returns true if the given text is a compositor literal.
  private func _isCompositorLiteral(_ text: String) -> Bool {
    text.count == 1 && text.first.map { $0.isLetter || $0.isNumber } == false
  }
}

extension DocumentView: CompositorWindowDelegate {
  func commandDidChange(_ text: String, _ controller: CompositorWindowController) {
    // check preconditions
    guard let selection = documentManager.textSelection,
      selection.textRange.isEmpty
    else {
      assertionFailure("selection is not empty")
      return
    }

    // insert immediately if text is trigger key or compositor literal
    if triggerKey.map(String.init) == text
      || _isCompositorLiteral(text)
    {
      beginEditing()
      let result = replaceCharactersForEdit(in: selection.textRange, with: text)
      assert(result.isInternalError == false)
      endEditing()

      controller.dismiss()
    }
    else {
      let completions = _getCompletions(for: text, location: selection.textRange.location)
      controller.compositorViewController.items = completions
    }
  }

  func commitSelection(_ item: CompletionItem, _ controller: CompositorWindowController) {
    guard let selection = documentManager.textSelection,
      selection.textRange.isEmpty
    else {
      assertionFailure("selection is not empty")
      return
    }

    beginEditing()
    executeCommand(item.record.body, at: selection.textRange)
    endEditing()
  }
}
