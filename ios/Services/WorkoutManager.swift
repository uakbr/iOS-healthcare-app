import HealthKit
import CoreMotion

class WorkoutManager: NSObject, ObservableObject {
    @Published var isWorkoutInProgress = false
    @Published var currentWorkout: HKWorkout?
    @Published var workoutMetrics: WorkoutMetrics
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    struct WorkoutMetrics {
        var heartRate: Double = 0
        var activeCalories: Double = 0
        var distance: Double = 0
        var pace: Double = 0
        var cadence: Double = 0
        var elevation: Double = 0
    }
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            builder = workoutSession?.associatedWorkoutBuilder()
            
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            workoutSession?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in
                if success {
                    self.isWorkoutInProgress = true
                }
            }
        } catch {
            print("Error starting workout: \(error)")
        }
    }
    
    func endWorkout() {
        workoutSession?.end()
        builder?.endCollection(withEnd: Date()) { success, error in
            if success {
                self.builder?.finishWorkout { workout, error in
                    if let workout = workout {
                        self.currentWorkout = workout
                        self.saveWorkout(workout)
                    }
                }
            }
        }
    }
} 