// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation

extension DocumentView {
  private var maxResults: Int { 1024 }

  /// Action triggered by the Control+Space shortcut.
  public override func complete(_ sender: Any?) {
    _triggerCompositorWindow() { notifyOperationIsRejected() }
  }

  /// Action triggered by Escape key.
  public override func cancelOperation(_ sender: Any?) {
    self.complete(sender)
  }

  /// Trigger the compositor window.
  private func _triggerCompositorWindow(_ notifyRejection: () -> Void) {
    // check preconditions for using the compositor
    guard completionProvider != nil,
      let selection = documentManager.textSelection,
      selection.textRange.isEmpty,
      let window = self.window
    else {
      notifyRejection()
      return
    }

    // scroll to insertion point
    self.forceUpdate(scroll: true)

    let location = selection.anchor
    guard let positions = _getCompositorPositions(location, selection.affinity, window)
    else { return }  // no need to notify rejection

    // compute completions
    let completions = _getCompletions(for: "", location: location)

    // create view controller
    let viewController = CompositorViewController()
    viewController.items = completions

    // create window controller
    let windowController = CompositorWindowController(viewController, window)
    windowController.delegate = self

    // show the compositor window
    let screen = NSScreen.main?.frame ?? .zero
    if positions.normal.y > screen.height / 3 {
      let compositorMode = CompositorMode.normal
      viewController.compositorMode = compositorMode
      windowController.showModal(at: positions.normal, mode: compositorMode)
    }
    else {
      let compositorMode = CompositorMode.inverted
      viewController.compositorMode = compositorMode
      windowController.showModal(at: positions.inverted, mode: compositorMode)
    }
  }

  /// Compute the compositor positions for the given range.
  /// - Returns: nil if the positions cannot be computed. The normal position is
  ///     for display prompt window below the insertion point, and the inverted
  ///     position is for display prompt window above the insertion point.
  private func _getCompositorPositions(
    _ location: TextLocation, _ affinity: SelectionAffinity, _ window: NSWindow
  ) -> (normal: CGPoint, inverted: CGPoint)? {
    guard
      let segmentFrame =
        documentManager.primaryInsertionIndicatorFrame(at: location, affinity)
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
  ) -> Array<CompletionItem> {
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
    guard text.count == 1 else { return false }
    let char = text.first!
    return !(char.isLetter || char.isNumber)
  }
}

extension DocumentView: @preconcurrency CompositorWindowDelegate {
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
