// Copyright 2024-2025 Lie Yan

import Cocoa
import SwiftRohan

class ViewController: NSViewController {

  @IBOutlet var scrollView: NSScrollView!
  @IBOutlet var documentView: DocumentView!

  private var pageWidth: CGFloat = 595  // a4 paper width

  private var completionProvider: CompletionProvider!

  override var representedObject: Any? {
    didSet {
      guard let content = representedObject as? DocumentContent
      else { return }
      documentView.content = content
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    assert(scrollView.documentView === documentView)
    do {
      scrollView.hasHorizontalScroller = true
      scrollView.hasVerticalScroller = true
      scrollView.autohidesScrollers = true
      scrollView.borderType = .noBorder
      // set up frame and autoresizing
      scrollView.frame = view.bounds
      scrollView.autoresizingMask = [.width, .height]
      // set up zoom
      scrollView.allowsMagnification = true
      scrollView.maxMagnification = 4.0
      scrollView.minMagnification = 0.1
    }
    do {
      documentView.delegate = self
      // set up completion provider
      completionProvider = CompletionProvider()
      completionProvider.addItems(DefaultCommands.allCases)
      documentView.completionProvider = self.completionProvider
      // set up page width
      documentView.pageWidth = pageWidth
    }
  }

  // MARK: - Zoom

  @IBAction func zoomIn(_ sender: Any?) {
    scrollView.magnification = scrollView.magnification + 0.1
  }

  @IBAction func zoomOut(_ sender: Any?) {
    scrollView.magnification = scrollView.magnification - 0.1
  }

  @IBAction func zoomImageToActualSize(_ sender: Any?) {
    scrollView.magnification = 1.0
  }
}

extension ViewController: DocumentViewDelegate {
  func documentDidChange(_ documentView: DocumentView) {
    if let document = self.view.window?.windowController?.document as? Document {
      // mark as edited
      document.updateChangeCount(.changeDone)
    }
  }
}

extension ViewController: NSMenuItemValidation {
  func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    switch menuItem.action {
    case #selector(zoomIn(_:)):
      return scrollView.magnification < scrollView.maxMagnification
    case #selector(zoomOut(_:)):
      return scrollView.magnification > scrollView.minMagnification
    case #selector(zoomImageToActualSize(_:)):
      return abs(scrollView.magnification - 1.0) > 0.01
    default:
      return true
    }
  }
}
