// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import RohanCommon

final class ContentView: NSView {
    private typealias FragmentViewCache
        = NSMapTable<NSTextLayoutFragment, TextLayoutFragmentView>

    private var fragmentViewCache: FragmentViewCache = .weakToWeakObjects()
    private var isRefreshing: Bool = false
    private var cacheStats = CacheStats()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        if DebugConfig.DECORATE_CONTENT_VIEW {
            layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05).cgColor
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    func beginRefresh() {
        precondition(!isRefreshing)
        // mark as refreshing
        isRefreshing = true
        // clear existing fragments
        clearFragments()
        // reset stats
        if DebugConfig.COLLECT_STATS_FRAGMENT_VIEW_CACHE {
            cacheStats.size = fragmentViewCache.count
            cacheStats.hit = 0
            cacheStats.miss = 0
        }
    }

    func endRefresh() {
        precondition(isRefreshing, "endRefresh can only be called after beginRefresh")
        // mark as not refreshing
        isRefreshing = false
        // log stats
        if DebugConfig.COLLECT_STATS_FRAGMENT_VIEW_CACHE {
            cacheStats.endSize = fragmentViewCache.count
            Rohan.logger.debug("\(self.cacheStats.debugDescription)")
        }
    }

    func addFragment(_ textLayoutFragment: NSTextLayoutFragment) {
        precondition(isRefreshing)

        // retrieve from cache or create
        if let cached = fragmentViewCache.object(forKey: textLayoutFragment) {
            // update layout fragment
            cached.layoutFragment = textLayoutFragment

            // update frame
            if !cached.frame
                .isApproximatelyEqual(to: textLayoutFragment.layoutFragmentFrame)
            {
                cached.frame = textLayoutFragment.layoutFragmentFrame
            }

            // add as subview
            addSubview(cached)

            // update stats
            if DebugConfig.COLLECT_STATS_FRAGMENT_VIEW_CACHE {
                cacheStats.hit += 1
            }
        }
        else {
            let fragmentView =
                TextLayoutFragmentView(textLayoutFragment,
                                       frame: textLayoutFragment.layoutFragmentFrame)

            // add to cache
            fragmentViewCache.setObject(fragmentView, forKey: textLayoutFragment)

            // add as subview
            addSubview(fragmentView)

            // update stats
            if DebugConfig.COLLECT_STATS_FRAGMENT_VIEW_CACHE {
                cacheStats.miss += 1
            }
        }
    }

    func clearFragments() {
        // remove subviews
        subviews.removeAll()
    }
}

private final class TextLayoutFragmentView: NSView {
    var layoutFragment: NSTextLayoutFragment {
        didSet {
            needsLayout = true
            needsDisplay = true
        }
    }

    init(_ layoutFragment: NSTextLayoutFragment, frame: CGRect) {
        self.layoutFragment = layoutFragment
        super.init(frame: frame)

        if DebugConfig.DECORATE_LAYOUT_FRAGMENT {
            layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.05).cgColor
            layer?.borderColor = NSColor.systemOrange.cgColor
            layer?.borderWidth = 0.5
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        // draw layout fragment
        layoutFragment.draw(at: .zero, in: context)
        // draw text attachments
        for viewProvider in layoutFragment.textAttachmentViewProviders {
            guard let view = viewProvider.view else { continue }
            let frame = layoutFragment.frameForTextAttachment(at: viewProvider.location)
            view.frame = frame
            view.draw(frame)
        }
    }
}

private struct CacheStats: CustomDebugStringConvertible {
    var size: Int = 0
    var endSize: Int = 0
    var hit: Int = 0
    var miss: Int = 0

    var debugDescription: String {
        """
        cache stats: \(size) -> \(endSize), hit \(hit), miss \(miss)
        """
    }
}
