// Copyright 2024-2025 Lie Yan

typealias GeneralIndex = RohanIndex

enum RohanIndex: Equatable, Hashable {
    case arrayIndex(ArrayIndex)
    case mathIndex(MathIndex)
    case gridIndex(GridIndex)

    static func arrayIndex(_ index: Int) -> RohanIndex {
        .arrayIndex(ArrayIndex(index))
    }

    static func gridIndex(row: Int, column: Int) -> RohanIndex {
        .gridIndex(GridIndex(row, column))
    }

    struct ArrayIndex: Hashable, Comparable {
        let index: Int

        init(_ index: Int) {
            precondition(index >= 0)
            self.index = index
        }

        static func < (lhs: ArrayIndex, rhs: ArrayIndex) -> Bool {
            lhs.index < rhs.index
        }
    }

    enum MathIndex: Int, Comparable {
        case nucleus = 0
        case subScript = 1
        case superScript = 2
        // fraction
        case numerator = 3
        case denominator = 4
        // radical
        case index = 5
        case radicand = 6

        static func < (lhs: MathIndex, rhs: MathIndex) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    struct GridIndex: Hashable, Comparable {
        let row: Int
        let column: Int

        init(_ row: Int, _ column: Int) {
            precondition(GridIndex.validate(row: row))
            precondition(GridIndex.validate(column: column))
            self.row = row
            self.column = column
        }

        static func < (lhs: GridIndex, rhs: GridIndex) -> Bool {
            (lhs.row, lhs.column) < (rhs.row, rhs.column)
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
}
