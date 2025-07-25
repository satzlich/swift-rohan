import Foundation

internal struct PageProperty: PropertyAggregate {
  // MARK: - PropertyAggregate

  public static func resolveAggregate(
    _ properties: PropertyDictionary, _ styleSheet: StyleSheet
  ) -> PageProperty {
    @inline(__always)
    func resolved(_ key: PropertyKey) -> PropertyValue {
      key.resolveValue(properties, styleSheet)
    }

    return PageProperty(
      width: resolved(width).absLength()!,
      height: resolved(height).absLength()!,
      topMargin: resolved(topMargin).absLength()!,
      bottomMargin: resolved(bottomMargin).absLength()!,
      leftMargin: resolved(leftMargin).absLength()!,
      rightMargin: resolved(rightMargin).absLength()!)
  }

  public static let allKeys: Array<PropertyKey> = [
    width,
    height,
    topMargin,
    bottomMargin,
    leftMargin,
    rightMargin,
  ]

  /// Resolve the content container width of the page.
  static func resolveContentContainerWidth(_ styleSheet: StyleSheet) -> AbsLength {
    @inline(__always)
    func resolveValue(_ key: PropertyKey) -> PropertyValue {
      styleSheet.resolveDefault(key)
    }
    let pageWidth = resolveValue(PageProperty.width).absLength()!
    let leftMargin = resolveValue(PageProperty.leftMargin).absLength()!
    let rightMargin = resolveValue(PageProperty.rightMargin).absLength()!
    return pageWidth - leftMargin - rightMargin
  }

  // MARK: - Implementation

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

  public static let width = PropertyKey(.root, .width)  // AbsLength
  public static let height = PropertyKey(.root, .height)  // AbsLength
  public static let topMargin = PropertyKey(.root, .topMargin)  // AbsLength
  public static let bottomMargin = PropertyKey(.root, .bottomMargin)  // AbsLength
  public static let leftMargin = PropertyKey(.root, .leftMargin)  // AbsLength
  public static let rightMargin = PropertyKey(.root, .rightMargin)  // AbsLength
}
