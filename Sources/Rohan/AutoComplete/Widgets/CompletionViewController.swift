// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class CompletionViewController: NSViewController {

  public weak var delegate: CompletionViewControllerDelegate?

  public var items: [any CompletionItem] = [] {
    didSet {
      tableView.reloadData()
      view.needsUpdateConstraints = true
    }
  }

  public let tableView: NSTableView = .init()

  private var eventMonitor: Any?
  private var heightConstraint: NSLayoutConstraint!

  // MARK: - Parameters

  private static let minViewWidth: CGFloat = 320
  private static let maxVisibleItemsCount: CGFloat = 8.5
  private static let rowHeight: CGFloat = 22
  private static let intercellSpacing: CGSize = .init(width: 4, height: 2)

  // MARK: - View behaviour

  public override func loadView() {
    // set up view
    view = NSView()
    view.wantsLayer = true  // wantsLayer should preceed other layer settings
    view.layer?.cornerCurve = .continuous
    view.layer?.cornerRadius = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(greaterThanOrEqualToConstant: Self.minViewWidth)
    ])

    // add background effect to view
    let backgroundEffect = NSVisualEffectView(frame: view.bounds)
    backgroundEffect.autoresizingMask = [.width, .height]
    backgroundEffect.blendingMode = .withinWindow
    backgroundEffect.material = .windowBackground
    backgroundEffect.state = .followsWindowActiveState
    backgroundEffect.wantsLayer = true
    view.addSubview(backgroundEffect)

    // set up table view
    tableView.allowsColumnResizing = false
    tableView.allowsEmptySelection = false
    tableView.backgroundColor = .clear
    tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
    tableView.headerView = nil
    tableView.intercellSpacing = Self.intercellSpacing
    tableView.rowHeight = Self.rowHeight
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
    let scrollView = NSScrollView()
    scrollView.automaticallyAdjustsContentInsets = false
    scrollView.autoresizingMask = [.width, .height]
    scrollView.backgroundColor = .clear
    scrollView.borderType = .noBorder
    scrollView.contentInsets = NSEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.documentView = tableView

    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  public override func viewDidAppear() {
    super.viewDidAppear()
    // add local event monitor
    eventMonitor = NSEvent.addLocalMonitorForEvents(
      matching: .keyDown,
      handler: { [weak self] event -> NSEvent? in self?.handleEvent(event) })
  }

  public override func viewDidDisappear() {
    super.viewDidDisappear()
    // remove event monitor
    if let eventMonitor = eventMonitor { NSEvent.removeMonitor(eventMonitor) }
    eventMonitor = nil
  }

  public override func updateViewConstraints() {
    if heightConstraint == nil {
      // constant "0" to be overridden immediately below
      heightConstraint = view.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
      heightConstraint.isActive = true
    }
    let height = {
      let n = min(Self.maxVisibleItemsCount, CGFloat(items.count))
      let contentInsets = tableView.enclosingScrollView!.contentInsets
      return (n * tableView.rowHeight) + (tableView.intercellSpacing.height * n)
        + (contentInsets.top + contentInsets.bottom)
    }()
    heightConstraint.constant = max(tableView.rowHeight, height)

    super.updateViewConstraints()
  }

  // MARK: - Handle Commands

  @objc func tableViewAction(_ sender: Any) {
    // select row
  }

  @objc func tableViewDoubleAction(_ sender: Any) {
    insertCompletionItem(movement: .other)
  }

  public override func insertTab(_ sender: Any?) {
    insertCompletionItem(movement: .tab)
  }

  public override func insertLineBreak(_ sender: Any?) {
    insertCompletionItem(movement: .return)
  }

  public override func insertNewline(_ sender: Any?) {
    insertCompletionItem(movement: .return)
  }

  public override func cancelOperation(_ sender: Any?) {
    view.window?.windowController?.close()
  }

  // MARK: - Private

  private func handleEvent(_ event: NSEvent) -> NSEvent? {
    guard let characters = event.characters else { return event }

    for c in characters {
      switch c {
      case Characters.escape,
        Characters.tab,
        Characters.newline,
        Characters.carriageReturn,
        Characters.enter:
        self.interpretKeyEvents([event])
        return nil

      case Characters.downArrowFn,
        Characters.upArrowFn:
        self.tableView.keyDown(with: event)  // forward to tableView
        return nil

      default:
        break  // continue outer loop
      }
    }
    return event
  }

  private func insertCompletionItem(movement: NSTextMovement) {
    defer { self.cancelOperation(self) }

    guard tableView.selectedRow != -1 else { return }
    let item = items[tableView.selectedRow]

    delegate?.completionViewController(self, item: item, movement: movement)
  }
}

extension CompletionViewController: NSTableViewDelegate {
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

extension CompletionViewController: NSTableViewDataSource {
  public func numberOfRows(in tableView: NSTableView) -> Int { items.count }
}

// MARK: - RhTableRowView

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

    context.setFillColor(NSColor.selectedContentBackgroundColor.cgColor)
    NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
  }
}

private extension NSUserInterfaceItemIdentifier {
  static let labelColumn = NSUserInterfaceItemIdentifier("LabelColumn")
}
