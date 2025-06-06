// Copyright 2024-2025 Lie Yan

protocol GenMathNode: Node {
  var layoutFragment: (any MathLayoutFragment)? { get }
}

extension MathNode: GenMathNode { }

extension ArrayNode: GenMathNode { }
  
