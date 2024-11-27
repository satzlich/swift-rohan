// Copyright 2024 Lie Yan

import Foundation

struct Selector {
    let nodeType: NodeType
    let matches: (name: PropertyName, value: PropertyValue)?
}

typealias PropertyDict = [PropertyKey: PropertyValue]

final class StyleSheet {
    func getValue(_ selector: Selector) -> PropertyDict? {
        nil
    }
}
