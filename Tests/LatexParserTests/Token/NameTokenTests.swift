import LatexParser
import Testing

struct NameTokenTests {
  @Test
  func coverage() {
    _ = NameToken.validate(string: "test")
    _ = NameToken("test*")
  }
}
