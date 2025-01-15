// Copyright 2024-2025 Lie Yan

import Foundation

enum TestUtils {
    static func filePath<S>(_ fileName: S, fileExtension: String) -> String?
    where S: StringProtocol {
        precondition(fileExtension.first == ".")

        // get output directory from environment
        guard let baseDir = ProcessInfo().environment["RH_OUTPUT_DIR"]
        else { return nil }

        return "\(baseDir)/\(fileName)\(fileExtension)"
    }
}
