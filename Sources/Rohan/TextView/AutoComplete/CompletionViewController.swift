// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class CompletionViewController: NSViewController {
  var items: [any CompletionItem] = [] {
    didSet {
      tableView.reloadData()
    }
  }

  public let tableView: NSTableView = .init()

  override func loadView() {
    // set up view
    view = NSView()
    view.layer?.cornerCurve = .continuous
    view.layer?.cornerRadius = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    view.wantsLayer = true
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(greaterThanOrEqualToConstant: 320)
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
    tableView.intercellSpacing = CGSize(width: 4, height: 2)
    tableView.rowHeight = 22
    tableView.rowSizeStyle = .custom
    tableView.selectionHighlightStyle = .regular
    tableView.style = .plain
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.usesAlternatingRowBackgroundColors = false
    tableView.usesAutomaticRowHeights = false

    tableView.action = #selector(tableViewAction(_:))
    tableView.doubleAction = #selector(tableViewDoubleAction(_:))
    tableView.target = self

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

  @objc func tableViewAction(_ sender: Any) {
    // select row
  }

  @objc func tableViewDoubleAction(_ sender: Any) {
    // TODO: insert
  }

}
