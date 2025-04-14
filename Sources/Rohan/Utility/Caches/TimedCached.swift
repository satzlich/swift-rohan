// Copyright 2024-2025 Lie Yan

import Foundation

final class TimedCache<Key: Hashable, Value> {
  private var cacheDictionary: [Key: Value] = [:]
  private var expirationDates: [Key: Date] = [:]
  private let expirationInterval: TimeInterval
  private let cleanupInterval: TimeInterval
  private let queue = DispatchQueue(label: "timedCacheQueue", attributes: .concurrent)
  private var cleanupTimer: DispatchSourceTimer?

  /// Initialize the cache
  /// - Parameters:
  ///   - expirationInterval: Time in seconds after which entries expire
  ///   - cleanupInterval: Time in seconds between automatic cleanup checks (optional)
  init(expirationInterval: TimeInterval, cleanupInterval: TimeInterval? = nil) {
    self.expirationInterval = expirationInterval
    self.cleanupInterval = cleanupInterval ?? expirationInterval / 2

    // Setup periodic cleanup
    setupCleanupTimer()
  }

  deinit {
    cleanupTimer?.cancel()
  }

  private func setupCleanupTimer() {
    cleanupTimer = DispatchSource.makeTimerSource(queue: queue)
    cleanupTimer?.schedule(deadline: .now() + cleanupInterval, repeating: cleanupInterval)
    cleanupTimer?.setEventHandler { [weak self] in
      self?.cleanupExpiredItems()
    }
    cleanupTimer?.resume()
  }

  /// Add or update a value in the cache
  func setValue(_ value: Value, forKey key: Key) {
    queue.async(flags: .barrier) {
      self.cacheDictionary[key] = value
      self.expirationDates[key] = Date().addingTimeInterval(self.expirationInterval)
    }
  }

  /// Get a value from the cache if it exists and hasn't expired
  func value(forKey key: Key) -> Value? {
    queue.sync {
      // Check if the item exists and hasn't expired
      if let expirationDate = expirationDates[key],
        expirationDate > Date()
      {
        return cacheDictionary[key]
      }

      // If expired, remove it
      if expirationDates[key] != nil {
        cacheDictionary.removeValue(forKey: key)
        expirationDates.removeValue(forKey: key)
      }

      return nil
    }
  }

  /// Remove a value from the cache
  func removeValue(forKey key: Key) {
    queue.async(flags: .barrier) {
      self.cacheDictionary.removeValue(forKey: key)
      self.expirationDates.removeValue(forKey: key)
    }
  }

  /// Remove all values from the cache
  func removeAll() {
    queue.async(flags: .barrier) {
      self.cacheDictionary.removeAll()
      self.expirationDates.removeAll()
    }
  }

  /// Manually trigger cleanup of expired items
  func cleanupExpiredItems() {
    queue.async(flags: .barrier) {
      let now = Date()
      let expiredKeys = self.expirationDates.filter { $0.value <= now }.map { $0.key }

      for key in expiredKeys {
        self.cacheDictionary.removeValue(forKey: key)
        self.expirationDates.removeValue(forKey: key)
      }
    }
  }

  /// Current count of items in cache (including expired but not yet cleaned up)
  var count: Int {
    queue.sync {
      return cacheDictionary.count
    }
  }

  /// Current count of non-expired items in cache
  var validCount: Int {
    queue.sync {
      let now = Date()
      return expirationDates.filter { $0.value > now }.count
    }
  }
}
