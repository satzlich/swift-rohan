// Copyright 2024-2025 Lie Yan

import Cocoa
import SwiftRohan

class ViewController: NSViewController {

  @IBOutlet var scrollView: NSScrollView!
  @IBOutlet var documentView: DocumentView!

  private var pageWidth: CGFloat = 612  // 8.5 inches (letter size)

  private var completionProvider: CompletionProvider!

  override func viewDidLoad() {
    super.viewDidLoad()

    _setupScrollView()
    _setupDocumentView()
    documentView.pageWidth = pageWidth

    // load content into document view
    if let document = self.view.window?.windowController?.document as? Document {
      documentView.content = document.content
    }
  }

  private func _setupScrollView() {
    // configure scroll view
    scrollView.hasHorizontalScroller = true
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = true
    scrollView.borderType = .noBorder
    scrollView.documentView = documentView
    scrollView.allowsMagnification = true
    scrollView.maxMagnification = 4.0
    scrollView.minMagnification = 0.1
    // set up frame and autoresizing
    scrollView.frame = view.bounds
    scrollView.autoresizingMask = [.width, .height]
    // set up zoom
    scrollView.magnification = 1.0
  }

  private func _setupDocumentView() {
    documentView.delegate = self

    // set up completion provider
    self.completionProvider = CompletionProvider()
    self.completionProvider.addItems(DefaultCommands.allCases)
    documentView.completionProvider = self.completionProvider
  }

  override var representedObject: Any? {
    didSet {
      guard let content = representedObject as? DocumentContent
      else { return }
      documentView.content = content
    }
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
