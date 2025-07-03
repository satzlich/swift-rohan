// Copyright 2024-2025 Lie Yan

///// Final count holder which is placed at the end of the linked list.
//final class FinalCountHolder: CountHolder {
//
//  final override var isDirty: Bool { previous?.isDirty ?? false }
//
//  override func propagateDirty() {
//    assert(next == nil)
//    /* no-op */
//  }
//
//  final override func value(forName name: CounterName) -> Int {
//    previous?.value(forName: name) ?? 0
//  }
//}
