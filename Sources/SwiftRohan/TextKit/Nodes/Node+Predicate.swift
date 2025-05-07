// Copyright 2024-2025 Lie Yan

// Check node category

@inline(__always) func isApplyNode(_ node: Node) -> Bool { node is ApplyNode }
@inline(__always) func isArgumentNode(_ node: Node) -> Bool { node is ArgumentNode }
@inline(__always) func isElementNode(_ node: Node) -> Bool { node is ElementNode }
@inline(__always) func isMathNode(_ node: Node) -> Bool { node is MathNode }
@inline(__always) func isMatrixNode(_ node: Node) -> Bool { node is _MatrixNode }
@inline(__always) func isSimpleNode(_ node: Node) -> Bool { node is _SimpleNode }
@inline(__always) func isTextNode(_ node: Node) -> Bool { node is TextNode }

// Check specific node type

@inline(__always) func isRootNode(_ node: Node) -> Bool { node is RootNode }
@inline(__always) func isParagraphNode(_ node: Node) -> Bool { node is ParagraphNode }

@inline(__always) func isAttachNode(_ node: Node) -> Bool { node is AttachNode }
@inline(__always) func isEquationNode(_ node: Node) -> Bool { node is EquationNode }
@inline(__always) func isRadicalNode(_ node: Node) -> Bool { node is RadicalNode }

@inline(__always) func isLinebreakNode(_ node: Node) -> Bool { node is LinebreakNode }
