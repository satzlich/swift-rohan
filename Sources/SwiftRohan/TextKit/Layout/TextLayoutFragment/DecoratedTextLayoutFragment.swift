import AppKit

final class DecoratedTextLayoutFragment: NSTextLayoutFragment {

  override func draw(at point: CGPoint, in context: CGContext) {
    super.draw(at: point, in: context)

    for decorator in decorators {
      decorator.draw(at: point, in: context, for: self)
    }
  }

  // MARK: - State

  private let decorators: Array<FragmentDecorator>

  init(
    textElement: NSTextElement, range rangeInElement: NSTextRange?,
    decorators: Array<FragmentDecorator> = []
  ) {
    self.decorators = decorators
    super.init(textElement: textElement, range: rangeInElement)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
