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

    public struct Citekey: Equatable, Hashable {
        public let text: String

        public init?(_ text: String) {
            guard Citekey.validateText(text) else {
                return nil
            }
            self.text = text
        }

        static func validateText(_ text: String) -> Bool {
            func isAlphanumeric(_ char: Character) -> Bool {
                char.isASCII && (char.isLetter || char.isNumber)
            }

            func isValidSpecialChar(_ char: Character) -> Bool {
                char == "-" || char == "_" || char == ":"
            }

            return !text.isEmpty &&
                text.contains(where: isAlphanumeric) &&
                text.allSatisfy { isAlphanumeric($0) || isValidSpecialChar($0) }
        }

        /**
         Checks equality ignoring case
         */
        public static func == (lhs: Citekey, rhs: Citekey) -> Bool {
            lhs.text.lowercased() == rhs.text.lowercased()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text.lowercased())
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
        public let key: Citekey
        public let type: EntryType
        public let fields: [FieldType: String]

        init(key: Citekey, type: EntryType, fields: [FieldType: String]) {
            self.key = key
            self.type = type
            self.fields = fields
        }
    }
}
