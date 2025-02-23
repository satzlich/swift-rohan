// Copyright 2024-2025 Lie Yan

import Cocoa
import Foundation
import Rohan

final class DocViewController: NSViewController {
  private var documentManager: DocumentManager!
  private var textView: TextView!

  required init?(coder: NSCoder) {
    // NOTE: use placeholder to avoid dangling references
    self.documentManager = DocumentManager(.defaultValue(18))

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
    documentManager = textView.documentManager

    // set up content
    if documentManager.documentRange.isEmpty {
      let content = [
        ParagraphNode([
          TextNode("The quick brown fox jumps over the lazy dog.")
        ]),
        // #1 paragraph: test apply node
        ParagraphNode([
          TextNode("Newton's second law of motion: "),
          EquationNode(
            isBlock: false,
            [
              ApplyNode(TemplateSample.newtonsLaw, [])!,
              TextNode("."),
            ]),
          TextNode(" Here is another sample: "),
          ApplyNode(
            TemplateSample.philipFox,
            [
              [TextNode("Philip")],
              [TextNode("Fox")],
            ])!,
        ]),
        // #2 paragraph: test nested apply node
        ParagraphNode([
          TextNode("Sample of nested apply nodes: "),
          ApplyNode(
            TemplateSample.doubleText,
            [
              [ApplyNode(TemplateSample.doubleText, [[TextNode("fox")]])!]
            ])!,
        ]),
        // #3
        HeadingNode(
          level: 1,
          [
            EquationNode(
              isBlock: false,
              [
                TextNode("m+"),
                ApplyNode(
                  TemplateSample.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
                TextNode("+n"),
              ])
          ]),

        //        ParagraphNode([
        //          TextNode("😀 The equation is "),
        //          EquationNode(
        //            isBlock: true,
        //            [
        //              TextNode("f(n)+"),
        //              FractionNode(
        //                [TextNode("g(n+1)")],
        //                [TextNode("h(n+2)")]),
        //              TextNode("+"),
        //              FractionNode(
        //                [],
        //                [TextNode("k+1")]
        //              ),
        //              TextNode("-"),
        //              FractionNode(
        //                [
        //                  FractionNode(
        //                    [TextNode("a+b+c")],
        //                    [TextNode("m+n")])
        //                ],
        //                [TextNode("x+y+z")]
        //              ),
        //              TextNode("=0,"),
        //            ]),
        //          TextNode(" where "),
        //          EquationNode(
        //            isBlock: false,
        //            [TextNode("n")]
        //          ),
        //          TextNode(" is a natural number."),
        //        ]),
        //        ParagraphNode([
        //          TextNode("The quick brown fox "),
        //          EmphasisNode([
        //            TextNode("jumps over the "),
        //            EmphasisNode([
        //              TextNode("lazy ")
        //            ]),
        //            TextNode("dog."),
        //          ]),
        //        ]),
        //        HeadingNode(level: 1, [TextNode("Book I ")]),
        //        ParagraphNode([
        //          TextNode(
        //            """
        //            Sing, O goddess, the anger of Achilles son of Peleus, that brought \
        //            countless ills upon the Achaeans. Many a brave soul did it send hurrying \
        //            down to Hades, and many a hero did it yield a prey to dogs and vultures, \
        //            for so were the counsels of Jove fulfilled from the day on which the \
        //            son of Atreus, king of men, and great Achilles, first fell out with \
        //            one another.
        //            """)
        //        ]),
        //        ParagraphNode([
        //          TextNode(
        //            """
        //            And which of the gods was it that set them on to quarrel? It was the \
        //            son of Jove and Leto; for he was angry with the king and sent a pestilence \
        //            upon the host to plague the people, because the son of Atreus had \
        //            dishonoured Chryses his priest. Now Chryses had come to the ships \
        //            of the Achaeans to free his daughter, and had brought with him a great \
        //            ransom: moreover he bore in his hand the sceptre of Apollo wreathed \
        //            with a suppliant's wreath and he besought the Achaeans, but most of \
        //            all the two sons of Atreus, who were their chiefs.
        //            """
        //          )
        //        ]),
        //        ParagraphNode([
        //          TextNode(
        //            """
        //            "Sons of Atreus," he cried, "and all other Achaeans, may the gods \
        //            who dwell in Olympus grant you to sack the city of Priam, and to reach \
        //            your homes in safety; but free my daughter, and accept a ransom for \
        //            her, in reverence to Apollo, son of Jove."
        //            """
        //          )
        //        ]),
      ]

      do {
        try documentManager.performEditingTransaction {
          try documentManager.replaceContents(in: documentManager.documentRange, with: content)
        }
      }
      catch let error {
        print("\(error)")
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
