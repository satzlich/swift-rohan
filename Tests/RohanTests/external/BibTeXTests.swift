// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite
struct BibTeXTests {
    @Test func testCitekey() async throws {
        #expect(BibTeX.Citekey.validate(text: "abc1024"))
        #expect(BibTeX.Citekey.validate(text: "abc-1024"))
        #expect(BibTeX.Citekey.validate(text: "abc_1024"))
        #expect(BibTeX.Citekey.validate(text: "abc:1024"))
        #expect(BibTeX.Citekey.validate(text: ":1024:abc"))

        #expect(!BibTeX.Citekey.validate(text: "abc#1024"))
    }
}
