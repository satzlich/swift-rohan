// Copyright 2024 Lie Yan

typealias CiteKey = BibTeX.Citekey

struct Citation {
    public let key: CiteKey

    init(_ key: CiteKey) {
        self.key = key
    }
}
