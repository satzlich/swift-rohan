// Copyright 2024-2025 Lie Yan

import Foundation

struct ContainerProperty: Equatable, Hashable {
  let nodeType: NodeType
  let parentType: NodeType?
  let containerMode: ContainerMode
  let containerType: ContainerType
  let containerTag: ContainerTag?
}

extension ContainerProperty {
  /// Returns a list of all container properties for testing purposes.
  static var allCasesForTesting: Array<ContainerProperty> {
    var result: Array<ContainerProperty> = []
    for nodeType in NodeType.allCases {
      for parentType in [NodeType.heading, .itemList, .paragraph, .parList] {
        for containerMode in ContainerMode.allCases {
          for containerType in ContainerType.allCases {
            let container = ContainerProperty(
              nodeType: nodeType,
              parentType: parentType,
              containerMode: containerMode,
              containerType: containerType,
              containerTag: nodeType.containerTag)
            result.append(container)
          }
        }
      }
    }
    return result
  }
}
