// Copyright 2024 Lie Yan

import AppKit
import Foundation

/**

 ```
 RhTextView
    |---RhContentView
    |---RhSelectionView
    |---RhTextInsertionIndicator
 ```
 */
open class RhTextView: RhView {
    typealias FragmentViewMap = NSMapTable<NSTextLayoutFragment, RhTextLayoutFragmentView>

    private(set) var textContentManager: NSTextContentManager
    private(set) var textLayoutManager: NSTextLayoutManager

    var textContainer: NSTextContainer {
        textLayoutManager.textContainer!
    }

    private(set) var fragmentViewMap: FragmentViewMap
    let contentView: RhContentView
    let selectionView: RhSelectionView

    override public init(frame frameRect: NSRect) {
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

        // set up delegates
        textLayoutManager.textViewportLayoutController.delegate = self

        // set up subviews
        addSubview(contentView)
        addSubview(selectionView)
    }

    override open func layout() {
        _propagateViewSize()

        super.layout()
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    func _propagateViewSize() {
        // update content view size
        contentView.frame = CGRect(origin: .zero, size: bounds.size)

        // update text container size
        textContainer.size = CGSize(width: bounds.size.width, height: 0)
    }
}
