// Copyright 2024 Lie Yan

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
    typealias FragmentViewMap = NSMapTable<NSTextLayoutFragment, RhTextLayoutFragmentView>

    public private(set) var textContentManager: NSTextContentManager
    public private(set) var textLayoutManager: NSTextLayoutManager

    var textContainer: NSTextContainer {
        textLayoutManager.textContainer!
    }

    private(set) var fragmentViewMap: FragmentViewMap
    let contentView: RhContentView
    let selectionView: RhSelectionView

    override public required init(frame frameRect: NSRect) {
        // init TextKit managers
        self.textContentManager = RhTextContentStorage()
        self.textLayoutManager = RhTextLayoutManager()

        // init views
        self.fragmentViewMap = NSMapTable.weakToWeakObjects()
        self.contentView = RhContentView()
        self.selectionView = RhSelectionView()

        super.init(frame: frameRect)
        setUp()
    }

    public required init?(coder: NSCoder) {
        // init TextKit managers
        self.textContentManager = RhTextContentStorage()
        self.textLayoutManager = RhTextLayoutManager()

        // init views
        self.fragmentViewMap = NSMapTable.weakToWeakObjects()
        self.contentView = RhContentView()
        self.selectionView = RhSelectionView()

        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        // set up TextKit managers
        textLayoutManager.textContainer = RhTextContainer()
        textLayoutManager.textContainer!.widthTracksTextView = false
        textLayoutManager.textContainer!.heightTracksTextView = true
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
    }

    override open func layout() {
        _propagateTextViewSize()

        super.layout()
        _layoutTextViewport()

        _propagateTextContainerSize()
    }

    func _layoutTextViewport() {
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    /**
     Propagate view width to text container
     */
    func _propagateTextViewSize() {
        textContainer.size = CGSize(width: bounds.width, height: 0)
    }

    /**
     Propagate text container height to views
     */
    func _propagateTextContainerSize() {
        let size = NSSize(
            width: bounds.width,
            height: textLayoutManager.usageBoundsForTextContainer.height
        )
        setFrameSize(size)
        contentView.setFrameSize(size)
        selectionView.setFrameSize(size)
    }
}
