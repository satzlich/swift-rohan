// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class MathListLayoutAttachment: NSTextAttachment {
  let fragment: MathListLayoutFragment

  init(_ fragment: MathListLayoutFragment) {
    self.fragment = fragment
    super.init(data: nil, ofType: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewProvider(
    for parentView: NSView?,
    location: any NSTextLocation,
    textContainer: NSTextContainer?
  ) -> NSTextAttachmentViewProvider? {
    let viewProvider = MathListLayoutAttachmentViewProvider(
      textAttachment: self,
      parentView: parentView,
      textLayoutManager: textContainer?.textLayoutManager,
      location: location
    )
    // IMPORTANT: tracksTextAttachmentViewBounds is required
    viewProvider.tracksTextAttachmentViewBounds = true
    return viewProvider
  }

  /** - Important: Return a default image to stop drawing a placeholder image. */
  override public func image(
    forBounds imageBounds: CGRect,
    textContainer: NSTextContainer?,
    characterIndex charIndex: Int
  ) -> NSImage? {
    NSImage()
  }
}

private final class MathListLayoutAttachmentViewProvider: NSTextAttachmentViewProvider {
  override public func loadView() {
    guard let attachment = textAttachment as? MathListLayoutAttachment else { return }
    view = MathListLayoutView(attachment.fragment)
  }

  override public func attachmentBounds(
    for attributes: [NSAttributedString.Key: Any],
    location: any NSTextLocation,
    textContainer: NSTextContainer?,
    proposedLineFragment: CGRect,
    position: CGPoint
  ) -> CGRect {
    guard let attachment = textAttachment as? MathListLayoutAttachment,
      let view
    else { return .zero }

    // ensure bounds are up-to-date
    let actualBounds = attachment.fragment.bounds
    if !actualBounds.isNearlyEqual(to: view.bounds) {
      // IMPORTANT: We must update the bounds of the view AFTER setting the frame size.
      // Otherwise, the view will have weird behaivour.
      view.frame.size = actualBounds.size
      view.bounds = actualBounds
      assert(view.frame.size == actualBounds.size)
    }
    return actualBounds
  }
}

private final class MathListLayoutView: RohanView {
  let fragment: MathListLayoutFragment

  init(_ fragment: MathListLayoutFragment) {
    self.fragment = fragment
    super.init(frame: CGRect(origin: .zero, size: fragment.glyphFrame.size))

    // expose box metrics
    self.bounds = fragment.bounds
    // disable for layout fragment, otherwise there will be artifacts
    clipsToBounds = false

    if DebugConfig.DECORATE_LAYOUT_FRAGMENT {
      // draw background and border
      layer?.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.05).cgColor
      layer?.borderColor = NSColor.systemGreen.cgColor
      layer?.borderWidth = 0.5
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ dirtyRect: NSRect) {
    guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
    // the fragment origin differs from the view origin
    let origin = CGPoint(x: bounds.origin.x, y: bounds.origin.y + fragment.ascent)
    fragment.draw(at: origin, in: cgContext)
  }
}
