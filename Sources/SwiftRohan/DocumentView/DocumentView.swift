// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import LatexParser

public final class DocumentView: NSView {
  /// Document content
  public private(set) var content: DocumentContent = DocumentContent()

  /// Style sheet for rendering
  public var styleSheet: StyleSheet {
    get { documentManager.styleSheet }
    set {
      documentManager.styleSheet = newValue
      _setPageConstraints(newValue.resolveDefault() as PageProperty)
      documentStyleDidChange()
    }
  }

  /// Set content with style sheet. Property `content` and `styleSheet` will be set
  /// to the provided values.
  public func setContent(_ content: DocumentContent, with styleSheet: StyleSheet? = nil) {
    self.content = content

    // reset document manager
    // No need to explicitly set styleSheet, as it will be set in documentManager.
    let styleSheet = styleSheet ?? self.styleSheet
    documentManager = DocumentManager(content: content, styleSheet)

    _setUpDocumentManager()
    _setPageConstraints(styleSheet.resolveDefault() as PageProperty)

    // reset undo history
    _undoManager.removeAllActions()

    // request update
    documentContentDidChange(layoutScope: .document, notifyChange: false)
  }

  /// True if visual delimiters are enabled. Default to true.
  public var isVisualDelimiterEnabled: Bool = true

  /// Key to trigger completion. Default to backslash.
  public var triggerKey: Character? = "\\"

  /// Delegate for document view
  public var delegate: DocumentViewDelegate? = nil

  // NOTE: set a large default font size so that when something goes wrong,
  // the mistake is conspicuous.
  internal var documentManager = DocumentManager(StyleSheets.defaultRecord.provider(20))

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

  /// Get the scroll view that immediately encloses the text view.
  var scrollView: NSScrollView? {
    if let enclosingScrollView = enclosingScrollView,
      enclosingScrollView.documentView == self
    {
      return enclosingScrollView
    }
    return nil
  }

  // MARK: - Misc support

  // Editing state
  internal var _isEditing = false
  // IME support
  internal var _markedText: MarkedText? = nil
  // Undo support
  internal let _undoManager: UndoManager = UndoManager()
  // Copy/Paste support
  internal private(set) var _pasteboardManagers: [any PasteboardManager] = []

  // MARK: - Abstractions Support

  /// Completion provider for text completion
  public var completionProvider: CompletionProvider?
  /// Replacement engine for auto replacement
  public var replacementProvider: ReplacementProvider?

  // MARK: - Initialisation

  override public init(frame frameRect: NSRect) {
    self.selectionView = SelectionView(frame: frameRect)
    self.contentView = ContentView(frame: frameRect)
    self.insertionIndicatorView = InsertionIndicatorView(frame: frameRect)
    super.init(frame: frameRect)
    _setUp()
  }

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
    clipsToBounds = false
    layer?.backgroundColor = NSColor.white.cgColor

    // add subviews
    addSubview(selectionView)
    addSubview(contentView, positioned: .above, relativeTo: selectionView)
    addSubview(insertionIndicatorView, positioned: .above, relativeTo: contentView)

    // set up constraints for resizing
    autoresizingMask = [.height]  // exclude width
    _setPageConstraints(documentManager.styleSheet.resolveDefault() as PageProperty)

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
    documentManager.textLayoutManager.delegate = self
  }

  private func _setPageConstraints(_ page: PageProperty) {

    // margin
    setMarginConstraints(contentView)
    setMarginConstraints(selectionView)
    setMarginConstraints(insertionIndicatorView)

    // width
    self.frame.size.width = page.width.ptValue

    // Helper

    func setMarginConstraints(_ view: NSView) {
      view.translatesAutoresizingMaskIntoConstraints = false

      let topMargin = page.topMargin.ptValue
      let bottomMargin = page.bottomMargin.ptValue
      let leftMargin = page.leftMargin.ptValue
      let rightMargin = page.rightMargin.ptValue

      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: topAnchor, constant: topMargin),
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomMargin),
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftMargin),
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightMargin),
      ])
    }
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
