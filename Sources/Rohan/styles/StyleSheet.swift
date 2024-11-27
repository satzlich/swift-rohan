// Copyright 2024 Lie Yan

import Foundation

/*

 # Style Model

 - StyleSheet
     - selector -> (extrinsic) properties to export

 - Selector
     - target node type
     - optional target (intrinsic) property name-value pair

 - Node property
     - intrinsic vs. extrinsic contrast
        - intrinsic properties are local to and part of the node
            - intrinsic properties belong to a node instance
        - extrinsic properties are propagated around and influence other nodes
            - extrinsic properties belong to a node type
     - property name
     - property key
     - property value
     - property value type

 */

struct Selector {
    let nodeType: NodeType
    /**
     Matches an intrinsic property.
     */
    let matches: (name: PropertyName, value: PropertyValue)?
}

typealias PropertyDict = [PropertyKey: PropertyValue]

final class StyleSheet {
    /**
     Returns extrinsic properties to export for the given selector.
     */
    func getProperties(_ selector: Selector) -> PropertyDict? {
        nil
    }
}
