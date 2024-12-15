// Copyright 2024 Lie Yan

import Foundation

/**
 Namespace for BibTeX

 - SeeAlso: [https://www.bibtex.com](https://www.bibtex.com)
 */
enum BibTeX {
    // MARK: - EntryType

    public enum EntryType: String, Equatable, Hashable, CaseIterable {
        case article
        case book
        case booklet
        case conference
        case inbook
        case incollection
        case inproceedings
        case manual
        case mastersthesis
        case misc
        case phdthesis
        case proceedings
        case techreport
        case unpublished
    }

    // MARK: - Citekey

    /**

     - Note: Citekey is case-insensitive.
     */
    public struct Citekey: Equatable, Hashable {
        public let text: String
        private let lowercased: String

        public init(_ text: String) {
            precondition(Citekey.validate(text: text))
            self.text = text
            self.lowercased = text.lowercased()
        }

        /**
         Validates the text for citekey.

         The citekey can be any combination of alphanumeric characters including the
         characters "-", "_", and ":".
         */
        static func validate(text: String) -> Bool {
            try! #/[a-zA-Z0-9\-_:]+/#.wholeMatch(in: text) != nil &&
                #/[a-zA-Z0-9]/#.firstMatch(in: text) != nil
        }

        /**
         Checks equality ignoring case
         */
        public static func == (lhs: Citekey, rhs: Citekey) -> Bool {
            lhs.lowercased == rhs.lowercased
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(lowercased)
        }
    }

    // MARK: - FieldType

    public enum FieldType: String, Equatable, Hashable, CaseIterable {
        // Standard field types
        case address
        case annote
        case author
        case booktitle
        case chapter
        case edition
        case editor
        case howpublished
        case institution
        case journal
        case month
        case note
        case number
        case organization
        case pages
        case publisher
        case school
        case series
        case title
        case type
        case volume
        case year

        // Non-standard field types
        case doi
        case issn
        case isbn
        case url
    }

    // MARK: - Entry

    public struct Entry {
        public let type: EntryType
        public let key: Citekey
        public let fields: [FieldType: String]

        init(type: EntryType, key: Citekey, fields: [FieldType: String]) {
            self.type = type
            self.key = key
            self.fields = fields
        }
    }
}
