import CoreLocation
import HealthKit

class LocationHealthService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let healthStore = HKHealthStore()
    private let geofenceRadius = 100.0 // meters
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startMonitoring() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Monitor relevant locations
        let locations = [
            "gym": CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            "home": CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
        ]
        
        for (identifier, coordinate) in locations {
            let region = CLCircularRegion(
                center: coordinate,
                radius: geofenceRadius,
                identifier: identifier
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleRegionEvent(region: region, eventType: .entry)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleRegionEvent(region: region, eventType: .exit)
    }
    
    private func handleRegionEvent(region: CLRegion, eventType: RegionEventType) {
        // Process location-based health insights
        switch region.identifier {
        case "gym":
            if eventType == .entry {
                // Start workout tracking
                startWorkoutTracking()
            } else {
                // End workout tracking
                endWorkoutTracking()
            }
        case "home":
            if eventType == .entry {
                // Start sleep tracking
                startSleepTracking()
            }
        default:
            break
        }
    }
} 