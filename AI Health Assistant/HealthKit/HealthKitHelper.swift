//import HealthKit
//
//class HealthKitHelper {
//    private let healthStore = HKHealthStore()
//    private let heartRateHelper = HeartRateHelper()
//    private let workoutHelper = WorkoutHelper()
//    
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            completion(false, nil)
//            return
//        }
//        
//        let typesToShare: Set<HKSampleType> = [
//            HKWorkoutType.workoutType(),
//            HKSeriesType.workoutRoute(),
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!
//        ]
//        
//        let typesToRead: Set<HKSampleType> = [
//            HKWorkoutType.workoutType(),
//            HKSeriesType.workoutRoute(),
//            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
//            
//            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
//            HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)!
//        ]
//        
//        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
//            completion(success, error)
//        }
//    }
//    
//    func getHealthData(completion: @escaping (String?, Error?) -> Void) {
//        let dispatchGroup = DispatchGroup()
//        var workoutMessage: String?
//        var heartRateMessage: String?
//        var workoutError: Error?
//        var heartRateError: Error?
//        
//        //        dispatchGroup.enter()
//        //        getHealthDataQuery { (message, error) in
//        //            workoutMessage = message
//        //            workoutError = error
//        //            dispatchGroup.leave()
//        //        }
//        
//        dispatchGroup.enter()
//        workoutHelper.getWorkoutMessage { (message, error) in
//            workoutMessage = message
//            workoutError = error
//            dispatchGroup.leave()
//        }
//        
//        dispatchGroup.enter()
//        heartRateHelper.getHeartRateData { (message, error) in
//            heartRateMessage = message
//            heartRateError = error
//            dispatchGroup.leave()
//        }
//        
//        dispatchGroup.notify(queue: .main) {
//            var formattedMessage = ""
//            
//            if let workoutMessage = workoutMessage {
//                formattedMessage += workoutMessage
//            } else if let workoutError = workoutError {
//                formattedMessage += "Error fetching workout data: \(workoutError.localizedDescription)"
//            } else {
//                formattedMessage += "No workout data available."
//            }
//            
//            formattedMessage += "\n\n"
//            
//            if let heartRateMessage = heartRateMessage {
//                formattedMessage += heartRateMessage
//            } else if let heartRateError = heartRateError {
//                formattedMessage += "Error fetching heart rate data: \(heartRateError.localizedDescription)"
//            } else {
//                formattedMessage += "No heart rate data available."
//            }
//            
//            let error = workoutError ?? heartRateError
//            completion(formattedMessage, error)
//        }
//    }
//    
//
//}
