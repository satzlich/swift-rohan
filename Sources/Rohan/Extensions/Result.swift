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

    func isFailure() -> Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
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

    func failure() -> Failure? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}
