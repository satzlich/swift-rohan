import Foundation

final class TimedCache<Key: Hashable, Value> {
  private var cacheDictionary: Dictionary<Key, Value> = [:]
  private var expirationDates: Dictionary<Key, Date> = [:]
  private let expirationInterval: TimeInterval
  private let cleanupInterval: TimeInterval
  private let queue =
    DispatchQueue(label: "net.satzlich.timedCache", attributes: .concurrent)
  private var cleanupTimer: DispatchSourceTimer?

  /// Initialize the cache
  /// - Parameters:
  ///   - expirationInterval: Time in seconds after which entries expire
  ///   - cleanupInterval: Time in seconds between automatic cleanup checks (optional)
  init(_ expirationInterval: TimeInterval, _ cleanupInterval: TimeInterval? = nil) {
    self.expirationInterval = expirationInterval
    self.cleanupInterval = cleanupInterval ?? expirationInterval / 2

    // setup periodic cleanup
    _setupCleanupTimer()
  }

  deinit {
    cleanupTimer?.cancel()
  }

  private func _setupCleanupTimer() {
    let cleanupTimer = DispatchSource.makeTimerSource(queue: queue)
    self.cleanupTimer = cleanupTimer

    cleanupTimer.schedule(deadline: .now() + cleanupInterval, repeating: cleanupInterval)
    cleanupTimer.setEventHandler { [weak self] in
      self?.cleanupExpiredItems()
    }
    cleanupTimer.resume()
  }

  /// Add or update a value in the cache
  func setValue(_ value: Value, forKey key: Key) {
    queue.async(flags: .barrier) {
      self.cacheDictionary[key] = value
      self._updateExpiration(forKey: key)
    }
  }

  /// Get a value from the cache if it exists and hasn't expired
  /// Also updates the expiration time for the accessed key
  func value(forKey key: Key) -> Value? {
    return queue.sync {
      // check if the item exists
      guard let value = cacheDictionary[key]
      else { return nil }

      // check if expired
      if let expirationDate = expirationDates[key],
        expirationDate > Date()
      {
        // update expiration since we're accessing it
        self._updateExpiration(forKey: key)
        return value
      }

      // if expired, remove it
      cacheDictionary.removeValue(forKey: key)
      expirationDates.removeValue(forKey: key)
      return nil
    }
  }

  /// Update expiration time for a key
  private func _updateExpiration(forKey key: Key) {
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
  /// - Complexity: O(n)
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
  /// - Complexity: O(1)
  var count: Int {
    queue.sync {
      return cacheDictionary.count
    }
  }

  /// Current count of non-expired items in cache
  /// - Complexity: O(n)
  var validCount: Int {
    queue.sync {
      let now = Date()
      return expirationDates.filter { $0.value > now }.count
    }
  }
}
