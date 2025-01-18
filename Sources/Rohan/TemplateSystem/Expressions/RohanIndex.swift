// Copyright 2024-2025 Lie Yan

public enum RohanIndex: Equatable, Hashable, CustomStringConvertible {
    case arrayIndex(ArrayIndex)
    case mathIndex(MathIndex)
    case gridIndex(GridIndex)

    public static func arrayIndex(_ index: Int) -> RohanIndex {
        .arrayIndex(ArrayIndex(index))
    }

    public static func gridIndex(row: Int, column: Int) -> RohanIndex {
        .gridIndex(GridIndex(row, column))
    }

    func arrayIndex() -> ArrayIndex? {
        switch self {
        case let .arrayIndex(index): return index
        default: return nil
        }
    }

    func mathIndex() -> MathIndex? {
        switch self {
        case let .mathIndex(index): return index
        default: return nil
        }
    }

    func gridIndex() -> GridIndex? {
        switch self {
        case let .gridIndex(index): return index
        default: return nil
        }
    }

    public var description: String {
        switch self {
        case let .arrayIndex(index): return "\(index)"
        case let .mathIndex(index): return "\(index)"
        case let .gridIndex(index): return "\(index)"
        }
    }

    public struct ArrayIndex: Hashable, Comparable, CustomStringConvertible {
        public let index: Int

        internal init(_ index: Int) {
            precondition(index >= 0)
            self.index = index
        }

        public static func < (lhs: ArrayIndex, rhs: ArrayIndex) -> Bool {
            lhs.index < rhs.index
        }

        public var description: String { "\(index)" }
    }

    public enum MathIndex: Int, Comparable, CustomStringConvertible {
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

        public var description: String {
            switch self {
            case .nucleus: return "nucleus"
            case .subScript: return "subscript"
            case .superScript: return "superscript"
            case .numerator: return "numerator"
            case .denominator: return "denominator"
            case .index: return "index"
            case .radicand: return "radicand"
            }
        }
    }

    public struct GridIndex: Hashable, Comparable, CustomStringConvertible {
        public let row: Int
        public let column: Int

        internal init(_ row: Int, _ column: Int) {
            precondition(GridIndex.validate(row: row))
            precondition(GridIndex.validate(column: column))
            self.row = row
            self.column = column
        }

        public var description: String {
            "(\(row), \(column))"
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

public typealias MathIndex = RohanIndex.MathIndex
