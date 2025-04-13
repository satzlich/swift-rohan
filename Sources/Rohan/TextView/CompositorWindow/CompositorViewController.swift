import AppKit

class CompositorViewController: NSViewController {

  enum TablePosition { case above, below }

  weak var delegate: CompositorViewDelegate?

  /// Completion items
  public var items: [any CompletionItem] = [] {
    didSet {
      tableView.reloadData()
      view.needsUpdateConstraints = true
    }
  }

  var tablePosition: TablePosition = .above
  /*
   stackView (tablePosition = below)
   |- textField
   |- scrollView
      |-- tableView
   */
  private let textField: NSTextField = .init()
  private let tableView: NSTableView = .init()
  private let scrollView: NSScrollView = .init()
  private let stackView: NSStackView = .init()

  private var heightConstraint: NSLayoutConstraint!

  private enum Constants {
    static let minFrameWidth: CGFloat = 280
    static let minVisibleRows: CGFloat = 2
    static let maxVisibleRows: CGFloat = 8.5
    static let rowHeight: CGFloat = 24
    static let textFieldPadding: CGFloat = 8
    static let prompt: String = "Type command ..."
  }

  override func loadView() {
    stackView.wantsLayer = true
    stackView.layer?.cornerCurve = .continuous
    stackView.layer?.cornerRadius = 8
    NSLayoutConstraint.activate([
      stackView.widthAnchor.constraint(
        greaterThanOrEqualToConstant: Constants.minFrameWidth)
    ])

    // add background effect to view
    let backgroundEffect = NSVisualEffectView(frame: stackView.bounds)
    backgroundEffect.wantsLayer = true
    backgroundEffect.autoresizingMask = [.width, .height]
    backgroundEffect.blendingMode = .withinWindow
    backgroundEffect.material = .windowBackground
    backgroundEffect.state = .followsWindowActiveState
    stackView.addSubview(backgroundEffect)

    // set up text field
    textField.placeholderString = Constants.prompt
    textField.focusRingType = .none
    textField.delegate = self

    // set up table view
    tableView.allowsColumnResizing = false
    tableView.allowsEmptySelection = false
    tableView.backgroundColor = .clear
    tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
    tableView.headerView = nil
    tableView.intercellSpacing = CGSize(width: 4, height: 2)
    tableView.rowHeight = Constants.rowHeight
    tableView.rowSizeStyle = .custom
    tableView.selectionHighlightStyle = .regular
    tableView.style = .plain
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.usesAlternatingRowBackgroundColors = false
    tableView.usesAutomaticRowHeights = false

    tableView.action = #selector(tableViewAction(_:))
    tableView.doubleAction = #selector(tableViewDoubleAction(_:))
    tableView.dataSource = self
    tableView.delegate = self
    tableView.target = self

    do {
      let labelColumn = NSTableColumn(identifier: .labelColumn)
      labelColumn.resizingMask = .autoresizingMask
      tableView.addTableColumn(labelColumn)
    }

    // set up scroll view
    scrollView.automaticallyAdjustsContentInsets = false
    scrollView.autoresizingMask = [.width, .height]
    scrollView.backgroundColor = .clear
    scrollView.borderType = .noBorder
    scrollView.contentInsets = NSEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.documentView = tableView

    stackView.orientation = .vertical
    switch tablePosition {
    case .below:
      stackView.addArrangedSubview(textField)
      stackView.addArrangedSubview(scrollView)
    case .above:
      stackView.addArrangedSubview(scrollView)
      stackView.addArrangedSubview(textField)
    }

    self.view = stackView
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    focusTextField()
  }

  private func focusTextField() {
    DispatchQueue.main.async { [weak self] in
      self?.view.window?.makeFirstResponder(self?.textField)
    }
  }

  public override func updateViewConstraints() {
    if heightConstraint == nil {
      // constant "0" to be overridden immediately below
      heightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
      heightConstraint.isActive = true
    }
    let height = {
      let n =
        min(max(Double(items.count), Constants.minVisibleRows), Constants.maxVisibleRows)
      let contentInsets = tableView.enclosingScrollView!.contentInsets
      return (n * tableView.rowHeight) + (tableView.intercellSpacing.height * n)
        + (contentInsets.top + contentInsets.bottom)
        + textField.frame.height + stackView.spacing
    }()
    heightConstraint.constant = height
    super.updateViewConstraints()
  }

  @objc func tableViewAction(_ sender: Any) {
    // select row
    Rohan.logger.debug("tableViewAction")
  }

  @objc func tableViewDoubleAction(_ sender: Any) {
    commitSelection(movement: .other)
  }

  public override func insertTab(_ sender: Any?) {
    commitSelection(movement: .tab)
  }

  public override func insertLineBreak(_ sender: Any?) {
    commitSelection(movement: .return)
  }

  public override func insertNewline(_ sender: Any?) {
    commitSelection(movement: .return)
  }

  public override func cancelOperation(_ sender: Any?) {
    view.window?.windowController?.close()
  }

  private func commitSelection(movement: NSTextMovement) {
    // close the window at the end
    defer { self.cancelOperation(self) }

    guard tableView.selectedRow != -1 else { return }
    let item = items[tableView.selectedRow]

    delegate?.commitSelection(item, self)
  }
}

extension CompositorViewController: NSTextFieldDelegate {
  func control(
    _ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector
  ) -> Bool {
    switch commandSelector {
    case #selector(insertNewline(_:)),
      #selector(insertLineBreak(_:)),
      #selector(insertTab(_:)):
      commitSelection(movement: .return)
      return true

    case #selector(moveUp(_:)):
      moveSelection(by: -1)
      return true

    case #selector(moveDown(_:)):
      moveSelection(by: 1)
      return true

    default:
      return false
    }
  }

  /// Moves the selection by the given offset.
  private func moveSelection(by offset: Int) {
    let rowCount = tableView.numberOfRows
    guard rowCount > 0 else { return }

    var newRow = tableView.selectedRow + offset
    newRow = max(0, min(newRow, rowCount - 1))

    tableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
    tableView.scrollRowToVisible(newRow)
  }

  func controlTextDidChange(_ obj: Notification) {
    delegate?.commandDidChange(textField.stringValue, self)
  }
}

extension CompositorViewController: NSTableViewDelegate {
  public func tableView(
    _ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int
  ) -> NSView? {
    return items[row].view
  }

  public func tableView(
    _ tableView: NSTableView, rowViewForRow row: Int
  ) -> NSTableRowView? {
    RhTableRowView(
      parentCornerRadius: view.layer!.cornerRadius,
      inset: tableView.enclosingScrollView?.contentInsets.top ?? 0)
  }
}

extension CompositorViewController: NSTableViewDataSource {
  public func numberOfRows(in tableView: NSTableView) -> Int { items.count }
}

private final class RhTableRowView: NSTableRowView {
  private let cornerRadius: CGFloat

  init(parentCornerRadius: CGFloat, inset: CGFloat) {
    self.cornerRadius = max((2 * parentCornerRadius - inset) / 2, 0)
    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func drawSelection(in dirtyRect: NSRect) {
    guard let context = NSGraphicsContext.current?.cgContext,
      self.isSelected
    else { return }

    context.saveGState()
    defer { context.restoreGState() }

    let backgroundColor = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.7)
    context.setFillColor(backgroundColor.cgColor)
    NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
  }
}

private extension NSUserInterfaceItemIdentifier {
  static let labelColumn = NSUserInterfaceItemIdentifier("LabelColumn")
}
