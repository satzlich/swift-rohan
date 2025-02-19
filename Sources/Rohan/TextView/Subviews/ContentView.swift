// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import RohanCommon

final class ContentView: RohanView {
  private typealias FragmentViewCache = NSMapTable<NSTextLayoutFragment, TextLayoutFragmentView>

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
    precondition(isRefreshing)
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
      if !cached.frame.isNearlyEqual(to: textLayoutFragment.layoutFragmentFrame) {
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
      let fragmentView = TextLayoutFragmentView(textLayoutFragment)

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

/**
 - Invariant: `frame == layoutFragment.layoutFragmentFrame` (maintained externally)
 */
private final class TextLayoutFragmentView: RohanView {
  var layoutFragment: NSTextLayoutFragment {
    didSet {
      needsLayout = true
      needsDisplay = true
    }
  }

  init(_ layoutFragment: NSTextLayoutFragment) {
    self.layoutFragment = layoutFragment
    super.init(frame: layoutFragment.layoutFragmentFrame)

    // disable for layout fragment, otherwise there will be artifacts
    clipsToBounds = false

    if DebugConfig.DECORATE_LAYOUT_FRAGMENT {
      // draw background and border
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
    guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
    cgContext.saveGState()
    layoutFragment.draw(at: .zero, in: cgContext)
    cgContext.restoreGState()
  }

  override func layout() {
    super.layout()
    layoutAttachmentView()
  }

  private func layoutAttachmentView() {
    for attachmentViewProvider in layoutFragment.textAttachmentViewProviders {
      guard let attachmentView = attachmentViewProvider.view else { continue }
      let attachmentOrigin =
        layoutFragment.frameForTextAttachment(at: attachmentViewProvider.location).origin
      attachmentView.setFrameOrigin(attachmentOrigin)
      if attachmentView.superview == nil {
        addSubview(attachmentView)
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
