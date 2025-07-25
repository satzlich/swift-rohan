import AppKit
import Foundation

final class LayoutFragmentAttachment: NSTextAttachment {
  let fragment: LayoutFragment

  init(_ fragment: LayoutFragment) {
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
    let viewProvider = LayoutFragmentAttachmentViewProvider(
      textAttachment: self,
      parentView: parentView,
      textLayoutManager: textContainer?.textLayoutManager,
      location: location
    )

    viewProvider.tracksTextAttachmentViewBounds = true  // required
    return viewProvider
  }

  /// - Important: Return a default image to stop drawing a placeholder image.
  override public func image(
    forBounds imageBounds: CGRect,
    textContainer: NSTextContainer?,
    characterIndex charIndex: Int
  ) -> NSImage? {
    NSImage()
  }
}

// This class is not thread-safe, so we mark it as `@unchecked Sendable`.
extension LayoutFragmentAttachment: @unchecked Sendable {}

private final class LayoutFragmentAttachmentViewProvider: NSTextAttachmentViewProvider {
  override public func loadView() {
    guard let attachment = textAttachment as? LayoutFragmentAttachment else { return }
    self.view = runOnMainThread { LayoutFragmentView(attachment.fragment) }
  }

  override public func attachmentBounds(
    for attributes: Dictionary<NSAttributedString.Key, Any>,
    location: any NSTextLocation,
    textContainer: NSTextContainer?,
    proposedLineFragment: CGRect,
    position: CGPoint
  ) -> CGRect {
    guard let attachment = textAttachment as? LayoutFragmentAttachment,
      let view = self.view
    else { return .zero }

    // ensure bounds are up-to-date
    let actualBounds = attachment.fragment.bounds

    runOnMainThread {
      if !actualBounds.isNearlyEqual(to: view.bounds) {
        // IMPORTANT: We must update the bounds of the view AFTER setting the frame size.
        // Otherwise, the view will have weird behaivour.
        view.frame.size = actualBounds.size
        view.bounds = actualBounds
        assert(view.frame.size == actualBounds.size)
      }
    }

    return actualBounds
  }
}

private final class LayoutFragmentView: RohanView {
  let fragment: LayoutFragment

  init(_ fragment: LayoutFragment) {
    self.fragment = fragment

    let size = CGSize(width: fragment.width, height: fragment.height)
    super.init(frame: CGRect(origin: .zero, size: size))

    // expose box metrics
    self.bounds = fragment.bounds

    // disable clipsToBounds for layout fragment, otherwise there will be artifacts
    assert(clipsToBounds == false)

    #if DEBUG && DECORATE_LAYOUT_FRAGMENT
    // draw background and border
    layer?.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.05).cgColor
    layer?.borderColor = NSColor.systemGreen.cgColor
    layer?.borderWidth = 0.5
    #endif
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ dirtyRect: NSRect) {
    guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
    // the fragment origin differs from the view origin
    let origin = bounds.origin.with(yDelta: fragment.ascent)
    fragment.draw(at: origin, in: cgContext)
  }
}
