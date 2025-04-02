// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class TextView: NSView {
  public let documentManager = DocumentManager(StyleSheet.latinModern(20))

  // subviews
  let selectionView: SelectionView
  let contentView: ContentView
  let insertionIndicatorView: InsertionIndicatorView

  // Update requests
  var _updateLock = NSLock()
  var _isUpdateEnqueued = false
  /// Whether scroll position is dirty and needs to be updated.
  var _pendingScrollUpdate = false
  /// Whether selection is dirty and needs to be updated.
  var _pendingSelectionUpdate = false

  // IME support
  internal var _markedText: MarkedText? = nil

  // Undo support
  let _undoManager: UndoManager = UndoManager()

  // Copy/Paste support
  private(set) var _pasteboardManagers: [any PasteboardManager] = []

  override public init(frame frameRect: NSRect) {
    self.selectionView = SelectionView(frame: frameRect)
    self.contentView = ContentView(frame: frameRect)
    self.insertionIndicatorView = InsertionIndicatorView(frame: frameRect)
    super.init(frame: frameRect)
    _setUp()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    self.selectionView = SelectionView()
    self.contentView = ContentView()
    self.insertionIndicatorView = InsertionIndicatorView()
    super.init(coder: coder)
    // set up frame to align with init(frame:)
    selectionView.frame = frame
    contentView.frame = frame
    insertionIndicatorView.frame = frame
    _setUp()
  }

  private func _setUp() {
    // set up text container
    documentManager.textContainer = NSTextContainer()
    documentManager.textContainer!.widthTracksTextView = true
    documentManager.textContainer!.heightTracksTextView = true

    // set NSTextViewportLayoutControllerDelegate
    documentManager.textViewportLayoutController.delegate = self

    // set up view properties
    wantsLayer = true
    clipsToBounds = true
    layer?.backgroundColor = NSColor.white.cgColor

    // add subviews
    addSubview(selectionView)
    addSubview(contentView, positioned: .above, relativeTo: selectionView)
    addSubview(insertionIndicatorView, positioned: .above, relativeTo: contentView)

    // set up constraints for resizing
    func setConstraints(on view: NSView) {
      view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: topAnchor),
        view.bottomAnchor.constraint(equalTo: bottomAnchor),
        view.leadingAnchor.constraint(equalTo: leadingAnchor),
        view.trailingAnchor.constraint(equalTo: trailingAnchor),
      ])
    }
    autoresizingMask = [.width, .height]
    setConstraints(on: selectionView)
    setConstraints(on: contentView)
    setConstraints(on: insertionIndicatorView)

    // set up pasteboard managers
    _pasteboardManagers.append(contentsOf: [
      // order matters: prefer rohan type over string type
      RohanPasteboardManager(self) as PasteboardManager,
      StringPasteboardManager(self),
    ])
  }

  override public var isFlipped: Bool {
    #if os(macOS)
    true
    #else
    false
    #endif
  }

  override public func layout() {
    super.layout()
    layoutTextViewport()
  }

  override public func prepareContent(in rect: NSRect) {
    super.prepareContent(in: rect)
    layoutTextViewport()
  }

  private func layoutTextViewport() {
    documentManager.textViewportLayoutController.layoutViewport()
  }

  // MARK: - Accept Events

  override public var acceptsFirstResponder: Bool { true }
}
