import HealthKit

class WorkoutHelper {
    private let healthStore = HKHealthStore()
    
    func getWorkoutMessage(completion: @escaping (String?, Error?) -> Void) {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -120, to: endDate)!
            
            let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, duration: 0)
            let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: compound, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
                guard let workouts = results as? [HKWorkout], error == nil else {
                    completion(nil, error)
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                var workoutMessages: [String] = []
                
                for workout in workouts {
                    dispatchGroup.enter()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
                    
                    let durationFormatter = DateComponentsFormatter()
                    durationFormatter.unitsStyle = .full
                    
                    let startDateString = dateFormatter.string(from: workout.startDate)
                    let duration = workout.duration
                    let durationString = durationFormatter.string(from: duration) ?? ""
                    
                    var message = "Workout on \(startDateString)\n"
                    message += "Type: \(self.getWorkoutActivityTypeName(workout.workoutActivityType))\n"
                    message += "Duration: \(durationString)\n"
                    
                    if let totalDistance = workout.totalDistance {
                        let distanceInMeters = totalDistance.doubleValue(for: HKUnit.meter())
                        let distanceInKilometers = distanceInMeters / 1000
                        message += "Distance: \(String(format: "%.2f", distanceInKilometers)) km\n"
                    }
                    
                    self.getHeartRateStatistics(for: workout) { (statistics) in
                        message += statistics
                        
                        self.getTimeInZone2(for: workout) { (timeInZone2) in
                            message += "Time in Zone 2: \(timeInZone2) minutes\n"
                            
                            workoutMessages.append(message)
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    let formattedMessage = "Here's a summary of your workouts for the last 2 weeks:\n\n" + workoutMessages.joined(separator: "\n\n")
                    
                    print("formmated message: \n\n\n", formattedMessage)
                    
                    completion(formattedMessage, nil)
                }
            }
            
            healthStore.execute(query)
        }

        private func getHeartRateStatistics(for workout: HKWorkout, completion: @escaping (String) -> Void) {
            var statistics = "Heart Rate Statistics:\n"
            
            guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
                completion(statistics)
                return
            }
            
            let heartRateQuery = HKQuery.predicateForObjects(from: workout)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            let query = HKSampleQuery(sampleType: quantityType, predicate: heartRateQuery, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
                guard let samples = results as? [HKQuantitySample], error == nil else {
                    completion(statistics)
                    return
                }
                
                var minHeartRate = Int.max
                var maxHeartRate = 0
                var totalHeartRate = 0
                
                for sample in samples {
                    let heartRateValue = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
                    minHeartRate = min(minHeartRate, heartRateValue)
                    maxHeartRate = max(maxHeartRate, heartRateValue)
                    totalHeartRate += heartRateValue
                }
                
                let averageHeartRate = samples.isEmpty ? 0 : totalHeartRate / samples.count
                
                statistics += "Average Heart Rate: \(averageHeartRate) bpm\n"
                statistics += "Minimum Heart Rate: \(minHeartRate) bpm\n"
                statistics += "Maximum Heart Rate: \(maxHeartRate) bpm\n"
                
                completion(statistics)
            }
            
            healthStore.execute(query)
        }

        private func getTimeInZone2(for workout: HKWorkout, completion: @escaping (Int) -> Void) {
            var timeInZone2 = 0
            
            guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
                completion(timeInZone2)
                return
            }
            
            let heartRateQuery = HKQuery.predicateForObjects(from: workout)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            let query = HKSampleQuery(sampleType: quantityType, predicate: heartRateQuery, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, results, error) in
                guard let samples = results as? [HKQuantitySample], error == nil else {
                    completion(timeInZone2)
                    return
                }
                
                for sample in samples {
                    let heartRateValue = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
                    if heartRateValue >= 120 && heartRateValue <= 140 {
                        timeInZone2 += 1
                    }
                }
                
                completion(timeInZone2)
            }
            
            healthStore.execute(query)
        }
    
    private func getWorkoutActivityTypeName(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        case .swimming:
            return "Swimming"
        case .hiking:
            return "Hiking"
        case .crossTraining:
            return "Cross Training"
        case .elliptical:
            return "Elliptical"
        case .functionalStrengthTraining:
            return "Functional Strength Training"
        case .golf:
            return "Golf"
        case .mixedCardio:
            return "Mixed Cardio"
        case .paddleSports:
            return "Paddle Sports"
        case .play:
            return "Play"
        case .preparationAndRecovery:
            return "Preparation and Recovery"
        case .skatingSports:
            return "Skating Sports"
        case .snowSports:
            return "Snow Sports"
        case .stairs:
            return "Stairs"
        case .surfingSports:
            return "Surfing Sports"
        case .yoga:
            return "Yoga"
        case .barre:
            return "Barre"
        case .coreTraining:
            return "Core Training"
        case .crossCountrySkiing:
            return "Cross Country Skiing"
        case .downhillSkiing:
            return "Downhill Skiing"
        case .flexibility:
            return "Flexibility"
        case .highIntensityIntervalTraining:
            return "High Intensity Interval Training"
        case .jumpRope:
            return "Jump Rope"
        case .kickboxing:
            return "Kickboxing"
        case .pilates:
            return "Pilates"
        case .snowboarding:
            return "Snowboarding"
        case .soccer:
            return "Soccer"
        case .softball:
            return "Softball"
        case .squash:
            return "Squash"
        case .stairClimbing:
            return "Stair Climbing"
        case .stepTraining:
            return "Step Training"
        case .wheelchairWalkPace:
            return "Wheelchair Walk Pace"
        case .wheelchairRunPace:
            return "Wheelchair Run Pace"
        case .wrestling:
            return "Wrestling"
        default:
            return "Other"
        }
    }
}
