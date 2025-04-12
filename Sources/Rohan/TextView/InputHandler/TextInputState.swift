// Copyright 2024-2025 Lie Yan

import Foundation

enum TextInputState {
  /// Default state.
  case normal
  /// Composition with IME is in progress.
  case inputMethod
  /// Completion is in progress.
  case completion
}
