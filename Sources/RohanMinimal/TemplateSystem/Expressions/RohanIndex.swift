// Copyright 2024-2025 Lie Yan

public enum RohanIndex: Equatable, Hashable {
    case arrayIndex(ArrayIndex)
    case mathIndex(MathIndex)
    case gridIndex(GridIndex)

    public static func arrayIndex(_ index: Int) -> RohanIndex {
        .arrayIndex(ArrayIndex(index))
    }

    public static func gridIndex(row: Int, column: Int) -> RohanIndex {
        .gridIndex(GridIndex(row, column))
    }

    public struct ArrayIndex: Hashable, Comparable {
        public let index: Int

        internal init(_ index: Int) {
            precondition(index >= 0)
            self.index = index
        }

        public static func < (lhs: ArrayIndex, rhs: ArrayIndex) -> Bool {
            lhs.index < rhs.index
        }
    }

    public enum MathIndex: Int, Comparable {
        case nucleus = 0
        case subScript = 1
        case superScript = 2
        // fraction
        case numerator = 3
        case denominator = 4
        // radical
        case index = 5
        case radicand = 6

        public static func < (lhs: MathIndex, rhs: MathIndex) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public struct GridIndex: Hashable, Comparable {
        public let row: Int
        public let column: Int

        internal init(_ row: Int, _ column: Int) {
            precondition(GridIndex.validate(row: row))
            precondition(GridIndex.validate(column: column))
            self.row = row
            self.column = column
        }

        public static func < (lhs: GridIndex, rhs: GridIndex) -> Bool {
            (lhs.row, lhs.column) < (rhs.row, rhs.column)
        }

        /*
          We follow the practice of Microsoft Word.
          Column count must be between 1 and 63.
          Row count must be between 1 and 32767.
         */

        internal static func validate(row: Int) -> Bool {
            0 ..< 32767 ~= row
        }

        internal static func validate(column: Int) -> Bool {
            0 ..< 63 ~= column
        }
    }
}
