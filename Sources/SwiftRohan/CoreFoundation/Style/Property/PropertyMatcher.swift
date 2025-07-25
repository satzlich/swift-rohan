import Foundation

internal struct PropertyMatcher: Equatable, Hashable, Codable, Sendable {
  public let name: PropertyName
  public let value: PropertyValue

  public init(_ name: PropertyName, _ value: PropertyValue) {
    self.name = name
    self.value = value
  }
}
