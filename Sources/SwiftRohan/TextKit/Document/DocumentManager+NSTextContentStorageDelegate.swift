// Copyright 2024-2025 Lie Yan

import AppKit

extension DocumentManager: @preconcurrency NSTextContentStorageDelegate {
  public func textContentStorage(
    _ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange
  ) -> NSTextParagraph? {
    return nil
  }
}
