// Copyright 2024 Lie Yan

import Foundation

extension Result {
    func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    func success() -> Success? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
}
