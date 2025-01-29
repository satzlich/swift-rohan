// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public final class TextView: NSView {
    public let contentStorage: ContentStorage = .init()
    public let layoutManager: LayoutManager = .init()

    // subviews

    let contentView: ContentView

    override public init(frame frameRect: NSRect) {
        self.contentView = ContentView(frame: frameRect)
        super.init(frame: frameRect)
        setUp()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        self.contentView = ContentView()
        super.init(coder: coder)
        // set up frame to align with init(frame:)
        contentView.frame = frame
        setUp()
    }

    private func setUp() {
        // set up content storage and layout manager
        layoutManager.textContainer = NSTextContainer()
        layoutManager.textContainer!.widthTracksTextView = true
        layoutManager.textContainer!.heightTracksTextView = true
        contentStorage.setLayoutManager(layoutManager)

        // set up NSTextViewportLayoutControllerDelegate
        layoutManager.textViewportLayoutController.delegate = self

        // set up properties
        wantsLayer = true
        clipsToBounds = true
        layer?.backgroundColor = NSColor.white.cgColor
        autoresizingMask = [.width, .height]

        // set up subviews
        addSubview(contentView)

        // set up constraints
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
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
        layoutManager.textViewportLayoutController.layoutViewport()
    }

    // MARK: - Accept Events

    override public var acceptsFirstResponder: Bool { true }
}
