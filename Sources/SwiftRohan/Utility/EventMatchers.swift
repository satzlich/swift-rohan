import AppKit

enum EventMatchers {

  /// Returns true if the event is key down of given character.
  static func isCharacter(_ char: Character, _ event: NSEvent) -> Bool {
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    return (modifierFlags == [] || modifierFlags == [.capsLock])
      && event.charactersIgnoringModifiers == String(char)
  }

  /// Returns true if the event is Control+Space.
  static func isControlSpace(_ event: NSEvent) -> Bool {
    event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .control
      && event.charactersIgnoringModifiers == " "
  }

  /// Returns true if the event is Escape.
  static func isEscape(_ event: NSEvent) -> Bool {
    event.keyCode == 53
  }
}
