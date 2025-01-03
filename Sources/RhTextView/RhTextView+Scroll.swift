// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    public class func initScrollable(frame: NSRect) -> NSScrollView {
        // init views
        let scrollView = NSScrollView(frame: frame)
        let textView = Self(frame: frame)

        // set up properties
        scrollView.wantsLayer = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.drawsBackground = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false // must be false

        // set up relations
        scrollView.documentView = textView

        return scrollView
    }

    /**
     Get the scroll view that immediately encloses the text view.
     */
    var scrollView: NSScrollView? {
        if let enclosingScrollView = enclosingScrollView,
           enclosingScrollView.documentView == self
        {
            return enclosingScrollView
        }
        return nil
    }
}
