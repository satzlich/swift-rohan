// Copyright 2024 Lie Yan

import Algorithms

struct Bibliography {
    typealias Entry = BibTeX.Entry

    private let entries: [CiteKey: Entry]

    init?(_ entries: [Entry]) {
        guard Bibliography.validateEntries(entries) else {
            return nil
        }

        self.entries = entries.reduce(into: [:]) { result, entry in
            result[entry.key] = entry
        }
    }

    static func validateEntries(_ entries: [Entry]) -> Bool {
        // Check whether all keys are unique
        let keys = Set(entries.map { $0.key })
        return keys.count == entries.count
    }
}
