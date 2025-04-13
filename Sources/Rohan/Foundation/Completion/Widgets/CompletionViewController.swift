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

  private static let minViewWidth: CGFloat = 280
  private static let minVisibleRows: CGFloat = 2
  private static let maxVisibleRows: CGFloat = 8.5  // 8.5 rows, practice of Xcode
  private static let rowHeight: CGFloat = 24
  private static let intercellSpacing: CGSize = .init(width: 4, height: 2)

  // MARK: - View behaviour

  public override func loadView() {
    // set up view
    view = NSView()
    view.wantsLayer = true  // wantsLayer should preceed other settings
    view.layer?.cornerCurve = .continuous
    view.layer?.cornerRadius = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(greaterThanOrEqualToConstant: Self.minViewWidth)
    ])

    // add background effect to view
    let backgroundEffect = NSVisualEffectView(frame: view.bounds)
    backgroundEffect.wantsLayer = true  // wantsLayer should preceed other settings
    backgroundEffect.autoresizingMask = [.width, .height]
    backgroundEffect.blendingMode = .withinWindow
    backgroundEffect.material = .windowBackground
    backgroundEffect.state = .followsWindowActiveState
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
      matching: [.keyDown],
      handler: { [weak self] event -> NSEvent? in self?.handleEvent(event) })
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    // call delegate to respond to view frame change
    self.delegate?.viewFrameDidChange(self, frame: view.frame)
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
      heightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
      heightConstraint.isActive = true
    }
    let height = {
      let n = min(max(Double(items.count), Self.minVisibleRows), Self.maxVisibleRows)
      let contentInsets = tableView.enclosingScrollView!.contentInsets
      return (n * tableView.rowHeight) + (tableView.intercellSpacing.height * n)
        + (contentInsets.top + contentInsets.bottom)
    }()
    heightConstraint.constant = height
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
    guard let characters = event.charactersIgnoringModifiers?.lowercased()
    else { return event }

    // try to capture Control+N, Control+P
    if event.modifierFlags.contains(.control) {
      switch characters {
      case "n":
        let downArrowEvent = Self.synthesizeEvent(Characters.downArrowFn, event)!
        self.tableView.keyDown(with: downArrowEvent)
        return nil
      case "p":
        let upArrowEvent = Self.synthesizeEvent(Characters.upArrowFn, event)!
        self.tableView.keyDown(with: upArrowEvent)
        return nil
      default:
        break  // FALL THROUGH
      }
    }

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
        break
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

  private static func synthesizeEvent(
    _ character: Character, _ event: NSEvent
  ) -> NSEvent? {
    NSEvent.keyEvent(
      with: .keyDown, location: event.locationInWindow, modifierFlags: [],
      timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil,
      characters: String(character), charactersIgnoringModifiers: String(character),
      isARepeat: false, keyCode: event.keyCode)
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

    let backgroundColor = NSColor.selectedContentBackgroundColor.withAlphaComponent(0.7)
    context.setFillColor(backgroundColor.cgColor)
    NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
  }
}

private extension NSUserInterfaceItemIdentifier {
  static let labelColumn = NSUserInterfaceItemIdentifier("LabelColumn")
}
