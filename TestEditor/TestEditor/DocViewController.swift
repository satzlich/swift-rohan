// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation
import Rohan

final class DocViewController: NSViewController {
    private var contentStorage: ContentStorage!
    private var layoutManager: LayoutManager!
    private var textView: TextView!

    required init?(coder: NSCoder) {
        // NOTE: use placeholder to avoid dangling references
        self.contentStorage = ContentStorage()
        self.layoutManager = LayoutManager()

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTextView()
    }

    func setUpTextView() {
        // set up scroll view
        let scrollView = TextView.initScrollable(frame: view.frame)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // set up document view
        textView = scrollView.documentView as? TextView

        // set up managers
        contentStorage = textView.contentStorage
        layoutManager = textView.layoutManager

        // set up content
        if contentStorage.documentRange.isEmpty {
            let content = [
                HeadingNode(level: 1, [
                    TextNode("Alpha "),
                    EmphasisNode([
                        TextNode("Beta Charlie"),
                    ]),
                ]),
                ParagraphNode([
                    TextNode("The quick brown fox "),
                    EmphasisNode([
                        TextNode("jumps over the "),
                        EmphasisNode([
                            TextNode("lazy "),
                        ]),
                        TextNode("dog."),
                    ]),
                ]),
                ParagraphNode([
                    TextNode("😀 The equation is "),
                    EquationNode(
                        isBlock: true,
                        nucleus: ContentNode([TextNode("f(n+2)=f(n+1)+f(n),")])
                    ),
                    TextNode("where "),
                    EquationNode(
                        isBlock: false,
                        nucleus: ContentNode([TextNode("n")])
                    ),
                    TextNode(" is a natural number."),
                ]),
                ParagraphNode([
                    TextNode("May the force be with you!"),
                ]),
            ]
            contentStorage.performEditingTransaction {
                contentStorage.replaceContents(in: contentStorage.documentRange,
                                               with: content)
            }
        }
    }
}

// import RhTextView
// final class DocViewController: NSViewController {
//    private var textContentStorage: NSTextContentStorage!
//    private var textLayoutManager: NSTextLayoutManager!
//
//    private var textView: RhTextView!
//
//    required init?(coder: NSCoder) {
//        // NOTE: use placeholder to avoid dangling references
//        self.textContentStorage = NSTextContentStorage()
//        self.textLayoutManager = NSTextLayoutManager()
//
//        super.init(coder: coder)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setUpTextView()
//    }
//
//    func setUpTextView() {
//        // set up views
//        let scrollView = RhTextView.initScrollable(frame: view.frame)
//        view.addSubview(scrollView)
//        NSLayoutConstraint.activate([
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//
//        // set up document view
//        textView = scrollView.documentView as? RhTextView
//
//        // set up TextKit managers
//        textContentStorage = (textView.textContentManager as! NSTextContentStorage)
//        textLayoutManager = textView.textLayoutManager
//
//        // set up content
//        if textContentStorage.textStorage!.length == 0 {
//            let fontName = "Palatino"
//            let fontSize = 18.0
//
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.lineHeightMultiple = 1.2
//            paragraphStyle.alignment = NSTextAlignment.justified
//            paragraphStyle.hyphenationFactor = 0.7
//
//            let content = try! String(contentsOf: Bundle.main.url(forResource: "iliad.mb",
//                                                                  withExtension: "txt")!,
//                                      encoding: .utf8)
//
//            let attributedString = NSAttributedString(
//                string: content,
//                attributes: [
//                    .font: NSFont(name: fontName, size: fontSize)!,
//                    .foregroundColor: NSColor.textColor,
//                    .paragraphStyle: paragraphStyle,
//                ]
//            )
//            textContentStorage.textStorage!.insert(attributedString, at: 0)
//        }
//    }
// }
