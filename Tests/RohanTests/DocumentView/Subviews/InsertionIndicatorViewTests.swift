import AppKit
import Foundation
import Testing

@testable import SwiftRohan

@MainActor
struct InsertionIndicatorViewTests {
  @Test
  func coverage() {
    let enclosingView = NSView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let view = InsertionIndicatorView()

    enclosingView.addSubview(view)

    //
    view.showPrimaryIndicator(CGRect(x: 10, y: 10, width: 0, height: 100))
    view.addSecondaryIndicator(CGRect(x: 20, y: 10, width: 0, height: 100))
    view.addSecondaryIndicator(CGRect(x: 30, y: 10, width: 0, height: 100))

    //
    view.indicatorWidth = 2.0

    //
    view.startBlinking()
    view.setNeedsDisplay(view.bounds)
    Thread.sleep(forTimeInterval: 0.8)
    view.stopBlinking()

    //
    view.hidePrimaryIndicator()
    view.clearSecondaryIndicators()
  }

  @Test
  func textInsertionIndicator() {
    let textInsertionIndicator = CustomInsertionIndicator()

    textInsertionIndicator.draw(.infinite)
  }
}
