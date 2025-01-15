// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

class Editor {
    // MARK: - EditorProtocol

    var containerSize: CGSize { textLayoutManager.textContainer!.size }
    var usageBounds: CGRect { textLayoutManager.usageBoundsForTextContainer }

    func draw(_ dirtyRect: CGRect) {
        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

        let startLocation = textContentManager.documentRange.location
        textLayoutManager.enumerateTextLayoutFragments(from: startLocation) { fragement in
            fragement.draw(at: fragement.layoutFragmentFrame.origin, in: cgContext)
            return true // continue
        }
    }

    // States

    public let styleSheet: StyleSheet
    var state: EditorState
    var pendingState: EditorState?

    // TextKit

    private var _textContentStorage: NSTextContentStorage
    private var textLayoutManager: NSTextLayoutManager
    private var textContentManager: NSTextContentManager { _textContentStorage }

    // helper variables

    weak var parent: Editor?
    private(set) var inEditTransaction: Bool = false

    init(state: EditorState,
         styleSheet: StyleSheet,
         containerSize: CGSize)
    {
        self.state = state
        self.pendingState = nil
        self.styleSheet = styleSheet
        self._textContentStorage = NSTextContentStorage_fix()
        self.textLayoutManager = NSTextLayoutManager()

        // set up
        textLayoutManager.textContainer = NSTextContainer(size: containerSize)
        textContentManager.addTextLayoutManager(textLayoutManager)
        textContentManager.primaryTextLayoutManager = textLayoutManager
    }

    public func reconcile() {
        let visitor = ReconcileVisitor(textContentStorage: _textContentStorage,
                                       styleSheet: styleSheet)

        textContentManager.performEditingTransaction {
            _ = state.rootNode.accept(visitor, 0)
        }

        textLayoutManager.ensureLayout(for: textContentManager.documentRange)
    }

    private final class ReconcileVisitor: NodeVisitor<Int, Int>
    // R: consumed lengthAsNSString, C: start location
    {
        let textContentStorage: NSTextContentStorage
        let styleSheet: StyleSheet

        init(textContentStorage: NSTextContentStorage,
             styleSheet: StyleSheet)
        {
            self.textContentStorage = textContentStorage
            self.styleSheet = styleSheet
        }

        override func visitNode(_ node: Node, _ context: Int) -> Int {
            var current = context

            if let element = node as? ElementNode {
                for i in 0 ..< element.childCount() {
                    let nsLength = element.getChild(i).accept(self, current)
                    current += nsLength
                }

                let postamble = element.getPostamble()
                if postamble.isEmpty == false {
                    let properties = element.resolve(with: styleSheet) as TextProperty
                    _insertText(current, postamble, properties.attributes())
                    current += postamble.lengthAsNSString()
                }

                return current - context
            }
            preconditionFailure()
        }

        override func visit(text: TextNode, _ context: Int) -> Int {
            let string = text.getString()
            let property = text.resolve(with: styleSheet) as TextProperty
            _insertText(context, string, property.attributes())
            return string.lengthAsNSString()
        }

        override func visit(equation: EquationNode, _ context: Int) -> Int {
            let string = "□"
            let property = equation.resolve(with: styleSheet) as TextProperty
            _insertText(context, string, property.attributes())
            return string.lengthAsNSString()
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
