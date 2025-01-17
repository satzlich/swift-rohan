// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

func someValue<T>() -> T { preconditionFailure() }
func useValue<T>(_: T) {
    // do nothing
}

func computeValue<T, R>(_: T) -> R { preconditionFailure() }
