// Copyright 2024-2025 Lie Yan

extension NodeUtils {
  /**
   Insert nodes at the specified location in the tree.
   - Returns: The new insertion point if the insertion is successful; otherwise, nil.
   */
  static func insertNodes(
    _ nodes: [Node], at location: TextLocation, _ tree: RootNode
  ) -> SatzResult<InsertionPoint> {

    return .failure(SatzError(.GenericInternalError))
  }
}
