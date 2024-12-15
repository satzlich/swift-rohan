// Copyright 2024 Lie Yan

import Algorithms

struct Bibliography {
    typealias Entry = BibTeX.Entry

    private let entries: [CiteKey: Entry]

    init(_ entries: [Entry]) {
        precondition(Bibliography.validate(entries: entries))

        self.entries = entries.reduce(into: [:]) { result, entry in
            result[entry.key] = entry
        }
    }

    static func validate(entries: [Entry]) -> Bool {
        // Check whether all keys are unique
        let keys = Set(entries.map { $0.key })
        return keys.count == entries.count
    }
}
