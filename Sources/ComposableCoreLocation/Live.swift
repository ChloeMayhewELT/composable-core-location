import Asynchrone
import Combine
import ComposableArchitecture
import CoreLocation

extension LocationManager {
  /// The live implementation of the `LocationManager` interface. This implementation is capable of
  /// creating real `CLLocationManager` instances, listening to its delegate methods, and invoking
  /// its methods. You will typically use this when building for the simulator or device:
  ///
  /// ```swift
  /// let store = Store(
  ///   initialState: AppState(),
  ///   reducer: appReducer,
  ///   environment: AppEnvironment(
  ///     locationManager: LocationManager.live
  ///   )
  /// )
  /// ```
  public static var live: Self {
    let manager = CLLocationManager()

    let delegate = AsyncStream<Action> { continuation in
      let delegate = LocationManagerDelegate(continuation)
      manager.delegate = delegate
    }
      .shared()
      .eraseToStream()

    return Self(
      accuracyAuthorization: {
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return AccuracyAuthorization(manager.accuracyAuthorization)
          }
        #endif
        return nil
      },
      authorizationStatus: {
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return manager.authorizationStatus
          }
        #endif
        return CLLocationManager.authorizationStatus()
      },
      delegate: { delegate },
      dismissHeadingCalibrationDisplay: {
        Task {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.dismissHeadingCalibrationDisplay()
          #endif
        }
      },
      heading: {
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return manager.heading.map(Heading.init(rawValue:))
        #else
          return nil
        #endif
      },
      headingAvailable: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.headingAvailable()
        #else
          return false
        #endif
      },
      isRangingAvailable: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.isRangingAvailable()
        #else
          return false
        #endif
      },
      location: { manager.location.map(Location.init(rawValue:)) },
      locationServicesEnabled: CLLocationManager.locationServicesEnabled,
      maximumRegionMonitoringDistance: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return manager.maximumRegionMonitoringDistance
        #else
          return CLLocationDistanceMax
        #endif
      },
      monitoredRegions: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return Set(manager.monitoredRegions.map(Region.init(rawValue:)))
        #else
          return []
        #endif
      },
      requestAlwaysAuthorization: {
        Task {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.requestAlwaysAuthorization()
          #endif
        }
      },
      requestLocation: {
        Task { manager.requestLocation() }
      },
      requestWhenInUseAuthorization: {
        Task {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.requestWhenInUseAuthorization()
          #endif
        }
      },
      requestTemporaryFullAccuracyAuthorization: { purposeKey in
        try await withCheckedThrowingContinuation { continuation in
          #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
            if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
              manager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: purposeKey
              ) { error in
                if let error {
                  continuation.resume(throwing: error)
                } else {
                  continuation.resume()
                }
              }
            } else {
              continuation.resume()
            }
          #else
            continuation.resume()
          #endif
        }
      },
      set: { properties in
        Task {
          #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
            if let activityType = properties.activityType {
              manager.activityType = activityType
            }
            if let allowsBackgroundLocationUpdates = properties.allowsBackgroundLocationUpdates {
              manager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
            }
          #endif
          #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
            if let desiredAccuracy = properties.desiredAccuracy {
              manager.desiredAccuracy = desiredAccuracy
            }
            if let distanceFilter = properties.distanceFilter {
              manager.distanceFilter = distanceFilter
            }
          #endif
          #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
            if let headingFilter = properties.headingFilter {
              manager.headingFilter = headingFilter
            }
            if let headingOrientation = properties.headingOrientation {
              manager.headingOrientation = headingOrientation
            }
          #endif
          #if os(iOS) || targetEnvironment(macCatalyst)
            if let pausesLocationUpdatesAutomatically = properties
              .pausesLocationUpdatesAutomatically
            {
              manager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
            }
            if let showsBackgroundLocationIndicator = properties.showsBackgroundLocationIndicator {
              manager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
            }
          #endif
        }
      },
      significantLocationChangeMonitoringAvailable: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.significantLocationChangeMonitoringAvailable()
        #else
          return false
        #endif
      },
      startMonitoringForRegion: { region in
        Task {
          #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
            manager.startMonitoring(for: region.rawValue!)
          #endif
        }
      },
      startMonitoringSignificantLocationChanges: {
        Task {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.startMonitoringSignificantLocationChanges()
          #endif
        }
      },
      startMonitoringVisits: {
        Task {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.startMonitoringVisits()
          #endif
        }
      },
      startUpdatingHeading: {
        Task {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.startUpdatingHeading()
          #endif
        }
      },
      startUpdatingLocation: {
        Task {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.startUpdatingLocation()
          #endif
        }
      },
      stopMonitoringForRegion: { region in
        Task {
          #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
            manager.stopMonitoring(for: region.rawValue!)
          #endif
        }
      },
      stopMonitoringSignificantLocationChanges: {
        Task {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.stopMonitoringSignificantLocationChanges()
          #endif
        }
      },
      stopMonitoringVisits: {
        Task {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.stopMonitoringVisits()
          #endif
        }
      },
      stopUpdatingHeading: {
        Task {
          #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.stopUpdatingHeading()
          #endif
        }
      },
      stopUpdatingLocation: {
        Task {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.stopUpdatingLocation()
          #endif
        }
      }
    )
  }
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
  let subscriber: AsyncStream<LocationManager.Action>.Continuation

  init(_ subscriber: AsyncStream<LocationManager.Action>.Continuation) {
    self.subscriber = subscriber
  }

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    self.subscriber.yield(.didChangeAuthorization(status))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.subscriber.yield(.didFailWithError(LocationManager.Error(error)))
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.subscriber.yield(.didUpdateLocations(locations.map(Location.init(rawValue:))))
  }

  #if os(macOS)
    func locationManager(
      _ manager: CLLocationManager, didUpdateTo newLocation: CLLocation,
      from oldLocation: CLLocation
    ) {
      self.subscriber.yield(
        .didUpdateTo(
          newLocation: Location(rawValue: newLocation),
          oldLocation: Location(rawValue: oldLocation)
        )
      )
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?
    ) {
      self.subscriber.yield(
        .didFinishDeferredUpdatesWithError(error.map(LocationManager.Error.init))
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
      self.subscriber.yield(.didPauseLocationUpdates)
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
      self.subscriber.yield(.didResumeLocationUpdates)
    }
  #endif

  #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
      self.subscriber.yield(.didUpdateHeading(newHeading: Heading(rawValue: newHeading)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      self.subscriber.yield(.didEnterRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
      self.subscriber.yield(.didExitRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion
    ) {
      self.subscriber.yield(.didDetermineState(state, region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error
    ) {
      self.subscriber.yield(
        .monitoringDidFail(
          region: region.map(Region.init(rawValue:)), error: LocationManager.Error(error)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
      self.subscriber.yield(.didStartMonitoring(region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didRange beacons: [CLBeacon],
      satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
      self.subscriber.yield(
        .didRangeBeacons(
          beacons.map(Beacon.init(rawValue:)), satisfyingConstraint: beaconConstraint
        )
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint,
      error: Error
    ) {
      self.subscriber.yield(
        .didFailRanging(beaconConstraint: beaconConstraint, error: LocationManager.Error(error))
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
      self.subscriber.yield(.didVisit(Visit(visit: visit)))
    }
  #endif
}
