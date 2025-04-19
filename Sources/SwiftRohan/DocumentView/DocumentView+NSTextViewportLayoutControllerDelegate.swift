// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView: @preconcurrency NSTextViewportLayoutControllerDelegate {
  public func viewportBounds(
    for textViewportLayoutController: NSTextViewportLayoutController
  ) -> CGRect {

    let overdrawRect = preparedContentRect
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat

    let visibleRect = scrollView?.documentVisibleRect ?? contentView.visibleRect

    if !overdrawRect.isEmpty,
      overdrawRect.intersects(visibleRect)
    {
      // Extend the overdraw rect to include the visible rect
      minX = min(overdrawRect.minX, max(visibleRect.minX, bounds.minX))
      minY = min(overdrawRect.minY, max(visibleRect.minY, bounds.minY))
      maxX = max(overdrawRect.maxX, visibleRect.maxX)
      maxY = max(overdrawRect.maxY, visibleRect.maxY)
    }
    else {
      // Use the visible rect
      minX = visibleRect.minX
      minY = visibleRect.minY
      maxX = visibleRect.maxX
      maxY = visibleRect.maxY
    }

    let bounds = CGRect(x: minX, y: minY, width: maxX, height: maxY - minY)
    Rohan.logger.debug("viewportBounds: \(String(describing: bounds))")
    return bounds
  }

  public func textViewportLayoutControllerWillLayout(
    _ textViewportLayoutController: NSTextViewportLayoutController
  ) {
    Rohan.logger.debug("pageWidth: \(String(describing: self.pageWidth))")
    Rohan.logger.debug("bounds: \(String(describing: self.bounds.size))")

    // propagate content view width to text container
    documentManager.textContainer!.size = self.bounds.size.with(height: 0)
    // synchronize content storage with current document
    documentManager.reconcileContentStorage()
    // begin refreshing
    contentView.beginRefreshing()
  }

  public func textViewportLayoutController(
    _ textViewportLayoutController: NSTextViewportLayoutController,
    configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
  ) {
    // refresh: add fragment
    contentView.addFragment(textLayoutFragment)
  }

  public func textViewportLayoutControllerDidLayout(
    _ textViewportLayoutController: NSTextViewportLayoutController
  ) {
    // end refreshing
    contentView.endRefreshing()

    // 1) update layout
    documentManager.ensureLayout(viewportOnly: true)
    // 2) propagate text container height to view
    let height = max(documentManager.usageBounds.height, window!.frame.height)
    setFrameSize(self.bounds.size.with(height: height))
    // 3) request update of selection
    self.setNeedsUpdate(selection: true)
  }
}
