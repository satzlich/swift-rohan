// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation
import RhTextView

final class DocViewController: NSViewController {
    private var textContentStorage: NSTextContentStorage!
    private var textLayoutManager: NSTextLayoutManager!

    private var textView: RhTextView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // set up TextKit managers
        // NOTE: use placeholder to avoid dangling references
        self.textContentStorage = NSTextContentStorage()
        self.textLayoutManager = NSTextLayoutManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        setUpTestView()
        setUpTextView()
    }

    func setUpTextView() {
        // set up views
        let scrollView = RhTextView.initScrollable(frame: view.frame)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // set up document view
        textView = scrollView.documentView as? RhTextView

        // set up TextKit managers
        textContentStorage = (textView.textContentManager as! NSTextContentStorage)
        textLayoutManager = textView.textLayoutManager

        // set up content
        if textContentStorage.textStorage!.length == 0 {
            let fontName = "Palatino"
            let fontSize = 18.0

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.2
            paragraphStyle.alignment = NSTextAlignment.justified
//            paragraphStyle.firstLineHeadIndent = fontSize * 1.5
            paragraphStyle.hyphenationFactor = 0.7

            let content = try! String(contentsOf: Bundle.main.url(forResource: "iliad.mb",
                                                                  withExtension: "txt")!,
                                      encoding: .utf8)

            let attributedString = NSAttributedString(
                string: content,
                attributes: [
                    .font: NSFont(name: fontName, size: fontSize)!,
                    .foregroundColor: NSColor.textColor,
                    .paragraphStyle: paragraphStyle,
                ]
            )
            textContentStorage.textStorage!.insert(attributedString, at: 0)
        }
    }
}
