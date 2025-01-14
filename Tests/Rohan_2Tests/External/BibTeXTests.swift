// Copyright 2024 Lie Yan

@testable import Rohan_2
import Foundation
import Testing

@Suite
struct BibTeXTests {
    @Test func testCitekey() async throws {
        #expect(BibTeX.Citekey.validate(string: "abc1024"))
        #expect(BibTeX.Citekey.validate(string: "abc-1024"))
        #expect(BibTeX.Citekey.validate(string: "abc_1024"))
        #expect(BibTeX.Citekey.validate(string: "abc:1024"))
        #expect(BibTeX.Citekey.validate(string: ":1024:abc"))

        #expect(!BibTeX.Citekey.validate(string: "abc#1024"))
    }
}
