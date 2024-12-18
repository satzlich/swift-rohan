// Copyright 2024 Lie Yan

import Foundation

/*

 # Style Model

 - Node property
     - intrinsic vs. extrinsic
     - property name
     - property key
     - property value
     - property value type

 - Selector
     - node type
     - intrinsic property matcher

 - Style sheet
     - selector -> extrinsic properties
 */

typealias PropertyDict = [PropertyKey: PropertyValue]

/**
 A style sheet

 Essentially a dictioary: `selector -> extrinsic properties`

 */
final class StyleSheet {
    let dict: Dictionary<Selector, PropertyDict>

    init(dict: Dictionary<Selector, PropertyDict>) {
        self.dict = dict
    }

    func getPropertyDict(_ selector: Selector) -> PropertyDict? {
        nil
    }
}
