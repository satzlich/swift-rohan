import AppKit
import Foundation

extension DocumentView {
  override public func keyDown(with event: NSEvent) {
    NSCursor.setHiddenUntilMouseMoves(true)

    // intercept trigger character
    if let triggerKey = triggerKey,
      EventMatchers.isCharacter(triggerKey, event)
    {
      self.complete(self)
    }
    else {
      if inputContext?.handleEvent(event) == false {
        // forward event
        interpretKeyEvents([event])
      }
    }
  }

  public override func performKeyEquivalent(with event: NSEvent) -> Bool {
    // ^Space -> complete:
    if EventMatchers.isControlSpace(event) {
      doCommand(by: #selector(NSStandardKeyBindingResponding.complete(_:)))
      return true
    }
    return super.performKeyEquivalent(with: event)
  }

  public override func insertText(_ insertString: Any) {
    insertText(insertString, replacementRange: .notFound)
  }
}
