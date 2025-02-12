// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import RohanCommon
import Testing

struct TextKitRegressionTests {
    @Test
    static func regress_FB9925647() {
        let textStroage = NSTextContentStorage()
        let textStoragePatched = NSTextContentStoragePatched()

        insertAndReplace(textStoragePatched)
        insertAndReplace(textStroage, buggy: true)
    }

    static func insertAndReplace(_ textContentStorage: NSTextContentStorage,
                                 buggy: Bool = false)
    {
        // insert
        let string = "the quick brown fox"
        let textElement = NSTextParagraph(attributedString: NSAttributedString(string: string))
        textContentStorage.performEditingTransaction {
            let textRange = NSTextRange(location: textContentStorage.documentRange.location)
            textContentStorage.replaceContents(in: textRange, with: [textElement])
        }

        if buggy {
            #expect(textContentStorage.textStorage!.string == "")
        }
        else {
            #expect(textContentStorage.textStorage!.string == "the quick brown fox")
        }

        // delete
        let location = textContentStorage.documentRange.location
        let end = textContentStorage.location(location, offsetBy: 4)
        let textRange = NSTextRange(location: location, end: end)!

        textContentStorage.performEditingTransaction {
            textContentStorage.replaceContents(in: textRange, with: nil)
        }
        if buggy {
            #expect(textContentStorage.textStorage!.string == "")
        }
        else {
            #expect(textContentStorage.textStorage!.string == "quick brown fox")
        }
    }
}
