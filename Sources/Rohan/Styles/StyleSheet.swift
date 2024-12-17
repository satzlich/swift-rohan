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
        - intrinsic properties are local to and part of a node instance
        - extrinsic properties are propagated around and influence other nodes
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
    let propertyMatcher: PropertyMatcher?
}

struct PropertyMatcher {
    let name: PropertyName
    let value: PropertyValue
}

typealias PropertyDict = [PropertyKey: PropertyValue]

final class StyleSheet {
    /**
     Returns extrinsic properties to export for the given selector.
     */
    func getPropertyDict(_ selector: Selector) -> PropertyDict? {
        nil
    }
}
