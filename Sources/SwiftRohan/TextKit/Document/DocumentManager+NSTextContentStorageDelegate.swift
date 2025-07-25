import AppKit

extension DocumentManager: NSTextContentStorageDelegate {
  public func textContentStorage(
    _ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange
  ) -> NSTextParagraph? {
    guard let textStorage = textContentStorage.textStorage else { return nil }

    @inline(__always)
    func attribute(_ key: NSAttributedString.Key) -> Any? {
      textStorage.attribute(key, at: range.location, effectiveRange: nil)
    }

    guard let paragraphStyle = attribute(.paragraphStyle) as? NSParagraphStyle
    else { return nil }

    var targetParagraphStyle: NSMutableParagraphStyle? = nil

    if let firstLineHeadIndent = attribute(.rhFirstLineHeadIndent) as? CGFloat,
      paragraphStyle.firstLineHeadIndent.isNearlyEqual(to: firstLineHeadIndent) == false
    {
      targetParagraphStyle =
        targetParagraphStyle ?? paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
      targetParagraphStyle!.firstLineHeadIndent = firstLineHeadIndent
    }
    if let headIndent = attribute(.rhHeadIndent) as? CGFloat,
      paragraphStyle.headIndent.isNearlyEqual(to: headIndent) == false
    {
      targetParagraphStyle =
        targetParagraphStyle ?? paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
      targetParagraphStyle!.headIndent = headIndent
    }
    if let textAlignment = attribute(.rhTextAlignment) as? NSTextAlignment,
      paragraphStyle.alignment != textAlignment
    {
      targetParagraphStyle =
        targetParagraphStyle ?? paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
      targetParagraphStyle!.alignment = textAlignment
    }

    guard let targetParagraphStyle = targetParagraphStyle else { return nil }

    Rohan.logger.debug("Repairing paragraph style for \(range)")

    let sourceString = textStorage.attributedSubstring(from: range)
    let targetString = NSMutableAttributedString(attributedString: sourceString)
    targetString.addAttribute(
      .paragraphStyle, value: targetParagraphStyle,
      range: NSRange(location: 0, length: targetString.length))
    return NSTextParagraph(attributedString: targetString)
  }
}
