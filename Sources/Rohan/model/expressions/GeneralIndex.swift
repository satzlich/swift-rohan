// Copyright 2024 Lie Yan

/**
 General index
 */
enum GeneralIndex: Equatable, Hashable, Codable {
    case arrayIndex(ArrayIndex)
    case gridIndex(GridIndex)
    case mathIndex(MathIndex)

    static func arrayIndex(_ intValue: Int) -> GeneralIndex {
        .arrayIndex(ArrayIndex(intValue))
    }

    static func gridIndex(row: Int, column: Int) -> GeneralIndex {
        .gridIndex(GridIndex(row: row, column: column))
    }

    struct ArrayIndex: Equatable, Hashable, Codable, ExpressibleByIntegerLiteral {
        typealias IntegerLiteralType = Int

        let intValue: Int

        init(_ intValue: Int) {
            precondition(Self.validate(intValue: intValue))
            self.intValue = intValue
        }

        init(integerLiteral value: IntegerLiteralType) {
            self.init(value)
        }

        static func validate(intValue: Int) -> Bool {
            intValue >= 0
        }
    }

    struct GridIndex: Equatable, Hashable, Codable {
        let row: Int
        let column: Int

        init(row: Int, column: Int) {
            precondition(Self.validate(row: row) && Self.validate(column: column))

            self.row = row
            self.column = column
        }

        /*
          We follow the practice of Microsoft Word.
          Column count must be between 1 and 63.
          Row count must be between 1 and 32767.
         */

        static func validate(row: Int) -> Bool {
            0 ..< 32767 ~= row
        }

        static func validate(column: Int) -> Bool {
            0 ..< 63 ~= column
        }
    }

    enum MathIndex: Equatable, Hashable, Codable {
        case subScript
        case superScript
        case numerator
        case denominator
        case radicand
        case index
    }
}
