// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct CompletionProviderTests {

  var mathContainer: ContainerProperty {
    ContainerProperty(
      nodeType: .equation, parentType: .paragraph, containerMode: .math,
      containerType: .inline, containerTag: nil)
  }

  @Test
  func coverage() {
    let completionProvider = CompletionProvider()
    completionProvider.addItems(CommandRecords.allCases)

    let maxResults = 1024

    // n-gram
    _ = completionProvider.getCompletions("riar", mathContainer, maxResults)
    // full match
    _ = completionProvider.getCompletions("dag", mathContainer, maxResults)
    _ = completionProvider.getCompletions("ddager", mathContainer, maxResults)
    // full match ignore case
    _ = completionProvider.getCompletions("ALPHA", mathContainer, maxResults)

    // empty input
    _ = completionProvider.getCompletions("", mathContainer, maxResults)

    // cache hit for single character
    do {
      _ = completionProvider.getCompletions("l", mathContainer, maxResults)
      _ = completionProvider.getCompletions("lf", mathContainer, maxResults)
      _ = completionProvider.getCompletions("lfrw", mathContainer, maxResults)
    }
  }

  @Test
  func refineResults() {
    let completionProvider = CompletionProvider()
    completionProvider.addItems(CommandRecords.allCases)

    let maxResults = 1024

    // equal -> prefix
    do {
      _ = completionProvider.getCompletions("dag", mathContainer, maxResults)
      _ = completionProvider.getCompletions("dagG", mathContainer, maxResults)

      _ = completionProvider.getCompletions("ddag", mathContainer, maxResults)
      _ = completionProvider.getCompletions("ddagGer", mathContainer, maxResults)
    }
    // equal lowercase -> equal lowercase
    do {
      _ = completionProvider.getCompletions("DAG", mathContainer, maxResults)
      _ = completionProvider.getCompletions("DAGGER", mathContainer, maxResults)
    }
    // equal lowercase -> equal lowercase
    do {
      _ = completionProvider.getCompletions("DAG", mathContainer, maxResults)
      _ = completionProvider.getCompletions("DAGGER", mathContainer, maxResults)
    }
    // equal lowercase -> prefix lowercase
    do {
      _ = completionProvider.getCompletions("DAG", mathContainer, maxResults)
      _ = completionProvider.getCompletions("DAGGE", mathContainer, maxResults)
    }

    // prefix + subseq
    do {
      _ = completionProvider.getCompletions("dag", mathContainer, maxResults)
      _ = completionProvider.getCompletions("dage", mathContainer, maxResults)
      _ = completionProvider.getCompletions("dager", mathContainer, maxResults)
      _ = completionProvider.getCompletions("dagerZ", mathContainer, maxResults)
    }

    // n-gram plus
    do {
      _ = completionProvider.getCompletions("riar", mathContainer, maxResults)
      _ = completionProvider.getCompletions("riarg", mathContainer, maxResults)
      _ = completionProvider.getCompletions("riargZ", mathContainer, maxResults)
    }

    // subseq -> subseq
    do {
      _ = completionProvider.getCompletions("fg", mathContainer, maxResults, true)
      _ = completionProvider.getCompletions("fgtq", mathContainer, maxResults, true)
    }

    let smallResults = 1

    do {
      _ = completionProvider.getCompletions("rig", mathContainer, smallResults)
      _ = completionProvider.getCompletions("righ", mathContainer, smallResults)
    }
  }
}
