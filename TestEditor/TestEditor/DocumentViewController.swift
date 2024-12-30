// Copyright 2024 Lie Yan

import Cocoa
import Foundation

final class DocumentViewController: NSViewController {
    private var textContentStorage: NSTextContentStorage!
    private var textLayoutManager: NSTextLayoutManager!

    private var documentView: DocumentView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // set up TextKit managers
        // NOTE: use placeholder to avoid dangling references
        self.textContentStorage = NSTextContentStorage()
        self.textLayoutManager = NSTextLayoutManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set up views
        documentView = DocumentView(frame: view.frame)
        view.addSubview(documentView)
        NSLayoutConstraint.activate([
            documentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            documentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            documentView.topAnchor.constraint(equalTo: view.topAnchor),
            documentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // set up TextKit managers
        textContentStorage = (documentView.textContentManager as! NSTextContentStorage)
        textLayoutManager = documentView.textLayoutManager

        // set up content
        if textContentStorage.textStorage!.length == 0 {
            let fontName = "Latin Modern Roman"
            let fontSize = 18.0

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            paragraphStyle.alignment = NSTextAlignment.justified
            paragraphStyle.firstLineHeadIndent = fontSize * 1.5
            paragraphStyle.hyphenationFactor = 0.7

            let attributedString = NSAttributedString(
                string: """
                The tribunes of Rome, Marullus and Flavius, break up a \
                gathering of citizens who want to celebrate Julius Caesar's \
                triumphant return from war. The victory is marked by public \
                games in which Caesar's protégé, Mark Antony, takes part. \
                On his way to the arena, Caesar is stopped by a stranger who \
                warns him that he should 'Beware the Ides [15th] of March.'

                Fellow senators, Caius Cassius and Marcus Brutus, are \
                suspicious of Caesar's reactions to the power he holds in the \
                Republic. They fear he will accept offers to become Emperor. \
                He has been gaining a lot of power recently and people treat \
                him like a god. Cassius, a successful general himself, is \
                jealous of Caesar. Brutus has a more balanced view of the \
                political position. The conspirator Casca enters and tells \
                Brutus of a ceremony held by the plebeians. They offered \
                Caesar a crown three times, and he refused it every time. But \
                the conspirators are still wary of his aspirations. 
                """,
                attributes: [
                    .font: NSFont(name: fontName, size: fontSize)!,
                    .foregroundColor: NSColor.blue,
                    .paragraphStyle: paragraphStyle,
                ]
            )
            textContentStorage.textStorage!.insert(attributedString, at: 0)
        }
    }
}
