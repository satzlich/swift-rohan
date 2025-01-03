// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**

 ```
 RhTextView (subviews from front to back)
    |---RhTextInsertionIndicator
    |---RhContentView
    |---RhSelectionView
 ```
 */
open class RhTextView: RhView {
    var _textContentStorage: NSTextContentStorage
    public private(set) var textLayoutManager: NSTextLayoutManager
    public var textContentManager: NSTextContentManager { _textContentStorage }

    var textContainer: NSTextContainer {
        textLayoutManager.textContainer!
    }

    let contentView: RhContentView
    let selectionView: RhSelectionView

    // MARK: - For Internal Process

    var markedText: RhMarkedText? = nil

    override public required init(frame frameRect: NSRect) {
        // init TextKit managers
        self._textContentStorage = RhTextContentStorage()
        self.textLayoutManager = RhTextLayoutManager()

        // init views
        self.contentView = RhContentView(frame: frameRect)
        self.selectionView = RhSelectionView(frame: frameRect)

        super.init(frame: frameRect)
        setUp()
    }

    public required init?(coder: NSCoder) {
        // init TextKit managers
        self._textContentStorage = RhTextContentStorage()
        self.textLayoutManager = RhTextLayoutManager()

        // init views
        self.contentView = RhContentView()
        self.selectionView = RhSelectionView()

        super.init(coder: coder)

        // set up frame
        contentView.frame = frame
        selectionView.frame = frame

        setUp()
    }

    private func setUp() {
        // set up TextKit managers
        textLayoutManager.textContainer = RhTextContainer()
        textLayoutManager.textContainer!.widthTracksTextView = true
        textLayoutManager.textContainer!.heightTracksTextView = false
        textContentManager.addTextLayoutManager(textLayoutManager)
        textContentManager.primaryTextLayoutManager = textLayoutManager

        // set up properties
        autoresizingMask = [.width, .height]
        backgroundColor = .white

        // set up delegates
        textLayoutManager.textViewportLayoutController.delegate = self

        // set up subviews: content above selection
        addSubview(selectionView)
        addSubview(contentView, positioned: .above, relativeTo: selectionView)

        // set up subviews: auto resize
        selectionView.translatesAutoresizingMaskIntoConstraints = false // must be false
        contentView.translatesAutoresizingMaskIntoConstraints = false // must be false
        NSLayoutConstraint.activate([
            // selection view
            selectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectionView.topAnchor.constraint(equalTo: topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // content view
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // add observers
        NotificationCenter.default.addObserver(
            forName: RhTextLayoutManager.didChangeSelectionNotification,
            object: textLayoutManager,
            queue: .main
        ) { [weak self] notification in

            guard let self = self else {
                return
            }

            // do nothing for the moment
        }
    }

    override open func layout() {
        super.layout()
        layoutTextViewport()
    }

    override public func prepareContent(in rect: NSRect) {
        super.prepareContent(in: rect)
        layoutTextViewport()
    }

    private func layoutTextViewport() {
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    // MARK: - Accept Events

    override public var acceptsFirstResponder: Bool {
        true
    }
}
