// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**

 ```
 RhTextView (subviews from front to back)
    |---RhInsertionIndicatorView
    |---RhContentView
    |---RhSelectionView
 ```
 */
open class RhTextView: RhView {
    // TextKit
    public var textContentManager: NSTextContentManager { _textContentStorage }
    public private(set) var textLayoutManager: NSTextLayoutManager = RhTextLayoutManager()
    var _textContentStorage: NSTextContentStorage = RhTextContentStorage()

    // Views
    let insertionIndicatorView: RhInsertionIndicatorView
    let contentView: RhContentView
    let selectionView: RhSelectionView

    /// for text input client
    var _markedText: RhMarkedText? = nil

    override public class var defaultMenu: NSMenu? {
        // evaluated once, and cached
        let menu = super.defaultMenu ?? NSMenu()

        let pasteAsPlainText =
            NSMenuItem(
                title: NSLocalizedString("Paste and Match Style", comment: ""),
                action: #selector(pasteAsPlainText(_:)),
                keyEquivalent: "V"
            )
        pasteAsPlainText.keyEquivalentModifierMask = [.option, .command, .shift]

        menu.items = [
            NSMenuItem(title: NSLocalizedString("Cut", comment: ""),
                       action: #selector(cut(_:)),
                       keyEquivalent: "x"),
            NSMenuItem(title: NSLocalizedString("Copy", comment: ""),
                       action: #selector(copy(_:)),
                       keyEquivalent: "c"),
            NSMenuItem(title: NSLocalizedString("Paste", comment: ""),
                       action: #selector(paste(_:)),
                       keyEquivalent: "v"),
            pasteAsPlainText,
            NSMenuItem.separator(),
            NSMenuItem(title: NSLocalizedString("Select All", comment: ""),
                       action: #selector(selectAll(_:)),
                       keyEquivalent: "a"),
        ]

        return menu
    }

    override public required init(frame frameRect: NSRect) {
        // init views
        self.insertionIndicatorView = RhInsertionIndicatorView(frame: frameRect)
        self.contentView = RhContentView(frame: frameRect)
        self.selectionView = RhSelectionView(frame: frameRect)

        super.init(frame: frameRect)
        setUp()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        // init views
        self.insertionIndicatorView = RhInsertionIndicatorView()
        self.contentView = RhContentView()
        self.selectionView = RhSelectionView()

        super.init(coder: coder)

        // set up frame
        insertionIndicatorView.frame = frame
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

        // set up subviews: insertion indicator above content above selection
        addSubview(selectionView)
        addSubview(contentView, positioned: .above, relativeTo: selectionView)
        addSubview(insertionIndicatorView, positioned: .above, relativeTo: contentView)

        // set up subviews: auto resize
        selectionView.translatesAutoresizingMaskIntoConstraints = false // must be false
        contentView.translatesAutoresizingMaskIntoConstraints = false // must be false
        insertionIndicatorView.translatesAutoresizingMaskIntoConstraints = false // must be false
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
            // insertion indicator view
            insertionIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            insertionIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            insertionIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            insertionIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // add observers
        NotificationCenter.default.addObserver(
            forName: RhTextLayoutManager.didChangeSelectionNotification,
            object: textLayoutManager,
            queue: .main
        ) { [weak self] notification in

            guard self != nil else { return }

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
