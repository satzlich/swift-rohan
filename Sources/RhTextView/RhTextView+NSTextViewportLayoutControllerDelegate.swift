// Copyright 2024 Lie Yan

import AppKit
import Foundation

extension RhTextView: NSTextViewportLayoutControllerDelegate {
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
            minX = min(overdrawRect.minX,
                       max(visibleRect.minX, bounds.minX))
            minY = min(overdrawRect.minY,
                       max(visibleRect.minY, bounds.minY))
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

        return CGRect(x: minX,
                      y: minY,
                      width: maxX,
                      height: maxY - minY)
    }

    public func textViewportLayoutControllerWillLayout(
        _ textViewportLayoutController: NSTextViewportLayoutController
    ) {
        /*
         TODO(optimization): update subviews incrementally

         Retain cache hits, add new fragments, remove the rest.
         */

        // clear subviews
        contentView.subviews.removeAll()
    }

    public func textViewportLayoutController(
        _ textViewportLayoutController: NSTextViewportLayoutController,
        configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
    ) {
        let fragmentView: RhTextLayoutFragmentView

        // retrieve from cache or create
        if let cached = fragmentViewMap.object(forKey: textLayoutFragment) {
            cached.layoutFragment = textLayoutFragment
            fragmentView = cached
        }
        else {
            fragmentView = RhTextLayoutFragmentView(
                layoutFragment: textLayoutFragment,
                frame: textLayoutFragment.layoutFragmentFrame
            )
        }

        // adjust position
        if !fragmentView.frame.isApproximatelyEqual(
            to: textLayoutFragment.layoutFragmentFrame
        ) {
            fragmentView.frame = textLayoutFragment.layoutFragmentFrame
            fragmentView.needsLayout = true
            fragmentView.needsDisplay = true
        }

        // update cache
        fragmentViewMap.setObject(fragmentView, forKey: textLayoutFragment)

        // add to content view
        contentView.addSubview(fragmentView)
    }

    public func textViewportLayoutControllerDidLayout(
        _ textViewportLayoutController: NSTextViewportLayoutController
    ) {
        let documentEnd = NSTextRange(location: textLayoutManager.documentRange.endLocation)
        textLayoutManager.ensureLayout(for: documentEnd)

        _propagateTextContainerSize()
    }
}
