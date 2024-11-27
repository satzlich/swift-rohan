// Copyright 2024 Lie Yan

import Foundation

struct PropertyEntry {
    let key: PropertyName
    let value: Value
}

typealias PropertyDict = [PropertyKey: Value]

final class Theme {
    func getValue(_ nodeType: NodeType,
                  match property: PropertyEntry? = nil) -> PropertyDict?
    {
        nil
    }
}
