import AppKit
import SatzAlgorithms
import SwiftUI
import _RopeModule

struct CompletionItem: Identifiable {
  enum ItemPreview {
    case attrString(AttributedString)
    case image(String)  // file name without extension
  }

  let id: String
  private let _iconSymbol: String
  private let _label: AttributedString
  let record: CommandRecord
  private let _preview: ItemPreview

  init(id: String, _ result: CompletionProvider.Result, _ query: String) {
    self.id = id

    let baseAttrs = CompositorStyle.baseAttrs
    let emphAttrs = CompositorStyle.emphAttrs

    // label
    let label = _generateLabel(result, query, baseAttrs, emphAttrs: emphAttrs)
    self._label = AttributedString(label)
    //
    self._iconSymbol = CompletionItem._iconSymbol(for: result.key)
    self.record = result.value
    // preview
    let previewAttrs = CompositorStyle.previewAttrs(mathMode: record.body.isMathOnly)
    self._preview = CompletionItem._preview(for: record.body, previewAttrs)
  }

  private enum Consts {
    static let leadingPadding: CGFloat = CompositorStyle.leadingPadding
    static let trailingPadding: CGFloat = CompositorStyle.trailingPadding
    static let iconSize: CGFloat = CompositorStyle.iconSize
    static let previewSize: CGFloat = CompositorStyle.iconSize
  }

  @MainActor
  var view: NSView {
    NSHostingView(
      rootView: VStack(alignment: .leading) {
        HStack {
          Image(systemName: _iconSymbol)
            .foregroundColor(.cyan)
            .font(.system(size: Consts.iconSize))
            .padding(.leading, Consts.leadingPadding)
          Text(_label)
            .fixedSize(horizontal: true, vertical: false)
            .lineLimit(1)
          Spacer()
          CompletionItem._previewView(for: _preview)
        }
      })
  }

  private static func _iconSymbol(for label: String) -> String {
    if let firstChar = label.first,
      firstChar.isASCII, firstChar.isLetter
    {
      return "\(firstChar.lowercased()).square.fill"
    }
    else {
      return "text.insert"
    }
  }

  @ViewBuilder
  private static func _previewView(for preview: ItemPreview) -> some View {
    switch preview {
    case .attrString(let string):
      Text(string)
        .padding(.trailing, Consts.trailingPadding)
        .lineLimit(1)

    case .image(let imageName):
      if let image = _imageCache.tryGetOrCreate(imageName, { tryLoadImage(imageName) }) {
        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: CompositorStyle.rowHeight - 2)
          .padding(.trailing, Consts.trailingPadding)
      }
      else {
        Text("⬚")
          .padding(.trailing, Consts.trailingPadding)
          .lineLimit(1)
      }
    }
  }

  private static func _preview(
    for body: CommandBody, _ attributes: Dictionary<NSAttributedString.Key, Any>
  ) -> ItemPreview {
    switch body.preview {
    case .string(let string):
      let nsAttrString = NSAttributedString(string: string, attributes: attributes)
      let attrString = AttributedString(nsAttrString)
      return .attrString(attrString)
    case .image(let imageName):
      return .image(imageName)
    }
  }

  nonisolated(unsafe) private static let _imageCache = ConcurrentCache<String, NSImage>()

  private static func tryLoadImage(_ imageName: String) -> NSImage? {
    guard let path = Bundle.module.path(forResource: imageName, ofType: "pdf"),
      let image = NSImage(contentsOfFile: path)
    else {
      return nil
    }
    return image
  }
}

private func _generateLabel(
  _ result: CompletionProvider.Result, _ pattern: String,
  _ baseAttrs: Dictionary<NSAttributedString.Key, Any>,
  emphAttrs: Dictionary<NSAttributedString.Key, Any>
) -> NSAttributedString {

  let label = result.key
  let attrString = NSMutableAttributedString(string: label)

  switch result.matchSpec {
  case .equal(caseSensitive: _):
    attrString.setAttributes(emphAttrs, range: NSRange(0..<attrString.length))
    return attrString

  case .prefix(_, length: let length):
    attrString.setAttributes(baseAttrs, range: NSRange(0..<attrString.length))
    attrString.setAttributes(emphAttrs, range: NSRange(0..<length))
    return attrString

  case .prefixPlus(_, length: let length):
    attrString.setAttributes(baseAttrs, range: NSRange(0..<attrString.length))
    attrString.setAttributes(emphAttrs, range: NSRange(0..<length))

    let labelSuffix = label.lowercased().utf16.dropFirst(length)
    let patternSuffix = pattern.lowercased().utf16.dropFirst(length)

    return _decorateSuffix(
      attrString, length, labelSuffix, by: patternSuffix, baseAttrs, emphAttrs: emphAttrs)

  case let .subString(location, length):
    attrString.setAttributes(baseAttrs, range: NSRange(0..<attrString.length))
    attrString.setAttributes(emphAttrs, range: NSRange(location..<location + length))
    return attrString

  case let .subStringPlus(location, length):
    attrString.setAttributes(baseAttrs, range: NSRange(0..<attrString.length))
    attrString.setAttributes(emphAttrs, range: NSRange(location..<location + length))

    let labelSuffix = label.lowercased().utf16.dropFirst(location + length)
    let patternSuffix = pattern.lowercased().utf16.dropFirst(length)

    return _decorateSuffix(
      attrString, location + length, labelSuffix, by: patternSuffix, baseAttrs,
      emphAttrs: emphAttrs)

  case .nGram:
    let n = CompletionProvider.gramSize
    return decorateLabel_nGram(label, by: pattern, baseAttrs, emphAttrs: emphAttrs, n)

  case .nGramPlus, .subSequence:
    attrString.setAttributes(baseAttrs, range: NSRange(0..<attrString.length))

    let label = label.lowercased().utf16
    let pattern = pattern.lowercased().utf16

    return _decorateSuffix(
      attrString, 0, label[...], by: pattern[...], baseAttrs, emphAttrs: emphAttrs)
  }
}

private func _decorateSuffix(
  _ attrString: NSMutableAttributedString, _ prefixLength: Int,
  _ labelSuffix: String.UTF16View.SubSequence,
  by patternSuffix: String.UTF16View.SubSequence,
  _ baseAttrs: Dictionary<NSAttributedString.Key, Any>,
  emphAttrs: Dictionary<NSAttributedString.Key, Any>
) -> NSAttributedString {
  var i = labelSuffix.startIndex
  var ii = prefixLength
  var j = patternSuffix.startIndex
  var emphRange: Range<Int>?

  while i < labelSuffix.endIndex && j < patternSuffix.endIndex {
    if labelSuffix[i] == patternSuffix[j] {
      if let range = emphRange {
        // it's okay to plus "1" as we are using UTF16View (same below)
        emphRange = range.lowerBound..<ii + 1
      }
      else {
        emphRange = ii..<ii + 1
      }
      j = patternSuffix.index(after: j)
    }
    else if let range = emphRange {
      attrString.addAttributes(emphAttrs, range: NSRange(range))
      emphRange = nil
    }

    i = labelSuffix.index(after: i)
    ii += 1
  }

  if let range = emphRange {
    attrString.addAttributes(emphAttrs, range: NSRange(range))
  }

  return attrString
}

private func decorateLabel_nGram(
  _ label: String, by pattern: String,
  _ baseAttrs: Dictionary<NSAttributedString.Key, Any>,
  emphAttrs: Dictionary<NSAttributedString.Key, Any>,
  _ gramSize: Int
) -> NSAttributedString {
  precondition(gramSize > 1)

  let attrString = NSMutableAttributedString(string: label)
  attrString.setAttributes(baseAttrs, range: NSRange(0..<attrString.length))

  guard !pattern.isEmpty else { return attrString }

  let labelGrams = Satz.nGrams(of: label.lowercased(), n: gramSize)
  let patternGrams = Satz.nGrams(of: pattern.lowercased(), n: gramSize)

  var i = 0
  var ii = 0
  var j = 0
  var emphRange: Range<Int>?

  while i < labelGrams.count && j < patternGrams.count {
    if labelGrams[i] == patternGrams[j] {
      if let range = emphRange {
        emphRange = range.lowerBound..<ii + labelGrams[i].length
      }
      else {
        emphRange = ii..<ii + labelGrams[i].length
      }
      j += 1
    }
    else if let range = emphRange {
      attrString.addAttributes(emphAttrs, range: NSRange(range))
      emphRange = nil
    }

    ii += labelGrams[i].first!.length
    i += 1
  }

  if let range = emphRange {
    attrString.addAttributes(emphAttrs, range: NSRange(range))
  }

  return attrString
}
