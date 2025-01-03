// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**

 ```
 RhContentView
    |---RhTextLayoutFragmentView *
 ```
 */
final class RhContentView: RhView {
    private typealias FragmentViewCache
        = NSMapTable<NSTextLayoutFragment, RhTextLayoutFragmentView>

    private var fragmentViewCache: FragmentViewCache
    private var isRefreshing: Bool = false
    private var cacheStats = CacheStats()

    override init(frame frameRect: NSRect) {
        self.fragmentViewCache = NSMapTable.weakToWeakObjects()

        super.init(frame: frameRect)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.fragmentViewCache = NSMapTable.weakToWeakObjects()

        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        if DebugConfig.DEBUG_CONTENT_VIEW {
            layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05).cgColor
        }
    }

    func beginRefresh() {
        precondition(!isRefreshing, "beginRefresh can only be called once")

        // mark as refreshing
        isRefreshing = true

        // clear fragments
        clearFragments()

        // reset stats
        if DebugConfig.DEBUG_FRAGMENT_VIEW_CACHE_STATS {
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
        if DebugConfig.DEBUG_FRAGMENT_VIEW_CACHE_STATS {
            logger.debug("\(self.cacheStats.debugDescription)")
        }
    }

    func addFragment(_ textLayoutFragment: NSTextLayoutFragment) {
        precondition(isRefreshing, "addFragment can only be called while refreshing")

        // retrieve from cache or create
        if let cached = fragmentViewCache.object(forKey: textLayoutFragment) {
            // update layout fragment
            cached.layoutFragment = textLayoutFragment

            // update frame
            if !cached.frame.isApproximatelyEqual(
                to: textLayoutFragment.layoutFragmentFrame
            ) {
                cached.frame = textLayoutFragment.layoutFragmentFrame
            }

            // add as subview
            addSubview(cached)

            // update stats
            if DebugConfig.DEBUG_FRAGMENT_VIEW_CACHE_STATS {
                cacheStats.hit += 1
            }
        }
        else {
            let fragmentView = RhTextLayoutFragmentView(
                layoutFragment: textLayoutFragment,
                frame: textLayoutFragment.layoutFragmentFrame
            )
            // add to cache
            fragmentViewCache.setObject(fragmentView, forKey: textLayoutFragment)

            // add as subview
            addSubview(fragmentView)

            // update stats
            if DebugConfig.DEBUG_FRAGMENT_VIEW_CACHE_STATS {
                cacheStats.miss += 1
            }
        }
    }

    func clearFragments() {
        // remove subviews
        subviews.removeAll()
    }
}

private final class RhTextLayoutFragmentView: RhView {
    var layoutFragment: NSTextLayoutFragment {
        didSet {
            needsLayout = true
            needsDisplay = true
        }
    }

    init(layoutFragment: NSTextLayoutFragment, frame: CGRect) {
        self.layoutFragment = layoutFragment
        super.init(frame: frame)

        if DebugConfig.DEBUG_LAYOUT_FRAGMENT {
            layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.05).cgColor
            layer?.borderColor = NSColor.systemOrange.cgColor
            layer?.borderWidth = 0.5
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        context.saveGState()
        layoutFragment.draw(at: .zero, in: context)
        context.restoreGState()
    }
}

private struct CacheStats: CustomDebugStringConvertible {
    var size: Int = 0
    var hit: Int = 0
    var miss: Int = 0

    var debugDescription: String {
        """
        cache stats: \(size), hit \(hit), miss \(miss)
        """
    }
}
