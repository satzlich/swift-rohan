// Copyright 2024-2025 Lie Yan

import _RopeModule

extension BigString: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self.init(string)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(String(self))
  }
}

extension BigString {
  var llength: Int { utf16.count }
}

extension BigSubstring {
  var llength: Int { utf16.count }
}
