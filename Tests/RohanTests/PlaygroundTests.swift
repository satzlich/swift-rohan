import AppKit
import DequeModule
import Testing

@testable import SwiftRohan

struct PlaygroundTests {

  var folderName: String { "PlaygroundTests" }

  init() throws {
    try TestUtils.touchDirectory(folderName)
  }

  @Test(
    "LoadImage",
    arguments: [
      "example.jpg",
      "example.pdf",
      "example.png",
      "example.svg",
      "example.tiff",
    ])
  func loadImage(_ fullName: String) throws {
    let components = fullName.split(separator: ".").map(String.init)
    guard components.count == 2,
      let fileName = components.first,
      let fileExtension = components.last,
      let url = Bundle.module.url(forResource: fileName, withExtension: fileExtension),
      let image = NSImage(contentsOf: url)
    else {
      Issue.record("Could not find \(fullName) in bundle")
      return
    }
    let pageSize = CGSize(width: 100, height: 100)

    let outputFileName = String(#function.dropLast(4) + "_\(fileExtension)")
    TestUtils.outputPDF(folderName: folderName, outputFileName, pageSize) { bounds in
      let origin = CGPoint(
        x: (bounds.width - image.size.width) / 2,
        y: (bounds.height - image.size.height) / 2)
      let mediaBox = CGRect(origin: origin, size: image.size)
      image.draw(in: mediaBox)
    }
  }
}
