// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation
import SwiftRohan

final class DocViewController: NSViewController {
  private var documentView: DocumentView!
  private var completionProvider: CompletionProvider!

  required init?(coder: NSCoder) {
    super.init(coder: coder)

  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpTextView()
  }

  func setUpTextView() {
    // set up scroll view
    let scrollView = DocumentView.initScrollable(frame: view.frame)
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    // set up document view
    documentView = scrollView.documentView as? DocumentView

    // set up content
    documentView.content = DocumentContent(RootNode(createSampleContent()))
    documentView.needsLayout = true

    // set up completion provider
    self.completionProvider = CompletionProvider()
    self.completionProvider.addItems(DefaultCommands.allCases)
    documentView.completionProvider = self.completionProvider
  }

  private func createDebugContent() -> [Node] {
    [
      ParagraphNode([
        TextNode("The quick brown \u{2028}")
      ]),
      ParagraphNode([
        TextNode("The quick brown ")
      ]),
      ParagraphNode([]),
      ParagraphNode([
        TextNode("The quick brown ")
      ]),
    ]
  }

  private func createSampleContent() -> [Node] {
    [
      ParagraphNode([]),
      HeadingNode(level: 1, [TextNode("The quick brown fox jumps "), UnknownNode()]),
      ParagraphNode([
        EmphasisNode([TextNode("the quick brown fox ")]),
        TextNode("jumps "),
        EmphasisNode([TextNode("over the lazy dog.")]),
      ]),
      // paragraph: test apply node
      ParagraphNode([
        TextNode("Newton's second law of motion: "),
        EquationNode(
          isBlock: false,
          nucleus: [ApplyNode(CompiledSamples.newtonsLaw, [])!, TextNode(".")]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          CompiledSamples.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ]),
      // paragraph: test nested apply node
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
          ])!,
      ]),
      HeadingNode(
        level: 1,
        [
          EquationNode(
            isBlock: false,
            nucleus: [
              TextNode("m+"),
              ApplyNode(
                CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
              TextNode("+n"),
            ])
        ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nucleus: [
            ApplyNode(
              CompiledSamples.bifun,
              [
                [ApplyNode(CompiledSamples.bifun, [[TextNode("n+1")]])!]
              ])!
          ])
      ]),
      ParagraphNode([
        TextNode("😀 The equation is "),
        EquationNode(
          isBlock: true,
          nucleus: [
            TextNode("f(n)+1+⋯+n+"),
            FractionNode(
              numerator: [TextNode("g(n+1)")], denominator: [TextNode("h(n+2)")]),
            TextNode("+"),
            FractionNode(numerator: [], denominator: [TextNode("k+1")]),
            TextNode("-"),
            FractionNode(
              numerator: [
                FractionNode(
                  numerator: [TextNode("a+b+c")], denominator: [TextNode("m+n")])
              ],
              denominator: [TextNode("x+y+z")]
            ),
            TextNode("=0,"),
          ]),
        TextNode(" where "),
        EquationNode(isBlock: false, nucleus: [TextNode("n")]),
        TextNode(" is a natural number."),
      ]),
      ParagraphNode([
        TextNode("The quick brown fox "),
        EmphasisNode([
          TextNode("jumps over the lazy dog.")
        ]),
      ]),
      HeadingNode(level: 1, [TextNode("Book I ")]),
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
    ]
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
