// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutContext {
    var cursor: Int { get }

    // MARK: - State

    var isEditing: Bool { get }
    func beginEditing()
    func endEditing()

    // MARK: - Operations

    func skipBackwards(_ n: Int)
    func deleteBackwards(_ n: Int)
    func insertText(_ text: TextNode)
    func insertNewline()
    func insertFragment(_ fragment: LayoutFragment)
}

final class TextKitLayoutContext: LayoutContext {
    private(set) var cursor: Int
    private(set) var isEditing: Bool = false

    let textContentStorage: NSTextContentStorage_fix
    let styleSheet: StyleSheet

    init(_ textContentStorage: NSTextContentStorage_fix, _ styleSheet: StyleSheet) {
        self.textContentStorage = textContentStorage
        self.styleSheet = styleSheet
        self.cursor = textContentStorage.textStorage!.length
    }

    func beginEditing() {
        precondition(isEditing == false)
        isEditing = true
    }

    func endEditing() {
        precondition(isEditing == true)
        isEditing = false
    }

    func skipBackwards(_ n: Int) {
        precondition(isEditing && n >= 0 && cursor >= n)
        cursor -= n
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
        cursor = location
    }

    func insertText(_ text: TextNode) {
        precondition(isEditing)

        // find text location
        guard let location = textContentStorage.textLocation(for: cursor)
        else { preconditionFailure("text location not found") }
        // styles
        let properties = text.resolve(with: styleSheet) as TextProperty
        // create text element
        let attrString = NSAttributedString(string: text.string,
                                            attributes: properties.attributes())
        let textElement = NSTextParagraph(attributedString: attrString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }

    func insertNewline() {
        precondition(isEditing)

        // find text location
        guard let location = textContentStorage.textLocation(for: cursor)
        else { preconditionFailure("text location not found") }

        // create text element
        let attributedString = NSAttributedString(string: "\n")
        assert(attributedString.length == 1)

        let textElement = NSTextParagraph(attributedString: attributedString)

        // update state
        textContentStorage.replaceContents(in: NSTextRange(location: location),
                                           with: [textElement])
    }

    func insertFragment(_ fragment: any LayoutFragment) {
        precondition(isEditing)
        preconditionFailure("TODO: insert fragment")
    }
}

final class MathLayoutContext: LayoutContext {
    private(set) var cursor: Int = 0
    private(set) var isEditing: Bool = false

    func beginEditing() {
        precondition(isEditing == false)
        isEditing = true
    }

    func endEditing() {
        precondition(isEditing == true)
        isEditing = false
    }

    func skipBackwards(_ n: Int) {
        preconditionFailure()
    }

    func deleteBackwards(_ n: Int) {
        preconditionFailure()
    }

    func insertText(_ text: TextNode) {
        preconditionFailure()
    }

    func insertNewline() {
        preconditionFailure()
    }

    func insertFragment(_ fragment: any LayoutFragment) {
        preconditionFailure()
    }
}
