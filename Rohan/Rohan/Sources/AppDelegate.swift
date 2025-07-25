import Cocoa
import SwiftRohan

@main
final class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    setupFonts()
    MenuManager.shared.setupThemeMenu()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: - Font Setup

  private func setupFonts() {
    let errors = FontLoader.registerFonts()

    if errors.isEmpty == false {
      for error in errors {
        Rohan.logger.error("Font loading error: \(error.localizedDescription)")
      }
      showFontErrorAlert(errors: errors)
    }
  }

  private func showFontErrorAlert(errors: Array<FontLoader.FontLoadingError>) {
    let alert = NSAlert()
    alert.messageText = "Font Loading Issue"

    if errors.count == 1 {
      let message = errors[0].errorDescription ?? "There was an issue loading a font."
      alert.informativeText = message
    }
    else {
      alert.informativeText = "There were issues loading \(errors.count) fonts."
    }

    alert.addButton(withTitle: "OK")
    alert.alertStyle = .warning

    // Run the alert as a sheet if you have a window, or as modal
    if let window = NSApp.mainWindow {
      alert.beginSheetModal(for: window) { _ in }
    }
    else {
      alert.runModal()
    }
  }
}
