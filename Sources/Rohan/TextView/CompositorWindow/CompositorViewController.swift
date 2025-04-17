import AppKit

class CompositorViewController: NSViewController {
  weak var delegate: CompositorViewDelegate? = nil

  /// Completion items
  public var items: [CompletionItem] = [] {
    didSet {
      tableView.reloadData()
      tableView.scrollRowToVisible(tableView.selectedRow)
      view.needsUpdateConstraints = true
    }
  }

  var compositorMode: CompositorMode = .normal {
    didSet { rearrangeWidgets() }
  }

  /*
   stackView (in case tablePosition = .below)
   ├ textFieldStack
   | ├ iconView
   | └ textField
   └ scrollView
     └ tableView
   */
  private let stackView: NSStackView = .init()
  private let textFieldStack: NSStackView = .init()
  private let textField: NSTextField = .init()
  private let scrollView: NSScrollView = .init()
  private let tableView: NSTableView = .init()

  private var heightConstraint: NSLayoutConstraint!
  private var widthConstraint: NSLayoutConstraint!

  private enum Consts {
    static let textFont: NSFont = CompositorStyle.textFont
    static let iconSize: CGFloat = CompositorStyle.iconSize
    static let leadingPadding: CGFloat = CompositorStyle.leadingPadding
    static let trailingPadding: CGFloat = CompositorStyle.trailingPadding
    static let contentInset: CGFloat = CompositorStyle.contentInset
    static let iconDiff: CGFloat = CompositorStyle.iconDiff
    static let iconTextSpacing: CGFloat = CompositorStyle.iconTextSpacing

    static let minFrameWidth: CGFloat = 300
    static let minVisibleRows: CGFloat = 2
    static let maxVisibleRows: CGFloat = 8.5
    static let rowHeight: CGFloat = 24
    static let textPrompt: String = "..."
    static let textFieldTopInset: CGFloat = 7
    static let intercellSpacing: CGSize = .init(width: 4, height: 2)
  }

  override func loadView() {
    stackView.wantsLayer = true
    stackView.spacing = 4
    stackView.layer?.cornerCurve = .continuous
    stackView.layer?.cornerRadius = 8

    // add background effect to view
    let backgroundEffect = NSVisualEffectView(frame: stackView.bounds)
    backgroundEffect.wantsLayer = true
    backgroundEffect.autoresizingMask = [.width, .height]
    backgroundEffect.blendingMode = .withinWindow
    backgroundEffect.material = .windowBackground
    backgroundEffect.state = .followsWindowActiveState
    stackView.addSubview(backgroundEffect)

    // set up table view
    tableView.allowsColumnResizing = false
    tableView.allowsEmptySelection = false
    tableView.backgroundColor = .clear
    tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
    tableView.headerView = nil
    tableView.intercellSpacing = Consts.intercellSpacing
    tableView.rowHeight = Consts.rowHeight
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
    scrollView.contentInsets = {
      let c = Consts.contentInset
      return NSEdgeInsets(top: c, left: c, bottom: c, right: c)
    }()
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.documentView = tableView

    // set up text field
    textFieldStack.wantsLayer = true
    textFieldStack.layer?.backgroundColor = .white
    textFieldStack.orientation = .horizontal
    textFieldStack.spacing = Consts.iconTextSpacing
    textFieldStack.edgeInsets = {
      let contentInsets = tableView.enclosingScrollView!.contentInsets
      let top = Consts.textFieldTopInset
      let left = contentInsets.left + Consts.leadingPadding + Consts.iconDiff
      let right = Consts.trailingPadding + contentInsets.right
      return .init(top: top, left: left, bottom: 0, right: right)
    }()
    let iconSymbol = "chevron.right.square.fill"
    let iconView = SFSymbolUtils.textField(for: iconSymbol, Consts.iconSize)

    textFieldStack.addArrangedSubview(iconView)
    textFieldStack.addArrangedSubview(textField)
    textField.font = Consts.textFont
    textField.placeholderString = Consts.textPrompt
    textField.delegate = self
    textField.isBordered = false  // Remove default border
    textField.drawsBackground = false  // Make background transparent
    textField.backgroundColor = .clear  // Ensure no internal background
    textField.focusRingType = .none  // Remove focus ring (optional)

    // set up stack view
    stackView.orientation = .vertical
    self.rearrangeWidgets()

    self.view = stackView
  }

  /// reocder widgets in stack view
  /// - Important: The method is **idempotent**.
  private func rearrangeWidgets() {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    switch compositorMode {
    case .normal:
      stackView.addArrangedSubview(textFieldStack)
      stackView.addArrangedSubview(scrollView)
    case .inverted:
      stackView.addArrangedSubview(scrollView)
      stackView.addArrangedSubview(textFieldStack)
    }
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    delegate?.viewDidLayout(self)
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    focusTextField()
  }

  /// Place focus on the text field
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
    heightConstraint.constant = {
      let itemsCount = Double(items.count)
      let n = itemsCount.clamped(Consts.minVisibleRows, Consts.maxVisibleRows)
      let contentInsets = tableView.enclosingScrollView!.contentInsets
      return (n * tableView.rowHeight) + (n * tableView.intercellSpacing.height)
        + (contentInsets.top + contentInsets.bottom)
        + textField.frame.height + Consts.textFieldTopInset * 2
        + (stackView.edgeInsets.top + stackView.edgeInsets.bottom + stackView.spacing)
    }()

    if widthConstraint == nil {
      // constant "0" to be overridden immediately below
      widthConstraint = view.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
      widthConstraint.isActive = true
    }
    widthConstraint.constant = Consts.minFrameWidth
    super.updateViewConstraints()
  }

  @objc func tableViewAction(_ sender: Any) {
    // do nothing
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

    case #selector(deleteBackward(_:)):
      if textField.stringValue.isEmpty {
        cancelOperation(self)
        return true
      }
      return false

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
      self.isSelected,
      self.selectionHighlightStyle != .none
    else { return }

    context.saveGState()
    defer { context.restoreGState() }

    let selectionPath =
      NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)

    // main highlight fill
    NSColor(white: 1.0, alpha: 0.75).setFill()
    selectionPath.fill()

    // inner glow
    NSColor(white: 1.0, alpha: 1.0).setStroke()
    selectionPath.lineWidth = 0.5
    selectionPath.stroke()

    // outer glow
    let outerGlowPath = NSBezierPath(
      roundedRect: bounds.insetBy(dx: -1.5, dy: -1.5),
      xRadius: cornerRadius + 1.5,
      yRadius: cornerRadius + 1.5
    )
    NSColor(white: 1.0, alpha: 0.1).setStroke()
    outerGlowPath.lineWidth = 1.5
    outerGlowPath.stroke()
  }

  // Ensure the appearance is consistent regardless of focus state
  override var isEmphasized: Bool {
    get { return false }
    set {}  // do nothing
  }
}

private extension NSUserInterfaceItemIdentifier {
  static let labelColumn = NSUserInterfaceItemIdentifier("LabelColumn")
}
