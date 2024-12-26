// Copyright 2024 Lie Yan

import AppKit
import Foundation

extension RhTextView: NSTextViewportLayoutControllerDelegate {
    public func viewportBounds(
        for textViewportLayoutController: NSTextViewportLayoutController
    ) -> CGRect {
        let overdrawRect = preparedContentRect
        let visibleRect = visibleRect

        let minY: CGFloat
        let maxY: CGFloat
        let minX: CGFloat
        let maxX: CGFloat

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
        contentView.subviews.removeAll()
    }

    public func textViewportLayoutController(
        _ textViewportLayoutController: NSTextViewportLayoutController,
        configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
    ) {
        let fragmentView: RhTextLayoutFragmentView

        // retrieve cache or create
        if let cached = fragmentViewMap.object(forKey: textLayoutFragment) {
            cached.layoutFragment = textLayoutFragment
            fragmentView = cached
        }
        else {
            fragmentView = RhTextLayoutFragmentView(
                layoutFragment: textLayoutFragment,
                frame: textLayoutFragment.layoutFragmentFrame.pixelAligned
            )
        }

        // adjust position
        if !fragmentView.frame.isApproximatelyEqual(
            to: textLayoutFragment.layoutFragmentFrame.pixelAligned
        ) {
            fragmentView.frame = textLayoutFragment.layoutFragmentFrame.pixelAligned
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
        // TODO: the setup of frame is provisional
        contentView.frame = CGRect(x: 0, y: 0,
                                   width: 300, height: 200)
    }
}
