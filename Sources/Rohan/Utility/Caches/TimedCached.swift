// Copyright 2024-2025 Lie Yan

import Foundation

final class TimedCache<Key: Hashable, Value> {
  private var cacheDictionary: [Key: Value] = [:]
  private var expirationDates: [Key: Date] = [:]
  private let expirationInterval: TimeInterval
  private let cleanupInterval: TimeInterval
  private let queue =
    DispatchQueue(label: "net.satzlich.timedCacheQueue", attributes: .concurrent)
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
      self.updateExpiration(forKey: key)
    }
  }

  /// Get a value from the cache if it exists and hasn't expired
  /// Also updates the expiration time for the accessed key
  func value(forKey key: Key) -> Value? {
    return queue.sync {
      // Check if the item exists
      guard let value = cacheDictionary[key] else {
        return nil
      }

      // Check if expired
      if let expirationDate = expirationDates[key], expirationDate > Date() {
        // Update expiration since we're accessing it
        self.updateExpiration(forKey: key)
        return value
      }

      // If expired, remove it
      cacheDictionary.removeValue(forKey: key)
      expirationDates.removeValue(forKey: key)
      return nil
    }
  }

  /// Update expiration time for a key
  private func updateExpiration(forKey key: Key) {
    expirationDates[key] = Date().addingTimeInterval(expirationInterval)
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
