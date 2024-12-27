// Copyright 2024 Lie Yan

struct GridSelection: SelectionProtocol {
    let grid: NodeKey
    let anchorCell: NodeKey
    let focusCell: NodeKey
}
