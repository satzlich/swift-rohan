// Copyright 2024 Lie Yan

import Cocoa
import Foundation

final class DocumentViewController: NSViewController {
    private var textContentStorage: NSTextContentStorage!
    private var textLayoutManager: NSTextLayoutManager!

    @IBOutlet private var documentView: DocumentView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // set up content manager and layout manager
        // NOTE: use placeholder to avoid dangling references
        self.textContentStorage = NSTextContentStorage()
        self.textLayoutManager = NSTextLayoutManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up content manager and layout manager
        textContentStorage = (documentView.textContentManager as! NSTextContentStorage)
        textLayoutManager = documentView.textLayoutManager

        // set up content
        if textContentStorage.textStorage!.length == 0 {
            let attributedString = NSAttributedString(
                string: """
                The quick brown fox jumps over the lazy dog.
                The turtle runs past Achilles.
                """,
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12),
                    .foregroundColor: NSColor.black,
                ]
            )
            textContentStorage.textStorage!.insert(attributedString, at: 0)
        }

        documentView.needsLayout = true
        documentView.needsDisplay = true
    }
}
