// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView: NSTextViewportLayoutControllerDelegate {
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

    let padding: CGFloat = 50  // padding for the viewport
    let targetMinY = max(minY - padding, bounds.minY)
    let height = maxY - targetMinY + padding

    return CGRect(x: minX, y: targetMinY, width: maxX, height: height)
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
    let page: PageProperty = documentManager.styleSheet.resolveDefault()
    let usageHeight =
      documentManager.usageBoundsForTextContainer.height + page.topMargin.ptValue
      + page.bottomMargin.ptValue
    let padding = page.height.ptValue / 2
    frame.size.height = max(usageHeight + padding, page.height.ptValue)

    // 3) request update of selection
    setNeedsUpdate(selection: true)
  }
}
