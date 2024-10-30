import SwiftUI
import ActivityKit

struct HealthActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var heartRate: Double
        var steps: Int
        var activeCalories: Double
    }
    
    var activityName: String
}

class HealthActivityManager {
    static let shared = HealthActivityManager()
    private var activity: Activity<HealthActivityAttributes>?
    
    func startLiveActivity() {
        let attributes = HealthActivityAttributes(activityName: "Health Monitoring")
        let state = HealthActivityAttributes.ContentState(
            heartRate: 0,
            steps: 0,
            activeCalories: 0
        )
        
        activity = try? Activity.request(
            attributes: attributes,
            contentState: state,
            pushType: nil
        )
    }
    
    func updateLiveActivity(heartRate: Double, steps: Int, calories: Double) {
        let state = HealthActivityAttributes.ContentState(
            heartRate: heartRate,
            steps: steps,
            activeCalories: calories
        )
        
        Task {
            await activity?.update(using: state)
        }
    }
} 