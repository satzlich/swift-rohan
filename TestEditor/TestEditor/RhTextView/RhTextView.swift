// Copyright 2024 Lie Yan

import AppKit
import Foundation

@objc open class RhTextView: NSView {
    typealias FragmentViewMap = NSMapTable<NSTextLayoutFragment, RhTextLayoutFragmentView>

    @objc open private(set) var textContentManager: NSTextContentManager
    @objc open private(set) var textLayoutManager: NSTextLayoutManager

    var fragmentViewMap: FragmentViewMap
    let contentView: RhContentView

    override public init(frame frameRect: NSRect) {
        // init content manager and layout manager
        self.textContentManager = RhTextContentStorage()
        self.textLayoutManager = RhTextLayoutManager()

        // init views
        self.fragmentViewMap = NSMapTable.weakToWeakObjects()
        self.contentView = RhContentView()

        super.init(frame: frameRect)

        setUp()
    }

    public required init?(coder: NSCoder) {
        // init content manager and layout manager
        self.textContentManager = RhTextContentStorage()
        self.textLayoutManager = RhTextLayoutManager()

        // init views
        self.fragmentViewMap = NSMapTable.weakToWeakObjects()
        self.contentView = RhContentView()

        super.init(coder: coder)

        setUp()
    }

    func setUp() {
        // set up content manager and layout manager
        textLayoutManager.textContainer = RhTextContainer()
        textLayoutManager.textContainer!.widthTracksTextView = false
        textLayoutManager.textContainer!.heightTracksTextView = true
        textContentManager.addTextLayoutManager(textLayoutManager)
        textContentManager.primaryTextLayoutManager = textLayoutManager

        // set up properties
        wantsLayer = true
        autoresizingMask = [.width, .height]

        // set up delegates
        textLayoutManager.textViewportLayoutController.delegate = self

        // set up subviews
        addSubview(contentView)
    }

    override open var isFlipped: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    func layoutViewport() {
        /*
         layoutViewport doesn't handle layout range properly:
         for far jump it tries to layout everything starting at location 0
         even though viewport range is properly calculated.

         No known workaround.
         */
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    override open func layout() {
        super.layout()
        layoutViewport()
    }

    override open func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        layoutViewport()
    }
}
