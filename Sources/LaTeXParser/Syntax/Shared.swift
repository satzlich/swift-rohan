// Copyright 2024-2025 Lie Yan

public typealias EscapedCharSyntax = EscapedCharToken
extension EscapedCharSyntax: SyntaxProtocol {}

public typealias NewlineSyntax = NewlineToken
extension NewlineSyntax: SyntaxProtocol {}

public typealias SpaceSyntax = SpaceToken
extension SpaceSyntax: SyntaxProtocol {}

public typealias TextSyntax = TextToken
extension TextSyntax: SyntaxProtocol {}
