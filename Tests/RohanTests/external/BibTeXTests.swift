// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite
struct BibTeXTests {
    @Test func testCitekey() async throws {
        #expect(BibTeX.Citekey.validateText("abc1024"))
        #expect(BibTeX.Citekey.validateText("abc-1024"))
        #expect(BibTeX.Citekey.validateText("abc_1024"))
        #expect(BibTeX.Citekey.validateText("abc:1024"))
        #expect(BibTeX.Citekey.validateText(":1024:abc"))

        #expect(!BibTeX.Citekey.validateText("abc#1024"))
    }
}
