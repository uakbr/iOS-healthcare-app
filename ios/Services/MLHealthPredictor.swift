import CoreML
import CreateML
import HealthKit

class MLHealthPredictor {
    private var healthModel: MLModel?
    private let healthStore = HKHealthStore()
    
    func trainModel(with healthData: [HealthDataPoint]) {
        let trainingData = prepareTrainingData(from: healthData)
        
        do {
            let parameters = MLBoostedTreeRegressor.ModelParameters(
                maxDepth: 4,
                minLossReduction: 0.0,
                minDataPointsInNode: 10,
                maxIterations: 100
            )
            
            let regressor = try MLBoostedTreeRegressor(
                trainingData: trainingData,
                targetColumn: "target",
                parameters: parameters
            )
            
            try regressor.write(to: getModelURL())
            healthModel = try MLModel(contentsOf: getModelURL())
            
        } catch {
            print("Error training model: \(error)")
        }
    }
    
    func predictHealthMetrics(currentData: HealthDataPoint) -> HealthPrediction {
        guard let model = healthModel else {
            return HealthPrediction(confidence: 0, prediction: 0)
        }
        
        do {
            let prediction = try model.prediction(from: prepareInput(from: currentData))
            return HealthPrediction(
                confidence: prediction.confidenceScore,
                prediction: prediction.value
            )
        } catch {
            print("Error making prediction: \(error)")
            return HealthPrediction(confidence: 0, prediction: 0)
        }
    }
    
    private func prepareTrainingData(from healthData: [HealthDataPoint]) -> MLDataTable {
        // Convert health data to training format
        let dataFrame = try? MLDataTable(dictionary: [
            "heartRate": healthData.map { $0.heartRate },
            "steps": healthData.map { $0.steps },
            "target": healthData.map { $0.target }
        ])
        
        return dataFrame ?? MLDataTable()
    }
} 