// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class RhTextLayoutManager {
    internal var nsTextLayoutManager: NSTextLayoutManager

    /** associated content storage */
    public private(set) var textContentStorage: RhTextContentStorage?

    /** text container */
    public var textContainer: RhTextContainer? {
        didSet { nsTextLayoutManager.textContainer = textContainer?.nsTextContainer }
    }

    public var documentRange: RhTextRange { textContentStorage!.documentRange }

    var textSelections: [RhTextSelection]

    var textSelectionNavigation: RhTextSelectionNavigation { preconditionFailure() }

    public init() {
        self.nsTextLayoutManager = .init()
        self.textSelections = []
    }

    public func ensureLayout(for range: RhTextRange) { preconditionFailure() }

    /**
     Enumerate text layout fragments from the given location.

     - Note: `block` should return `false` to stop enumeration.
     */
    public func enumerateTextLayoutFragments(
        from location: (any RhTextLocation)?,
        using block: (RhTextLayoutFragment) -> Bool
    ) -> (any RhTextLocation)? {
        preconditionFailure()
    }

    /**
     Enumerate text segments in the given range.

     Definition of closure `block`:
     ```swift
     func block(
         textSegmentRange: RhTextRange?,
         textSegmentFrame: CGRect,
         baselinePosition: CGFloat
     ) -> Bool
     ```
     It should return `false` to stop enumeration.
     */
    public func enumerateTextSegments(
        in textRange: RhTextRange,
        using block: (RhTextRange?, CGRect, CGFloat) -> Bool
    ) {
        preconditionFailure()
    }

    internal func setTextContentStorage(_ textContentStorage: RhTextContentStorage?) {
        assert(textContentStorage == nil || textContentStorage!.textLayoutManager === self)
        self.textContentStorage = textContentStorage
    }
}
