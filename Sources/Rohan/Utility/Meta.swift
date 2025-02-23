// Copyright 2024-2025 Lie Yan

import Foundation

/** Meta Programming Utilities */
enum Meta {
  // MARK: - rjoin

  static func rjoin<T0, T1>(
    _ tup: T0, _ t: T1
  ) -> (T0, T1) {
    (tup, t)
  }

  static func rjoin<T0, T1, T2>(
    _ tup: (T0, T1), _ t: T2
  ) -> (T0, T1, T2) {
    (tup.0, tup.1, t)
  }

  static func rjoin<T0, T1, T2, T3>(
    _ tup: (T0, T1, T2), _ t: T3
  ) -> (T0, T1, T2, T3) {
    (tup.0, tup.1, tup.2, t)
  }

  static func rjoin<T0, T1, T2, T3, T4>(
    _ tup: (T0, T1, T2, T3), _ t: T4
  ) -> (T0, T1, T2, T3, T4) {
    (tup.0, tup.1, tup.2, tup.3, t)
  }

  static func rjoin<T0, T1, T2, T3, T4, T5>(
    _ tup: (T0, T1, T2, T3, T4), _ t: T5
  ) -> (T0, T1, T2, T3, T4, T5) {
    (tup.0, tup.1, tup.2, tup.3, tup.4, t)
  }

  static func rjoin<T0, T1, T2, T3, T4, T5, T6>(
    _ tup: (T0, T1, T2, T3, T4, T5), _ t: T6
  ) -> (T0, T1, T2, T3, T4, T5, T6) {
    (tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, t)
  }

  static func rjoin<T0, T1, T2, T3, T4, T5, T6, T7>(
    _ tup: (T0, T1, T2, T3, T4, T5, T6), _ t: T7
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
    (tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, tup.6, t)
  }

  static func rjoin<T0, T1, T2, T3, T4, T5, T6, T7, T8>(
    _ tup: (T0, T1, T2, T3, T4, T5, T6, T7), _ t: T8
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
    (tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, tup.6, tup.7, t)
  }

  static func rjoin<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>(
    _ tup: (T0, T1, T2, T3, T4, T5, T6, T7, T8), _ t: T9
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    (tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, tup.6, tup.7, tup.8, t)
  }

  // MARK: - ljoin

  static func ljoin<T0, T1>(
    _ t: T0, _ tup: T1
  ) -> (T0, T1) {
    (t, tup)
  }

  static func ljoin<T0, T1, T2>(
    _ t: T0, _ tup: (T1, T2)
  ) -> (T0, T1, T2) {
    (t, tup.0, tup.1)
  }

  static func ljoin<T0, T1, T2, T3>(
    _ t: T0, _ tup: (T1, T2, T3)
  ) -> (T0, T1, T2, T3) {
    (t, tup.0, tup.1, tup.2)
  }

  static func ljoin<T0, T1, T2, T3, T4>(
    _ t: T0, _ tup: (T1, T2, T3, T4)
  ) -> (T0, T1, T2, T3, T4) {
    (t, tup.0, tup.1, tup.2, tup.3)
  }

  static func ljoin<T0, T1, T2, T3, T4, T5>(
    _ t: T0, _ tup: (T1, T2, T3, T4, T5)
  ) -> (T0, T1, T2, T3, T4, T5) {
    (t, tup.0, tup.1, tup.2, tup.3, tup.4)
  }

  static func ljoin<T0, T1, T2, T3, T4, T5, T6>(
    _ t: T0, _ tup: (T1, T2, T3, T4, T5, T6)
  ) -> (T0, T1, T2, T3, T4, T5, T6) {
    (t, tup.0, tup.1, tup.2, tup.3, tup.4, tup.5)
  }

  static func ljoin<T0, T1, T2, T3, T4, T5, T6, T7>(
    _ t: T0, _ tup: (T1, T2, T3, T4, T5, T6, T7)
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
    (t, tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, tup.6)
  }

  static func ljoin<T0, T1, T2, T3, T4, T5, T6, T7, T8>(
    _ t: T0, _ tup: (T1, T2, T3, T4, T5, T6, T7, T8)
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
    (t, tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, tup.6, tup.7)
  }

  static func ljoin<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>(
    _ t: T0, _ tup: (T1, T2, T3, T4, T5, T6, T7, T8, T9)
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    (t, tup.0, tup.1, tup.2, tup.3, tup.4, tup.5, tup.6, tup.7, tup.8)
  }

  // MARK: - Matches

  static func matches<T>(_ a: T, _ b0: T, _ b1: T) -> Bool where T: Equatable {
    a == b0 || a == b1
  }

  static func matches<T>(_ a: T, _ b0: T, _ b1: T, _ b2: T) -> Bool
  where T: Equatable {
    a == b0 || a == b1 || a == b2
  }

  static func matches<T>(_ a: T, _ b0: T, _ b1: T, _ b2: T, _ b3: T) -> Bool
  where T: Equatable {
    a == b0 || a == b1 || a == b2 || a == b3
  }
}
