// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

enum AtomType: Int, Codable {
  case hbox
  case vbox
  case glue
  case text
  case unknown
}

enum SerdeUtils {
  static let registeredAtoms: [AtomType: Atom.Type] = [
    .hbox: Box.self,
    .vbox: VBox.self,
    .glue: Glue.self,
    .text: TextAtom.self,
    .unknown: Unknown.self,
  ]

  static func decodeAtomArray(_ childrenContainer: inout UnkeyedDecodingContainer) throws -> [Atom]
  {
    var children = [Atom]()

    while !childrenContainer.isAtEnd {
      var containerCopy = childrenContainer
      let unprocessedContainer = try childrenContainer.nestedContainer(
        keyedBy: PartialCodingKeys.self)
      let type =
        try AtomType(rawValue: unprocessedContainer.decode(Int.self, forKey: .atomType))
        ?? .unknown
      let klass = registeredAtoms[type] ?? Unknown.self

      do {
        let decoder = try containerCopy.superDecoder()
        let decodedNode = try klass.init(from: decoder)
        children.append(decodedNode)
      }
      catch {
        print(error)
      }
    }
    return children
  }
}

struct SerdeAtomArray: Decodable {
  let atoms: [Atom]

  init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    atoms = try SerdeUtils.decodeAtomArray(&container)
  }
}

enum PartialCodingKeys: CodingKey {
  case atomType
}

class Atom: Codable {
  var atomType: AtomType { fatalError() }
  init() {}

  // MARK: - Serde
  enum CodingKeys: CodingKey {
    case atomType
  }

  public required init(from decoder: Decoder) throws {
  }

  open func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(atomType, forKey: .atomType)
  }
}

class Box: Atom {
  override var atomType: AtomType { .hbox }

  let children: [Atom]

  init(_ children: [Atom]) {
    self.children = children
    super.init()
  }

  // MARK: - Serde

  enum CodingKeys: CodingKey {
    case children
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var childrenContainer = try container.nestedUnkeyedContainer(forKey: .children)
    self.children = try SerdeUtils.decodeAtomArray(&childrenContainer)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(children, forKey: .children)
  }
}

final class VBox: Box {
  override var atomType: AtomType { .vbox }

  let baseline: Double

  init(_ baseline: Double, _ children: [Atom]) {
    self.baseline = baseline
    super.init(children)
  }

  // MARK: - Serde

  enum CodingKeys: CodingKey {
    case baseline
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    baseline = try container.decode(Double.self, forKey: .baseline)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(baseline, forKey: .baseline)
  }
}

final class Glue: Atom {
  override var atomType: AtomType { .glue }

  let width: Double

  init(width: Double) {
    self.width = width
    super.init()
  }

  // MARK: - Serde

  enum CodingKeys: CodingKey {
    case width
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    width = try container.decode(Double.self, forKey: .width)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(width, forKey: .width)
  }
}

final class TextAtom: Atom {
  override var atomType: AtomType { .text }

  let string: String

  init(_ string: String) {
    self.string = string
    super.init()
  }

  // MARK: - Serde

  enum CodingKeys: CodingKey {
    case string
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    string = try container.decode(String.self, forKey: .string)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(string, forKey: .string)
  }
}

final class Unknown: Atom {
  override var atomType: AtomType { .unknown }

  // MARK: - Serde

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
  }
}

struct SerdeTests {
  @Test
  static func testSerde() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let atoms: [Atom] = [
      Box([
        TextAtom("Hello, "),
        Glue(width: 10),
        TextAtom("world!"),
      ]),
      VBox(
        20,
        [
          TextAtom("Hello, "),
          Glue(width: 15),
          TextAtom("world!"),
        ]),
    ]

    let result: Data = try encoder.encode(atoms)

    print(String(data: result, encoding: .utf8)!)

    let restored: SerdeAtomArray =
      try decoder.decode(SerdeAtomArray.self, from: result)

    let result2: Data = try encoder.encode(restored.atoms)
    print("------------")
    print(String(data: result2, encoding: .utf8)!)
  }
}
