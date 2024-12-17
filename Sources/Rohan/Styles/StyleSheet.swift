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
    let type: NodeType

    /**
     Matches an intrinsic property.
     */
    let matcher: PropertyMatcher?

    init(_ type: NodeType, _ matcher: PropertyMatcher? = nil) {
        self.type = type
        self.matcher = matcher
    }
}

struct PropertyMatcher {
    let name: PropertyName
    let value: PropertyValue

    init(_ name: PropertyName, _ value: PropertyValue) {
        self.name = name
        self.value = value
    }
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
