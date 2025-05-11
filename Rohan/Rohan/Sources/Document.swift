// Copyright 2024-2025 Lie Yan

import Cocoa
import SwiftRohan

class Document: NSDocument {

  private(set) var content = DocumentContent()

  override init() {
    super.init()
  }

  override class var autosavesInPlace: Bool {
    return true
  }

  override func makeWindowControllers() {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let windowController =
      storyboard.instantiateController(
        withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")
      ) as! NSWindowController

    // make the window full size
    if let window = windowController.window {
      window.setFrame(NSScreen.main?.visibleFrame ?? window.frame, display: true)
    }

    self.addWindowController(windowController)

    // pass content to view controller
    if let viewController = windowController.contentViewController as? ViewController {
      viewController.representedObject = content
    }
  }

  override func data(ofType typeName: String) throws -> Data {
    if let data = content.data() {
      return data
    }
    else {
      throw NSError(domain: Rohan.domain, code: 0, userInfo: nil)
    }
  }

  override func read(from data: Data, ofType typeName: String) throws {
    if let content = DocumentContent.from(data) {
      self.content = content

      // pass content to view controller
      if let viewController = windowControllers.first?.contentViewController
        as? ViewController
      {
        viewController.representedObject = content
      }
    }
    else {
      throw NSError(domain: Rohan.domain, code: 0, userInfo: nil)
    }
  }

  func setStyle(_ style: StyleSheet) {
    (windowControllers.first?.contentViewController as? ViewController)?.setStyle(style)
  }
}
