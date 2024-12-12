// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite
struct BibTeXTests {
    @Test func testCitekey() async throws {
        #expect(BibTeX.Citekey("abc1024") != nil)
        #expect(BibTeX.Citekey("abc-1024") != nil)
        #expect(BibTeX.Citekey("abc_1024") != nil)
        #expect(BibTeX.Citekey("abc:1024") != nil)
        #expect(BibTeX.Citekey(":1024:abc") != nil)

        #expect(BibTeX.Citekey("abc#1024") == nil)
    }
}
