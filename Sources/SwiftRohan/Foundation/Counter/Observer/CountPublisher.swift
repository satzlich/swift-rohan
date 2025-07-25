protocol CountPublisher {
  func registerObserver(_ observer: any CountObserver)
  func unregisterObserver(_ observer: any CountObserver)

  func notifyObservers(markAsDirty: Void)
}
