// Copyright 2024-2025 Lie Yan

import Foundation

enum AppDemo {
    func insertAndUndo(_ text: TextNode) {
        let contentStorage: ContentStorage = someValue()
        let location: RohanTextLocation = someValue()

        // insert
        contentStorage.replaceContents(in: RhTextRange(location: location), with: [text])
//
//        // undo
//        let undo: () -> Void = {
//            guard let end = contentStorage.location(location, offsetBy: text.length),
//                  let deleteRange = RhTextRange(location: location, end: end)
//            else { fatalError() }
//            return {
//                contentStorage.replaceContents(in: deleteRange, with: nil)
//            }
//        }()

        // perform undo
//        undo()
    }

    func deleteAndUndo() {
        let contentStorage: ContentStorage = someValue()
        let textRange: RhTextRange = someValue()

        // undo
        let undo: () -> Void = {
            // save deleted nodes
            var deletedContent: [Node] = []
            _ = contentStorage.enumerateSubnodes(in: textRange) { subnode, subnodeRange in
                guard let subnode else { return true }
                deletedContent.append(subnode)
                return true // continue
            }
            // construct insert range
            let insertRange = RhTextRange(location: textRange.location)

            return {
                contentStorage.replaceContents(in: insertRange, with: deletedContent)
            }
        }()

        // delete
        contentStorage.replaceContents(in: textRange, with: nil)

        // perform undo
        undo()
    }

    func reconcileSelection() {
        let layoutManager: LayoutManager = someValue()
        let viewFrame: CGRect = someValue()

        // get text selection
        let textSelections = layoutManager.textSelections
        guard textSelections.count == 1 else { fatalError() }
        let textSelection = textSelections[0]

        // produce highlight frames
        var highlightFrames: [CGRect] = []
        for textRange in textSelection.textRanges {
            layoutManager.enumerateTextSegments(in: textRange) {
                (textSegment, textSegmentFrame, _) in

                let textSegmentFrame = textSegmentFrame.intersection(viewFrame)
                guard textSegmentFrame.isEmpty else { return true }
                highlightFrames.append(textSegmentFrame)
                return true // continue
            }
        }
    }

    func reconcileInsertionPoint() {
        let layoutManager: LayoutManager = someValue()
        let location: RohanTextLocation = someValue()

        // get insertion point
        let textRange = RhTextRange(location: location)
        var insertionPointFrame: CGRect = .zero
        layoutManager.enumerateTextSegments(in: textRange) {
            (textSegment, textSegmentFrame, _) in
            guard textSegment != nil else { return true }
            insertionPointFrame = textSegmentFrame
            return false
        }
        useValue(insertionPointFrame)
    }
}
