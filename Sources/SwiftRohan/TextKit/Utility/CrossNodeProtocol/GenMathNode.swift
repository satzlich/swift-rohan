// Copyright 2024-2025 Lie Yan

protocol GenMathNode: Node {

}

extension MathNode: GenMathNode {}
extension ArrayNode: GenMathNode {}
