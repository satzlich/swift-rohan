import Cocoa
import SwiftRohan

final class ViewController: NSViewController {

  @IBOutlet var scrollView: RhScrollView!
  @IBOutlet var documentView: DocumentView!

  private var completionProvider: CompletionProvider!
  private var replacementProvider: ReplacementProvider!

  override var representedObject: Any? {
    didSet {
      guard let content = representedObject as? DocumentContent else { return }

      if let document = self.view.window?.windowController?.document as? Document {
        let styleSheet = document.getStyleSheet()
        documentView.setContent(content, with: styleSheet)
      }
      else {
        Rohan.logger.warning("No document found in window controller.")
        documentView.setContent(content)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    assert(scrollView.documentView === documentView)
    do {
      scrollView.scrollDelegate = documentView
      //
      scrollView.hasHorizontalScroller = true
      scrollView.hasVerticalScroller = true
      scrollView.autohidesScrollers = true
      scrollView.borderType = .noBorder
      // set up frame and autoresizing
      scrollView.frame = view.bounds
      scrollView.autoresizingMask = [.width, .height]
      // set up zoom
      scrollView.allowsMagnification = true
      scrollView.maxMagnification = 5.0
      scrollView.minMagnification = 0.1
      // initial zoom
      scrollView.magnification = 1.5
    }
    do {
      documentView.delegate = self
      // set up completion provider
      completionProvider = CompletionProvider()
      completionProvider.addItems(CommandRecords.allCases)
      documentView.completionProvider = self.completionProvider
      // set up replacement engine
      replacementProvider = ReplacementProvider(ReplacementRules.allCases)
      documentView.replacementProvider = replacementProvider
    }
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    // set up magnification to avoid unproportional visual scaling
    documentView.scrollView(scrollView, didChangeMagnification: ())
    // request layout and display to avoid blank view
    documentView.needsLayout = true
    documentView.needsDisplay = true
  }

  // MARK: - Zoom

  @IBAction func zoomIn(_ sender: Any?) {
    scrollView.magnification = scrollView.magnification + 0.1
    documentView.scrollView(scrollView, didChangeMagnification: ())
  }

  @IBAction func zoomOut(_ sender: Any?) {
    scrollView.magnification = scrollView.magnification - 0.1
    documentView.scrollView(scrollView, didChangeMagnification: ())
  }

  @IBAction func zoomImageToActualSize(_ sender: Any?) {
    scrollView.magnification = 1.0
    documentView.scrollView(scrollView, didChangeMagnification: ())
  }

  // MARK: - Styles

  func setStyleSheet(_ styleSheet: StyleSheet) {
    documentView.styleSheet = styleSheet
  }
}
