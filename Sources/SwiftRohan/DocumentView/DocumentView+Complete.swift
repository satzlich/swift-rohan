// Copyright 2024-2025 Lie Yan

import AppKit
import CoreGraphics
import Foundation

extension DocumentView {
  private var maxResults: Int { 512 }

  public override func complete(_ sender: Any?) {
    let okay = triggerCompositorWindow()
    if !okay { notifyOperationRejected() }
  }

  public override func cancelOperation(_ sender: Any?) {
    complete(sender)
  }

  /// Trigger the compositor window.
  /// - Returns: false if the operation is rejected.
  internal func triggerCompositorWindow() -> Bool {
    guard let selection = documentManager.textSelection,
      selection.textRange.isEmpty,
      let window = self.window
    else { return false }

    // scroll to insertion point
    self.forceUpdate(scroll: true)

    guard let positions = getCompositorPositions(selection, window)
    else {
      // fail to get segment frame is not operation rejected
      return true
    }

    // compute completions
    let completions = getCompletions(for: "", location: selection.textRange.location)

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
  private func getCompositorPositions(
    _ selection: RhTextSelection, _ window: NSWindow
  ) -> (normal: CGPoint, inverted: CGPoint)? {
    let options: DocumentManager.SegmentOptions =
      selection.affinity == .upstream ? .upstreamAffinity : []
    guard
      let segmentFrame = documentManager.insertionIndicatorFrame(
        in: selection.textRange, type: .standard, options: options)
    else { return nil }

    func windowPosition(for point: CGPoint) -> CGPoint {
      // Since there may be magnification, we need to convert the point to screen
      // before applying the offset.
      let point = window.convertPoint(toScreen: contentView.convert(point, to: nil))
      return point.with(xDelta: -CompositorStyle.textFieldXOffset)
    }

    let normal = windowPosition(for: segmentFrame.origin.with(y: segmentFrame.maxY))
    let inverted = windowPosition(for: segmentFrame.origin.with(y: segmentFrame.minY))

    return (normal, inverted)
  }

  private func getCompletions(
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
}

extension DocumentView: CompositorWindowDelegate {
  func commandDidChange(_ text: String, _ controller: CompositorWindowController) {
    guard let selection = documentManager.textSelection,
      selection.textRange.isEmpty
    else {
      assertionFailure("selection is not empty")
      return
    }

    if let triggerKey = triggerKey,
      String(triggerKey) == text
    {
      let result = replaceCharactersForEdit(in: selection.textRange, with: text)
      assert(result.isInternalError == false)
      controller.dismiss()
    }
    else {
      let completions = getCompletions(for: text, location: selection.textRange.location)
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
    executeCommand(item.record.body, at: selection.textRange)
  }
}
