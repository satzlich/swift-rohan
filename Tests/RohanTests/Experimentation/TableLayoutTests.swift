import AppKit
import DequeModule
import Testing

@testable import SwiftRohan

struct TableLayoutTests {
  @MainActor
  @Test
  func layoutTable() {
    let textContentStorage = NSTextContentStoragePatched()
    let textLayoutManager = NSTextLayoutManager()

    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    textLayoutManager.textContainer =
      NSTextContainer(size: CGSize(width: 600, height: 400))

    let attrString = tableAttributedString()
    textContentStorage.textStorage!.setAttributedString(attrString)
    textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
    TestUtils.outputPDF(
      #function, textLayoutManager.textContainer!.size, textLayoutManager)
  }

  func tableAttributedString() -> NSMutableAttributedString {
    let tableString = NSMutableAttributedString(string: "\n\n")
    let table = NSTextTable()
    table.numberOfColumns = 2

    tableString.append(
      tableCellAttributedString(
        with: "Cell1\n",
        table: table,
        backgroundColor: .green,
        borderColor: .magenta,
        row: 0,
        column: 0))

    tableString.append(
      tableCellAttributedString(
        with: "Cell2\n",
        table: table,
        backgroundColor: .yellow,
        borderColor: .blue,
        row: 0,
        column: 1))

    tableString.append(
      tableCellAttributedString(
        with: "Cell3\n",
        table: table,
        backgroundColor: .lightGray,
        borderColor: .red,
        row: 1,
        column: 0))

    tableString.append(
      tableCellAttributedString(
        with: "Cell4\n",
        table: table,
        backgroundColor: .cyan,
        borderColor: .orange,
        row: 1,
        column: 1))

    return tableString
  }

  func tableCellAttributedString(
    with string: String,
    table: NSTextTable,
    backgroundColor: NSColor,
    borderColor: NSColor,
    row: Int,
    column: Int
  ) -> NSMutableAttributedString {

    let block = NSTextTableBlock(
      table: table,
      startingRow: row,
      rowSpan: 1,
      startingColumn: column,
      columnSpan: 1)
    block.setBorderColor(borderColor)
    block.backgroundColor = backgroundColor
    block.setWidth(4.0, type: .absoluteValueType, for: .border)
    block.setWidth(6.0, type: .absoluteValueType, for: .padding)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.textBlocks = [block]

    let cellString = NSMutableAttributedString(string: string)
    cellString.addAttribute(
      .paragraphStyle,
      value: paragraphStyle,
      range: NSRange(location: 0, length: cellString.length))

    return cellString
  }
}
