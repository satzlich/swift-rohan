// Copyright 2024-2025 Lie Yan

import AppKit
import DequeModule
import Testing

@testable import SwiftRohan

struct PlaygroundTests {
  @Test
  func layoutTable() {
    let textContentStorage = NSTextContentStoragePatched()
    let textLayoutManager = NSTextLayoutManager()

    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    textLayoutManager.textContainer = NSTextContainer()

    let mas = getTableString()
    textContentStorage.textStorage!.append(mas)
  }

  func getTableString() -> NSMutableAttributedString {
    let table = NSTextTable()
    table.numberOfColumns = 4
    let mas = NSMutableAttributedString()

    // Header
    mas.append(
      createTableCell(
        string: "Header. 1", textTable: table, row: 0, column: 0, width: 25,
        isHeader: true))
    mas.append(
      createTableCell(
        string: "Header. 2", textTable: table, row: 0, column: 1, width: 25,
        isHeader: true))
    mas.append(
      createTableCell(
        string: "Header. 3", textTable: table, row: 0, column: 2, width: 25,
        isHeader: true))
    mas.append(
      createTableCell(
        string: "Header. 4", textTable: table, row: 0, column: 3, width: 25,
        isHeader: true))

    // Row 1
    mas.append(
      createTableCell(string: "Nr. 1", textTable: table, row: 1, column: 0, width: 25))
    mas.append(
      createTableCell(string: "Nr. 2", textTable: table, row: 1, column: 1, width: 25))

    // Create the nested table
    let parentBlock = createTextTableBlock(
      textTable: table, row: 1, column: 2, columnSpan: 2, width: 50)
    let nestedTable = NSTextTable()
    nestedTable.numberOfColumns = 2
    mas.append(
      createTableCell(
        string: "Nested 1", textTable: nestedTable, row: 0, column: 0, width: 50,
        isNested: true, parentBlocks: [parentBlock]))
    mas.append(
      createTableCell(
        string: "Nested 2", textTable: nestedTable, row: 0, column: 1, width: 50,
        isNested: true, parentBlocks: [parentBlock]))

    return mas
  }

  func createTextTableBlock(
    textTable: NSTextTable, row: Int, column: Int, columnSpan: Int = 1, width: CGFloat,
    isHeader: Bool = false, isNested: Bool = false
  ) -> NSTextTableBlock {
    let block = NSTextTableBlock(
      table: textTable, startingRow: row, rowSpan: 1, startingColumn: column,
      columnSpan: columnSpan)
    block.backgroundColor = isHeader ? .lightGray : .white
    block.setBorderColor(isNested ? .red : .green)
    block.setWidth(
      1.0, type: NSTextBlock.ValueType.absoluteValueType, for: NSTextBlock.Layer.border)
    block.setContentWidth(width, type: .percentageValueType)
    return block
  }

  func createTableCell(
    string: String, textTable: NSTextTable, row: Int, column: Int, columnSpan: Int = 1,
    width: CGFloat, isHeader: Bool = false, isNested: Bool = false,
    parentBlocks: [NSTextTableBlock] = []
  ) -> NSAttributedString {
    let block = createTextTableBlock(
      textTable: textTable, row: row, column: column, columnSpan: columnSpan,
      width: width, isHeader: isHeader, isNested: isNested)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = isNested ? .center : .left
    paragraphStyle.textBlocks = parentBlocks + [block]

    return NSAttributedString(
      string: string + "\n", attributes: [.paragraphStyle: paragraphStyle])
  }
}
