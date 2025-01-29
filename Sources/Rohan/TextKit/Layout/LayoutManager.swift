// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class LayoutManager {
    let styleSheet: StyleSheet

    /** base text layout manager */
    private var _textLayoutManager: NSTextLayoutManager
    var textLayoutManager: NSTextLayoutManager {
        @inline(__always) get { _textLayoutManager }
    }

    /** companion content storage */
    private var _contentStorage: ContentStorage?
    var contentStorage: ContentStorage? { @inline(__always) get { _contentStorage } }

    internal var textContainer: NSTextContainer? {
        @inline(__always) get { _textLayoutManager.textContainer }
        @inline(__always) _modify { yield &_textLayoutManager.textContainer }
    }

    internal var usageBoundsForTextContainer: CGRect {
        @inline(__always) get { _textLayoutManager.usageBoundsForTextContainer }
    }

    internal var textViewportLayoutController: NSTextViewportLayoutController {
        @inline(__always) get { _textLayoutManager.textViewportLayoutController }
    }

    var documentRange: RhTextRange {
        @inline(__always) get { contentStorage!.documentRange }
    }

    var textSelections: [RhTextSelection]
    var textSelectionNavigation: TextSelectionNavigation { preconditionFailure() }

    public init() {
        self.styleSheet = StyleSheet(Self.styleRules, Self.defaultProperties)
        self._textLayoutManager = NSTextLayoutManager()
        self.textSelections = []
    }

    public func ensureLayout(delayed: Bool = false) {
        guard let contentStorage else { return }

        let textContentStorage = contentStorage.textContentStorage
        let context =
            TextLayoutContext(styleSheet, textContentStorage, _textLayoutManager)

        textContentStorage.performEditingTransaction {
            if textContentStorage.documentRange.isEmpty {
                context.beginEditing()
                contentStorage.rootNode.performLayout(context, fromScratch: true)
                context.endEditing()
            }
            else {
                context.beginEditing()
                contentStorage.rootNode.performLayout(context, fromScratch: false)
                context.endEditing()
            }
        }

        if delayed {
            let endLocation = textContentStorage.documentRange.endLocation
            _textLayoutManager.ensureLayout(for: NSTextRange(location: endLocation))
        }
        else {
            _textLayoutManager.ensureLayout(for: textContentStorage.documentRange)
        }
    }

    /**
     Enumerate text layout fragments from the given location.

     - Note: `block` should return `false` to stop enumeration.
     */
    public func enumerateTextLayoutFragments(
        from location: (any TextLocation)?,
        using block: (NSTextLayoutFragment) -> Bool
    ) -> (any TextLocation)? {
        preconditionFailure()
    }

    /**
     Enumerate text segments in the given range.

     - Note: `block` should return `false` to stop enumeration.
     */
    public func enumerateTextSegments(
        in textRange: RhTextRange,
        /* (textSegmentRange, textSegmentFrame, baselinePosition) -> continue */
        using block: (RhTextRange?, CGRect, CGFloat) -> Bool
    ) {
        preconditionFailure()
    }

    internal func setContentStorage(_ contentStorage: ContentStorage?) {
        assert(contentStorage == nil || contentStorage!.layoutManager === self)
        _contentStorage = contentStorage
    }

    // MARK: - Default Styles

    private static let styleRules: StyleRules = [
        // H1
        HeadingNode.selector(level: 1): [
            TextProperty.font: .string("Latin Modern Sans"),
            TextProperty.size: .fontSize(FontSize(18)),
            TextProperty.style: .fontStyle(.italic),
            TextProperty.foregroundColor: .color(.blue),
        ],
    ]

    private static let defaultProperties: PropertyMapping =
        [
            // text
            TextProperty.font: .string("Latin Modern Roman"),
            TextProperty.size: .fontSize(FontSize(12)),
            TextProperty.stretch: .fontStretch(.normal),
            TextProperty.style: .fontStyle(.normal),
            TextProperty.weight: .fontWeight(.regular),
            TextProperty.foregroundColor: .color(.black),
            // equation
            MathProperty.font: .string("Latin Modern Math"),
            MathProperty.bold: .bool(false),
            MathProperty.italic: .none,
            MathProperty.cramped: .bool(false),
            MathProperty.style: .mathStyle(.display),
            MathProperty.variant: .mathVariant(.serif),
            // paragraph
            ParagraphProperty.topMargin: .float(.zero),
            ParagraphProperty.bottomMargin: .float(.zero),
            ParagraphProperty.topPadding: .float(.zero),
            ParagraphProperty.bottomPadding: .float(.zero),
        ]
}
