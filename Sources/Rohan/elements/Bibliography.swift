// Copyright 2024 Lie Yan

import Algorithms

struct Bibliography {
    private let entries: [CitationKey: BibliographyEntry]

    init?(_ entries: [BibliographyEntry]) {
        let keys = Set(entries.map { $0.key })
        guard keys.count == entries.count else {
            return nil
        }

        self.entries = entries.reduce(into: [:]) { $0[$1.key] = $1 }
    }
}
