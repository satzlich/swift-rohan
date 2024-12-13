// Copyright 2024 Lie Yan

import Foundation

struct PassError: Error {
}

typealias PassResult<T> = Result<T, PassError>
