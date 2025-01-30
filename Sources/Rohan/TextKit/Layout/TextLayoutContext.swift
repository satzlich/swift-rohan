// Copyright 2024-2025 Lie Yan

import AppKit

final class TextLayoutContext: LayoutContext {
    let styleSheet: StyleSheet
    let textContentStorage: NSTextContentStorage
    let textLayoutManager: NSTextLayoutManager

    init(_ styleSheet: StyleSheet,
         _ textContentStorage: NSTextContentStorage,
         _ textLayoutManager: NSTextLayoutManager)
    {
        self.styleSheet = styleSheet

        assert(textContentStorage is NSTextContentStoragePatched)
        self.textContentStorage = textContentStorage
        self.textLayoutManager = textLayoutManager

        self._cursor = textContentStorage.textStorage!.length
    }

    // MARK: - State

    /** current cursor location */
    private var _cursor: Int
    var cursor: Int { @inline(__always) get { _cursor } }

    /** `true` if the layout context is in the process of editing */
    private var _isEditing: Bool = false
    var isEditing: Bool { @inline(__always) get { _isEditing } }

    func beginEditing() {
        precondition(isEditing == false)
        _isEditing = true
    }

    func endEditing() {
        precondition(isEditing == true)
        _isEditing = false
    }

    // MARK: - Operations

    func skipBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)
        _cursor -= n
    }

    func deleteBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        // find text range
        let location = cursor - n
        let characterRange = NSRange(location: location, length: n)
        guard let textRange = textContentStorage.textRange(for: characterRange)
        else { preconditionFailure("text range not found") }

        // update state
        textContentStorage.replaceContents(in: textRange, with: nil)
        _cursor = location
    }

    func invalidateBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)

        // find text range
        let location = cursor - n
        let characterRange = NSRange(location: location, length: n)
        guard let textRange = textContentStorage.textRange(for: characterRange)
        else { preconditionFailure("text range not found") }

        // update state
        textLayoutManager.invalidateLayout(for: textRange)
        _cursor = location
    }

    func insertText(_ text: TextNode) {
        precondition(isEditing)

        // find text location
        guard let location = textContentStorage.textLocation(for: cursor)
        else { preconditionFailure("text location not found") }
        // styles
        let properties = text.resolveProperties(styleSheet) as TextProperty
        // create text element
        let attrString = NSAttributedString(string: text.string,
                                            attributes: properties.attributes())
        let textElement = NSTextParagraph(attributedString: attrString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }

    func insertNewline(_ context: Node) {
        precondition(isEditing)

        // find text location
        guard let location = textContentStorage.textLocation(for: cursor)
        else { preconditionFailure("text location not found") }

        // styles
        let attributes = (context.resolveProperties(styleSheet) as TextProperty)
            .attributes()

        // create text element
        let attributedString = NSAttributedString(string: "\n", attributes: attributes)
        assert(attributedString.length == 1)

        let textElement = NSTextParagraph(attributedString: attributedString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }

    func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
        precondition(isEditing)

        // find text location
        guard let location = textContentStorage.textLocation(for: cursor)
        else { preconditionFailure("text location not found") }

        // create text element
        let textElement: NSTextParagraph
        switch fragment {
        case let mathListLayoutFragment as MathListLayoutFragment:
            let attributes = (source.resolveProperties(styleSheet) as TextProperty)
                .attributes()
            textElement = Self.createTextElement(for: mathListLayoutFragment, attributes)
        case _:
            let attributedString = NSAttributedString(string: "$")
            textElement = NSTextParagraph(attributedString: attributedString)
        }

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }

    /**

     - Parameters:
        - attributes: the attributes to be applied to the text element

     - Note: Suitable `attributes` is a must; otherwise the overall layout would
     be visually flawed, specifically the line spacing around the fragment could
     be inconsistent with the rest of the text.
     */
    private static func createTextElement(
        for fragment: MathListLayoutFragment,
        _ attributes: [NSAttributedString.Key: Any]
    ) -> NSTextParagraph {
        let attachment = MathListLayoutAttachment(fragment)

        let attributedString: NSAttributedString
        if #available(macOS 15.0, *) {
            attributedString = NSAttributedString(attachment: attachment,
                                                  attributes: attributes)
        }
        else {
            // Fallback on earlier versions
            let attributedString_ = NSMutableAttributedString(attachment: attachment)
            let range = NSRange(location: 0, length: attributedString_.length)
            attributedString_.setAttributes(attributes, range: range)
            attributedString = attributedString_
        }
        return NSTextParagraph(attributedString: attributedString)
    }
}
