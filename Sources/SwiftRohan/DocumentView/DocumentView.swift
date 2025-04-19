// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class DocumentView: NSView {
  /// Document content
  public var content: DocumentContent = .init() {
    didSet {
      // reset document manager
      documentManager = DocumentManager(content: content, documentManager.styleSheet)
      _setUpDocumentManager()

      // reset undo history
      _undoManager.removeAllActions()

      // request layout
      self.needsLayout = true
      self.setNeedsUpdate(selection: true)
    }
  }

  /// Style sheet for rendering
  public var styleSheet: StyleSheet {
    get { documentManager.styleSheet }
    _modify { yield &documentManager.styleSheet }
  }

  /// Page width for rendering
  public var pageWidth: CGFloat? = nil {
    didSet {
      if let pageWidth = pageWidth {
        let size = frame.size.with(width: pageWidth)
        self.setFrameSize(size)
        assert(frame.size.width == pageWidth)
        assert(bounds.size.width == pageWidth)
      }

      needsLayout = true
      setNeedsUpdate(selection: true, scroll: true)
    }
  }

  /// True if visual delimiters are enabled. Default to true.
  public var isVisualDelimiterEnabled: Bool = true

  /// Key to trigger completion. Default to backslash.
  public var triggerKey: Character? = "\\"

  /// Delegate for document view
  public var delegate: DocumentViewDelegate? = nil

  internal var documentManager = DocumentManager(StyleSheets.latinModern(12))

  // MARK: - Subviews

  let selectionView: SelectionView
  let contentView: ContentView
  let insertionIndicatorView: InsertionIndicatorView

  // MARK: - Selection/Scroll Update

  // Update requests
  var _isUpdateEnqueued = false
  /// Whether scroll position is dirty and needs to be updated.
  var _pendingScrollUpdate = false
  /// Whether selection is dirty and needs to be updated.
  var _pendingSelectionUpdate = false

  // MARK: - Misc support

  // IME support
  internal var _markedText: MarkedText? = nil
  // Undo support
  internal let _undoManager: UndoManager = UndoManager()
  // Copy/Paste support
  internal private(set) var _pasteboardManagers: [any PasteboardManager] = []

  // MARK: - Completion Support

  /// Dispatch queue for accessing completion provider
  private let providerAccessQueue =
    DispatchQueue(label: "providerAccessQueue", attributes: .concurrent)

  /// Completion provider
  private var _completionProvider: CompletionProvider? = nil

  /// Completion provider for text completion
  /// - Warning: Placed below `providerAccessQueue` and `_completionProvider`
  ///     to ensure initialisation order.
  public weak var completionProvider: CompletionProvider? {
    get {
      providerAccessQueue.sync { _completionProvider }
    }
    set {
      providerAccessQueue.async(flags: .barrier) {
        self._completionProvider = newValue
      }
    }
  }

  // MARK: - Initialisation

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
    _setUpDocumentManager()

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
    autoresizingMask = [.height]  // exclude width
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

  private func _setUpDocumentManager() {
    // set up text container
    documentManager.textContainer = NSTextContainer()
    documentManager.textContainer!.widthTracksTextView = true
    documentManager.textContainer!.heightTracksTextView = true

    // set NSTextViewportLayoutControllerDelegate
    documentManager.textViewportLayoutController.delegate = self
  }

  // MARK: - Flags

  override public var isFlipped: Bool {
    #if os(macOS)
    true
    #else
    false
    #endif
  }

  override public var acceptsFirstResponder: Bool { true }

  // MARK: - Layout

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
}
