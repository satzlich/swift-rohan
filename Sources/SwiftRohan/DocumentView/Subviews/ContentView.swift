// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

private let DECORATE_CONTENT_VIEW = false

final class ContentView: RohanView {
  private typealias FragmentViewCache =
    NSMapTable<NSTextLayoutFragment, TextLayoutFragmentView>

  private var fragmentViewCache: FragmentViewCache = .weakToWeakObjects()
  private var isRefreshing: Bool = false
  private var cacheStats = CacheStats()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    // TextKit may produce fragments beyond the bounds of the content view,
    // so we disable clipping to bounds to ensure all fragments are visible.
    assert(clipsToBounds == false)

    #if DEBUG && DECORATE_CONTENT_VIEW
    layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05).cgColor
    #endif
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func beginRefreshing() {
    precondition(!isRefreshing)
    // mark as refreshing
    isRefreshing = true
    // clear existing fragments
    clearFragments()
    // reset stats
    #if DEBUG && COLLECT_STATS_FRAGMENT_VIEW_CACHE
    cacheStats.size = fragmentViewCache.count
    cacheStats.hit = 0
    cacheStats.miss = 0
    #endif
  }

  func endRefreshing() {
    precondition(isRefreshing)
    // mark as not refreshing
    isRefreshing = false
    // log stats
    #if DEBUG && COLLECT_STATS_FRAGMENT_VIEW_CACHE
    cacheStats.endSize = fragmentViewCache.count
    Rohan.logger.debug("\(self.cacheStats.debugDescription)")
    #endif
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
      #if DEBUG && COLLECT_STATS_FRAGMENT_VIEW_CACHE
      cacheStats.hit += 1
      #endif
    }
    else {
      let fragmentView = TextLayoutFragmentView(textLayoutFragment)

      // add to cache
      fragmentViewCache.setObject(fragmentView, forKey: textLayoutFragment)

      // add as subview
      addSubview(fragmentView)

      // update stats
      #if DEBUG && COLLECT_STATS_FRAGMENT_VIEW_CACHE
      cacheStats.miss += 1
      #endif
    }
  }

  func clearFragments() {
    // remove subviews
    subviews.removeAll()
  }
}

/// - Invariant: `frame == layoutFragment.layoutFragmentFrame` (maintained externally)
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

    // disable clipsToBounds for layout fragment, otherwise there will be artifacts
    assert(clipsToBounds == false)

    #if DEBUG && DECORATE_LAYOUT_FRAGMENT
    // draw background and border
    layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.05).cgColor
    layer?.borderColor = NSColor.systemOrange.cgColor
    layer?.borderWidth = 0.5
    #endif
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
    "cache stats: \(size) -> \(endSize), hit \(hit), miss \(miss)"
  }
}
