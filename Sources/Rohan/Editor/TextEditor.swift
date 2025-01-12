// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

class TextEditor: EditorProtocol {
    public let styleSheet: StyleSheet
    var state: EditorState

    var layoutBounds: CGRect { textLayoutManager.usageBoundsForTextContainer }

    func draw(_ dirtyRect: CGRect) {
        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

        let startLocation = textContentManager.documentRange.location
        textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragement in
            fragement.draw(at: fragement.layoutFragmentFrame.origin, in: cgContext)
            return true // continue
        }
    }

    // TextKit

    private var _textContentStorage: NSTextContentStorage
    private(set) var textLayoutManager: NSTextLayoutManager
    var textContentManager: NSTextContentManager { _textContentStorage }

    // helper variables

    weak var parent: TextEditor?
    private(set) var inEditTransaction: Bool = false

    init(state: EditorState, styleSheet: StyleSheet) {
        self.state = state
        self.styleSheet = styleSheet
        self._textContentStorage = RhTextContentStorage()
        self.textLayoutManager = NSTextLayoutManager()

        // set up
        textLayoutManager.textContainer = NSTextContainer()
        textContentManager.addTextLayoutManager(textLayoutManager)
        textContentManager.primaryTextLayoutManager = textLayoutManager
    }

    public func reconcile() {
        let visitor = ReconcileVisitor(textLayoutManager: textLayoutManager,
                                       textContentStorage: _textContentStorage,
                                       styleSheet: styleSheet)

        textContentManager.performEditingTransaction {
            _ = state.rootNode.accept(visitor, 0)
        }

        textLayoutManager.ensureLayout(for: textContentManager.documentRange)
    }

    private final class ReconcileVisitor: NodeVisitor<Int, Int>
    // R: consumed length, C: start location
    {
        let textLayoutManager: NSTextLayoutManager
        let textContentStorage: NSTextContentStorage
        let styleSheet: StyleSheet

        init(textLayoutManager: NSTextLayoutManager,
             textContentStorage: NSTextContentStorage,
             styleSheet: StyleSheet)
        {
            self.textLayoutManager = textLayoutManager
            self.textContentStorage = textContentStorage
            self.styleSheet = styleSheet
        }

        override func visitNode(_ node: Node, _ context: Int) -> Int {
            var current = context

            if let element = node as? ElementNode {
                for i in 0 ..< element.childCount() {
                    let length = element.getChild(i).accept(self, current)
                    current += length
                }

                if element.postamble.isEmpty == false {
                    let properties = element.resolve(with: styleSheet) as TextProperty
                    _insertText(current, element.postamble, properties.attributes())
                    current += element.postamble.count
                }

                return current - context
            }
            preconditionFailure()
        }

        override func visit(text: TextNode, _ context: Int) -> Int {
            let string = text.getString()
            let property = text.resolve(with: styleSheet) as TextProperty
            _insertText(context, string, property.attributes())
            return string.count
        }

        override func visit(equation: EquationNode, _ context: Int) -> Int {
            let string = "□"
            let property = equation.resolve(with: styleSheet) as TextProperty
            _insertText(context, string, property.attributes())
            return string.count
        }

        internal func _insertText(
            _ location: Int,
            _ text: String,
            _ attributes: [NSAttributedString.Key: Any]
        ) {
            // location
            let textLocation = textContentStorage.textLocation(for: location)!
            let textRange = NSTextRange(location: textLocation)
            // content
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textParagraph = NSTextParagraph(attributedString: attributedString)
            // replace
            textContentStorage.replaceContents(in: textRange, with: [textParagraph])
        }
    }
}
