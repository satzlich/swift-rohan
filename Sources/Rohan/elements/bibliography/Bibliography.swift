// Copyright 2024 Lie Yan

import Algorithms

struct Bibliography {
    struct Entry {
        let key: CitationKey

        init(_ key: CitationKey) {
            self.key = key
        }
    }

    private let entries: [CitationKey: Entry]

    init?(_ entries: [Entry]) {
        let keys = Set(entries.map { $0.key })
        guard keys.count == entries.count else {
            return nil
        }

        self.entries = entries.reduce(into: [:]) { result, entry in
            result[entry.key] = entry
        }
    }
}
