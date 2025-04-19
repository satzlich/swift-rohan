// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import SwiftRohan

/**

 ```
 RhContentView
    |---RhTextLayoutFragmentView *
 ```
 */
final class RhContentView: RhView {
    private typealias FragmentViewCache
        = NSMapTable<NSTextLayoutFragment, RhTextLayoutFragmentView>

    private var fragmentViewCache: FragmentViewCache = .weakToWeakObjects()
    private var isRefreshing: Bool = false
    private var cacheStats = CacheStats()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        if DebugConfig.DECORATE_CONTENT_VIEW {
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
            if !cached.frame.isNearlyEqual(
                to: textLayoutFragment.layoutFragmentFrame
            ) {
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
            let fragmentView = RhTextLayoutFragmentView(
                layoutFragment: textLayoutFragment,
                frame: textLayoutFragment.layoutFragmentFrame
            )
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

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext
        else { return }

        layoutFragment.draw(at: .zero, in: context)
        for viewProvider in layoutFragment.textAttachmentViewProviders {
            if let view = viewProvider.view {
                let frame = layoutFragment.frameForTextAttachment(at: viewProvider.location)

                view.frame = frame
                view.draw(frame)
            }
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
