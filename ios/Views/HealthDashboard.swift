import SwiftUI
import HealthKit
import CoreLocation

struct HealthDashboard: View {
    @StateObject private var viewModel = HealthDashboardViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // Dynamic Island Live Activity State
    @State private var isLiveActivityRunning = false
    
    // Health Metrics
    @State private var heartRate: Double = 0
    @State private var steps: Int = 0
    @State private var activeCalories: Double = 0
    @State private var distance: Double = 0
    @State private var oxygenLevel: Double = 0
    
    // UI States
    @State private var selectedTimeRange: TimeRange = .today
    @State private var selectedMetric: HealthMetric = .heartRate
    @State private var showingDetailView = false
    
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Live Health Status Card
                    LiveHealthStatusCard(
                        heartRate: heartRate,
                        steps: steps,
                        calories: activeCalories,
                        oxygenLevel: oxygenLevel
                    )
                    .frame(height: 200)
                    .padding(.horizontal)
                    
                    // Time Range Selector
                    TimeRangeSelector(
                        selectedRange: $selectedTimeRange,
                        ranges: TimeRange.allCases
                    )
                    .padding(.horizontal)
                    
                    // Metrics Grid
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(HealthMetric.allCases) { metric in
                            MetricCard(
                                metric: metric,
                                value: viewModel.getValue(for: metric),
                                trend: viewModel.getTrend(for: metric),
                                isSelected: selectedMetric == metric
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedMetric = metric
                                    showingDetailView = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Activity Rings
                    ActivityRingsView(
                        movePercentage: viewModel.movePercentage,
                        exercisePercentage: viewModel.exercisePercentage,
                        standPercentage: viewModel.standPercentage
                    )
                    .frame(height: 200)
                    .padding()
                    
                    // Health Insights
                    HealthInsightsView(insights: viewModel.healthInsights)
                        .padding()
                    
                    // Recommendations
                    RecommendationsView(recommendations: viewModel.recommendations)
                        .padding()
                }
            }
            .navigationTitle("Health Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refreshData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetailView) {
            MetricDetailView(metric: selectedMetric)
        }
        .onAppear {
            viewModel.startMonitoring()
            startLiveActivity()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
    
    private func startLiveActivity() {
        guard !isLiveActivityRunning else { return }
        
        let activityAttributes = HealthActivityAttributes(
            activityName: "Health Monitoring"
        )
        
        let initialContentState = HealthActivityAttributes.ContentState(
            heartRate: heartRate,
            steps: steps,
            activeCalories: activeCalories
        )
        
        do {
            let activity = try Activity.request(
                attributes: activityAttributes,
                contentState: initialContentState,
                pushType: nil
            )
            isLiveActivityRunning = true
        } catch {
            print("Error starting live activity: \(error)")
        }
    }
    
    // Add Dynamic Island Support
    private func configureDynamicIsland() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let attributes = HealthActivityAttributes(
                activityName: "Health Monitoring",
                startTime: Date()
            )
            
            let contentState = HealthActivityAttributes.ContentState(
                heartRate: heartRate,
                steps: steps,
                activeCalories: activeCalories,
                oxygenLevel: oxygenLevel,
                lastUpdated: Date()
            )
            
            do {
                let activity = try Activity.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: .token
                )
                isLiveActivityRunning = true
            } catch {
                print("Error starting live activity: \(error)")
            }
        }
    }
}

// Supporting Views
struct LiveHealthStatusCard: View {
    let heartRate: Double
    let steps: Int
    let calories: Double
    let oxygenLevel: Double
    
    var body: some View {
        VStack {
            HStack {
                MetricView(
                    icon: "heart.fill",
                    value: String(format: "%.0f", heartRate),
                    unit: "BPM",
                    color: .red
                )
                Divider()
                MetricView(
                    icon: "flame.fill",
                    value: String(format: "%.0f", calories),
                    unit: "CAL",
                    color: .orange
                )
            }
            Divider()
            HStack {
                MetricView(
                    icon: "figure.walk",
                    value: "\(steps)",
                    unit: "STEPS",
                    color: .green
                )
                Divider()
                MetricView(
                    icon: "lungs.fill",
                    value: String(format: "%.0f%%", oxygenLevel),
                    unit: "O₂",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct MetricView: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Enums and Models
enum TimeRange: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

enum HealthMetric: String, CaseIterable, Identifiable {
    case heartRate = "Heart Rate"
    case steps = "Steps"
    case calories = "Calories"
    case distance = "Distance"
    case sleep = "Sleep"
    case bloodOxygen = "Blood Oxygen"
    case workout = "Workouts"
    case mindfulness = "Mindfulness"
    
    var id: String { rawValue }
}

// View Model
class HealthDashboardViewModel: ObservableObject {
    @Published var movePercentage: Double = 0
    @Published var exercisePercentage: Double = 0
    @Published var standPercentage: Double = 0
    @Published var healthInsights: [HealthInsight] = []
    @Published var recommendations: [Recommendation] = []
    
    private let healthStore = HKHealthStore()
    private let locationManager = CLLocationManager()
    
    func startMonitoring() {
        requestAuthorization()
        startHealthKitUpdates()
        startLocationUpdates()
    }
    
    func stopMonitoring() {
        // Implementation
    }
    
    func refreshData() {
        // Implementation
    }
    
    func getValue(for metric: HealthMetric) -> Double {
        // Implementation
        return 0
    }
    
    func getTrend(for metric: HealthMetric) -> Trend {
        // Implementation
        return .stable
    }
    
    private func requestAuthorization() {
        // Implementation
    }
    
    private func startHealthKitUpdates() {
        // Implementation
    }
    
    private func startLocationUpdates() {
        // Implementation
    }
}

enum Trend {
    case up, down, stable
}

struct HealthInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: InsightType
}

enum InsightType {
    case positive, negative, neutral
}

struct Recommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let priority: Priority
}

enum Priority {
    case high, medium, low
} 