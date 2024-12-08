// Copyright 2024 Lie Yan

import Foundation

enum CommandName: Equatable, Hashable {
    case keyArrowDown
    case keyArrowLeft
    case keyArrowRight
    case keyArrowUp
    case keyBackspace
    case keyDelete
    case keyEnter
    case keyEscape
    case keySpace
    case keyTab
    //
    case deleteWord
    case deleteLine
    case insertLikeBreak
    case insertParagraph
    case insertText
    case removeText
    //
    case copy
    case cut
    case paste
    //
    case indentContent
    case outdentContent
}
