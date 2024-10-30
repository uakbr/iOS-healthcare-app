import HealthKit
import CoreLocation
import CoreMotion
import BackgroundTasks

class BackgroundHealthService {
    private let healthStore = HKHealthStore()
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    // Background task identifiers
    private let backgroundTaskIdentifier = "com.healthcare.backgroundHealth"
    private let backgroundLocationIdentifier = "com.healthcare.backgroundLocation"
    
    func setupBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundHealthUpdate(task: task as! BGAppRefreshTask)
        }
        
        // Request necessary permissions
        requestPermissions()
    }
    
    private func requestPermissions() {
        // Health data permissions
        let healthTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: healthTypes) { _, _ in }
        
        // Location permissions
        locationManager.requestAlwaysAuthorization()
        
        // Motion permissions
        motionManager.startActivityUpdates(to: .main) { _ in }
    }
    
    func startBackgroundMonitoring() {
        // Start location updates
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
        // Start motion updates
        startMotionUpdates()
        
        // Schedule background health data collection
        scheduleBackgroundHealthUpdate()
    }
    
    private func handleBackgroundHealthUpdate(task: BGAppRefreshTask) {
        // Collect and sync health data
        collectHealthData { [weak self] data in
            // Upload to backend
            self?.syncHealthData(data)
            
            // Schedule next update
            self?.scheduleBackgroundHealthUpdate()
            task.setTaskCompleted(success: true)
        }
    }
} 