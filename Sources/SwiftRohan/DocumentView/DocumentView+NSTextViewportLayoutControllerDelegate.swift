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

    let rect = CGRect(x: minX, y: minY, width: maxX, height: maxY - minY)
    return rect.insetBy(dx: 0, dy: -50)
  }

  public func textViewportLayoutControllerWillLayout(
    _ textViewportLayoutController: NSTextViewportLayoutController
  ) {
    // propagate content view width to text container
    documentManager.textContainer!.size = contentView.bounds.size.with(height: 0)
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
    documentManager.ensureLayout(scope: .viewport)

    // 2) propagate text container height to view
    let pageHeight: Double
    let usageBasedHeight: Double
    do {
      pageHeight =
        documentManager.styleSheet
        .resolveDefault(PageProperty.height).absLength()!.ptValue
      usageBasedHeight =
        documentManager.usageBoundsForTextContainer.height + pageHeight * 0.7
    }
    let oldFrameHeight = self.frame.height
    let frameHeight = max(usageBasedHeight, pageHeight)
    setFrameSize(CGSize(width: self.frame.width, height: frameHeight))

    // 3) request update of selection
    setNeedsUpdate(selection: true)

    // 4) request re-layout again if needed. This is necessary as TextKit may
    //    occasionally returns a usage bounds with drastic error after layout.
    if abs(frameHeight - oldFrameHeight) > pageHeight * 0.6 {
      Rohan.logger.debug("Re-layout needed after height change.")
      needsLayout = true
    }
  }
}
