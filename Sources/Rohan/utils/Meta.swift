// Copyright 2024 Lie Yan

import Foundation

/**
 Meta Programming Library
 */
enum Meta {
    // foldl

    static func foldl<T0, T1>(
        _ acc: T0, _ t: T1
    ) -> (T0, T1) {
        (acc, t)
    }

    static func foldl<T0, T1, T2>(
        _ acc: (T0, T1), _ t: T2
    ) -> (T0, T1, T2) {
        (acc.0, acc.1, t)
    }

    static func foldl<T0, T1, T2, T3>(
        _ acc: (T0, T1, T2), _ t: T3
    ) -> (T0, T1, T2, T3) {
        (acc.0, acc.1, acc.2, t)
    }

    static func foldl<T0, T1, T2, T3, T4>(
        _ acc: (T0, T1, T2, T3), _ t: T4
    ) -> (T0, T1, T2, T3, T4) {
        (acc.0, acc.1, acc.2, acc.3, t)
    }

    static func foldl<T0, T1, T2, T3, T4, T5>(
        _ acc: (T0, T1, T2, T3, T4), _ t: T5
    ) -> (T0, T1, T2, T3, T4, T5) {
        (acc.0, acc.1, acc.2, acc.3, acc.4, t)
    }

    static func foldl<T0, T1, T2, T3, T4, T5, T6>(
        _ acc: (T0, T1, T2, T3, T4, T5), _ t: T6
    ) -> (T0, T1, T2, T3, T4, T5, T6) {
        (acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, t)
    }

    static func foldl<T0, T1, T2, T3, T4, T5, T6, T7>(
        _ acc: (T0, T1, T2, T3, T4, T5, T6), _ t: T7
    ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
        (acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, acc.6, t)
    }

    static func foldl<T0, T1, T2, T3, T4, T5, T6, T7, T8>(
        _ acc: (T0, T1, T2, T3, T4, T5, T6, T7), _ t: T8
    ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
        (acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, acc.6, acc.7, t)
    }

    static func foldl<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>(
        _ acc: (T0, T1, T2, T3, T4, T5, T6, T7, T8), _ t: T9
    ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
        (acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, acc.6, acc.7, acc.8, t)
    }

    /// foldr
    static func foldr<T0, T1>(
        _ t: T0, _ acc: T1
    ) -> (T0, T1) {
        (t, acc)
    }

    static func foldr<T0, T1, T2>(
        _ t: T0, _ acc: (T1, T2)
    ) -> (T0, T1, T2) {
        (t, acc.0, acc.1)
    }

    static func foldr<T0, T1, T2, T3>(
        _ t: T0, _ acc: (T1, T2, T3)
    ) -> (T0, T1, T2, T3) {
        (t, acc.0, acc.1, acc.2)
    }

    static func foldr<T0, T1, T2, T3, T4>(
        _ t: T0, _ acc: (T1, T2, T3, T4)
    ) -> (T0, T1, T2, T3, T4) {
        (t, acc.0, acc.1, acc.2, acc.3)
    }

    static func foldr<T0, T1, T2, T3, T4, T5>(
        _ t: T0, _ acc: (T1, T2, T3, T4, T5)
    ) -> (T0, T1, T2, T3, T4, T5) {
        (t, acc.0, acc.1, acc.2, acc.3, acc.4)
    }

    static func foldr<T0, T1, T2, T3, T4, T5, T6>(
        _ t: T0, _ acc: (T1, T2, T3, T4, T5, T6)
    ) -> (T0, T1, T2, T3, T4, T5, T6) {
        (t, acc.0, acc.1, acc.2, acc.3, acc.4, acc.5)
    }

    static func foldr<T0, T1, T2, T3, T4, T5, T6, T7>(
        _ t: T0, _ acc: (T1, T2, T3, T4, T5, T6, T7)
    ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
        (t, acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, acc.6)
    }

    static func foldr<T0, T1, T2, T3, T4, T5, T6, T7, T8>(
        _ t: T0, _ acc: (T1, T2, T3, T4, T5, T6, T7, T8)
    ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
        (t, acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, acc.6, acc.7)
    }

    static func foldr<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>(
        _ t: T0, _ acc: (T1, T2, T3, T4, T5, T6, T7, T8, T9)
    ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
        (t, acc.0, acc.1, acc.2, acc.3, acc.4, acc.5, acc.6, acc.7, acc.8)
    }
}
