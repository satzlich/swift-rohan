// Copyright 2024-2025 Lie Yan

import Foundation

enum TestUtils {
    static func filePath(
        for functionName: String,
        extension: String
    ) -> String? {
        precondition(functionName.hasSuffix("()"))
        precondition(`extension`.first == ".")

        // get output directory from environment
        guard let baseDir = ProcessInfo().environment["RH_OUTPUT_DIR"] else {
            return nil
        }

        let baseName = functionName.dropLast(2)
        return "\(baseDir)/\(baseName)\(`extension`)"
    }
}
