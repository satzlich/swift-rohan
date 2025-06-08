// Copyright 2024-2025 Lie Yan

import Foundation

public struct PageProperty: PropertyAggregate {
  public let width: AbsLength
  public let height: AbsLength
  public let topMargin: AbsLength
  public let bottomMargin: AbsLength
  public let leftMargin: AbsLength
  public let rightMargin: AbsLength

  public init(
    width: AbsLength,
    height: AbsLength,
    topMargin: AbsLength,
    bottomMargin: AbsLength,
    leftMargin: AbsLength,
    rightMargin: AbsLength
  ) {
    self.width = width
    self.height = height
    self.topMargin = topMargin
    self.bottomMargin = bottomMargin
    self.leftMargin = leftMargin
    self.rightMargin = rightMargin
  }

  public func getProperties() -> PropertyDictionary {
    [
      PageProperty.width: .absLength(width),
      PageProperty.height: .absLength(height),
      PageProperty.topMargin: .absLength(topMargin),
      PageProperty.bottomMargin: .absLength(bottomMargin),
      PageProperty.leftMargin: .absLength(leftMargin),
      PageProperty.rightMargin: .absLength(rightMargin),
    ]
  }

  public func getAttributes() -> [NSAttributedString.Key: Any] {
    [:]
  }

  public static func resolve(
    _ properties: PropertyDictionary, _ fallback: PropertyMapping
  ) -> PageProperty {
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, fallback)
    }

    return PageProperty(
      width: resolved(width).absLength()!,
      height: resolved(height).absLength()!,
      topMargin: resolved(topMargin).absLength()!,
      bottomMargin: resolved(bottomMargin).absLength()!,
      leftMargin: resolved(leftMargin).absLength()!,
      rightMargin: resolved(rightMargin).absLength()!)
  }

  // MARK: - Key

  public static let width = PropertyKey(.root, .width)  // AbsLength
  public static let height = PropertyKey(.root, .height)  // AbsLength
  public static let topMargin = PropertyKey(.root, .topMargin)  // AbsLength
  public static let bottomMargin = PropertyKey(.root, .bottomMargin)  // AbsLength
  public static let leftMargin = PropertyKey(.root, .leftMargin)  // AbsLength
  public static let rightMargin = PropertyKey(.root, .rightMargin)  // AbsLength

  public static let allKeys: [PropertyKey] = [
    width,
    height,
    topMargin,
    bottomMargin,
    leftMargin,
    rightMargin,
  ]
}
