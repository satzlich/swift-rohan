// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public class TextLayoutManager {
    internal var nsTextLayoutManager: NSTextLayoutManager

    /** associated content storage */
    public private(set) var textContentStorage: TextContentStorage?

    /** text container */
    public var textContainer: TextContainer? {
        didSet { nsTextLayoutManager.textContainer = textContainer?.nsTextContainer }
    }

    public var documentRange: RhTextRange { textContentStorage!.documentRange }

    var textSelections: [RhTextSelection]

    var textSelectionNavigation: TextSelectionNavigation { preconditionFailure() }

    let styleSheet: StyleSheet

    public init() {
        self.nsTextLayoutManager = .init()
        self.textSelections = []
        self.styleSheet = StyleSheet(Self.styleRules, Self.defaultProperties)
    }

    public func ensureLayout() {
        guard let textContentStorage = textContentStorage else { return }
        let nsTextContentStorage = textContentStorage.nsTextContentStorage
        let context = TextKitLayoutContext(nsTextContentStorage, styleSheet)

        nsTextContentStorage.performEditingTransaction {
            if nsTextContentStorage.textStorage!.length == 0 {
                context.beginEditing()
                textContentStorage.rootNode.performLayout(context, fromScratch: true)
                context.endEditing()
            }
            else {
                context.beginEditing()
                textContentStorage.rootNode.performLayout(context, fromScratch: false)
                context.endEditing()
            }
        }

        nsTextLayoutManager.ensureLayout(for: nsTextContentStorage.documentRange)
    }

    /**
     Enumerate text layout fragments from the given location.

     - Note: `block` should return `false` to stop enumeration.
     */
    public func enumerateTextLayoutFragments(
        from location: (any RhTextLocation)?,
        using block: (TextLayoutFragment) -> Bool
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

    internal func setTextContentStorage(_ textContentStorage: TextContentStorage?) {
        assert(textContentStorage == nil || textContentStorage!.textLayoutManager === self)
        self.textContentStorage = textContentStorage
    }

    // MARK: - Default Styles

    private static let styleRules: StyleRules = [
        // H1
        HeadingNode.selector(level: 1): [
            TextProperty.font: .string("Latin Modern Sans"),
            TextProperty.size: .fontSize(FontSize(20)),
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
