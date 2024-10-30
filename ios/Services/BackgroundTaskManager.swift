import BackgroundTasks
import HealthKit
import CoreLocation
import CoreMotion

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let healthStore = HKHealthStore()
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    // Task identifiers
    private let healthUpdateTaskId = "com.healthcare.healthUpdate"
    private let locationUpdateTaskId = "com.healthcare.locationUpdate"
    private let dataUploadTaskId = "com.healthcare.dataUpload"
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: healthUpdateTaskId,
            using: nil
        ) { task in
            self.handleHealthUpdate(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: locationUpdateTaskId,
            using: nil
        ) { task in
            self.handleLocationUpdate(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: dataUploadTaskId,
            using: nil
        ) { task in
            self.handleDataUpload(task: task as! BGProcessingTask)
        }
    }
    
    private func handleHealthUpdate(task: BGAppRefreshTask) {
        scheduleNextHealthUpdate()
        
        let healthQuery = HKAnchoredObjectQuery(
            type: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { query, samples, deletedObjects, anchor, error in
            // Process new health data
            if let samples = samples {
                self.processHealthSamples(samples)
            }
            task.setTaskCompleted(success: true)
        }
        
        healthStore.execute(healthQuery)
    }
    
    private func handleLocationUpdate(task: BGAppRefreshTask) {
        scheduleNextLocationUpdate()
        
        locationManager.startUpdatingLocation()
        // Process location updates
        task.setTaskCompleted(success: true)
    }
    
    private func handleDataUpload(task: BGProcessingTask) {
        scheduleNextDataUpload()
        
        // Upload collected data to server
        task.setTaskCompleted(success: true)
    }
} 