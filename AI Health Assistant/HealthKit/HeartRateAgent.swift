import HealthKit
import CoreData
import UIKit

class HeartRateAgent: HealthKitAgent {
    private let healthStore = HKHealthStore()
    private let context = CoreDataStack.shared.context
    
    func fetchData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        let cachedDataStartDate = getCachedDataStartDate()
        
        if cachedDataStartDate <= startDate {
            print("All of the data we need is cached in core data")
            fetchFromCoreData(from: startDate, to: endDate, completion: completion)
        } else if cachedDataStartDate <= endDate {
            print("We have some cached data")
            let coreDataStartDate = max(startDate, cachedDataStartDate)
            
            // Attempt to pull what data we can from our cached CoreData. Find out what dates we don't have
            // cached that ChatGPT asked us for and pull those from HealthKit. Save any newly pulled dates
            // in CoreData.
            fetchFromCoreData(from: coreDataStartDate, to: endDate) { coreDataResult, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                self.fetchMissingHealthKitData(from: startDate, to: cachedDataStartDate) { healthKitResult, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    let combinedResult = (healthKitResult ?? "") + "\n" + (coreDataResult ?? "")
                    completion(combinedResult, nil)
                }
            }
        } else {
            print("We don't have any cached data. Pull it all")
            fetchMissingHealthKitData(from: startDate, to: endDate, completion: completion)
        }
    }
    
    private func getCachedDataStartDate() -> Date {
        let fetchRequest: NSFetchRequest<Metadata> = Metadata.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dataType == %@", "HeartRateData")
        
        do {
            let metadata = try context.fetch(fetchRequest).first
            return metadata?.timestamp ?? .distantFuture
        } catch {
            print("Failed to fetch metadata: \(error)")
            return .distantFuture
        }
    }
    
    private func fetchFromCoreData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        let fetchRequest: NSFetchRequest<HeartRateData> = HeartRateData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            let heartRateData = results.map { data in
                "Date: \(data.date ?? Date()), Average Resting Heart Rate: \(data.avgRestingHeartRate), Min Heart Rate: \(data.minHeartRate), Max Heart Rate: \(data.maxHeartRate)"
            }.joined(separator: "\n")
            completion(heartRateData, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    private func fetchMissingHealthKitData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        var missingData: [HeartRateData] = []
        
        let calendar = Calendar.current
        var date = startDate
        while date <= endDate {
            let heartRateData = HeartRateData(context: self.context)
            heartRateData.date = date
            missingData.append(heartRateData)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        fetchHealthData(for: missingData) { error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            self.saveToCoreData(dailyData: missingData)
            let resultString = missingData.map { data in
                "Date: \(data.date ?? Date()), Average Resting Heart Rate: \(data.avgRestingHeartRate), Min Heart Rate: \(data.minHeartRate), Max Heart Rate: \(data.maxHeartRate)"
            }.joined(separator: "\n")
            completion(resultString, nil)
        }
    }
    
    private func fetchHealthData(for data: [HeartRateData], completion: @escaping (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        populateAverageRestingHeartRate(for: data) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        populateMinMaxHeartRate(for: data) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    private func populateAverageRestingHeartRate(for data: [HeartRateData], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for heartRateData in data {
            dispatchGroup.enter()
            
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: heartRateData.date ?? Date())
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
                dispatchGroup.leave()
                continue
            }

            guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
                dispatchGroup.leave()
                continue
            }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                guard error == nil, let heartRateSamples = samples as? [HKQuantitySample], !heartRateSamples.isEmpty else {
                    DispatchQueue.main.async {
                        heartRateData.avgRestingHeartRate = 0
                        dispatchGroup.leave()
                    }
                    return
                }

                let totalHeartRate = heartRateSamples.reduce(0.0) { (result, sample) -> Double in
                    let heartRateValue = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    return result + heartRateValue
                }

                let averageHeartRate = totalHeartRate / Double(heartRateSamples.count)

                DispatchQueue.main.async {
                    heartRateData.avgRestingHeartRate = Int64(averageHeartRate.rounded())
                    dispatchGroup.leave()
                }
            }

            healthStore.execute(query)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    
    private func populateMinMaxHeartRate(for data: [HeartRateData], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for heartRateData in data {
            dispatchGroup.enter()
            
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: heartRateData.date ?? Date())
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
                dispatchGroup.leave()
                continue
            }

            guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
                dispatchGroup.leave()
                continue
            }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                guard error == nil, let heartRateSamples = samples as? [HKQuantitySample], !heartRateSamples.isEmpty else {
                    DispatchQueue.main.async {
                        heartRateData.minHeartRate = 0
                        heartRateData.maxHeartRate = 0
                        dispatchGroup.leave()
                    }
                    return
                }

                let heartRates = heartRateSamples.map { sample in
                    sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }

                let minHeartRate = heartRates.min() ?? 0
                let maxHeartRate = heartRates.max() ?? 0

                DispatchQueue.main.async {
                    heartRateData.minHeartRate = Int64(minHeartRate.rounded())
                    heartRateData.maxHeartRate = Int64(maxHeartRate.rounded())
                    dispatchGroup.leave()
                }
            }

            healthStore.execute(query)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    
    private func saveToCoreData(dailyData: [HeartRateData]) {
        do {
            try context.save()
        } catch {
            print("Failed to save heart rate data to Core Data: \(error)")
        }
    }
    
    private func updateMetadata(startDate: Date) {
        let fetchRequest: NSFetchRequest<Metadata> = Metadata.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dataType == %@", "HeartRateData")
        
        do {
            let metadata = try context.fetch(fetchRequest).first ?? Metadata(context: context)
            metadata.dataType = "HeartRateData"
            metadata.isAvailable = true
            metadata.timestamp = min(metadata.timestamp ?? .distantFuture, startDate)
            try context.save()
        } catch {
            print("Failed to update metadata: \(error)")
        }
    }
    
    func resetCoreData(completion: @escaping (Error?) -> Void) {
        let heartRateDataFetchRequest: NSFetchRequest<NSFetchRequestResult> = HeartRateData.fetchRequest()
        let metadataFetchRequest: NSFetchRequest<NSFetchRequestResult> = Metadata.fetchRequest()
        
        let batchDeleteHeartRateRequest = NSBatchDeleteRequest(fetchRequest: heartRateDataFetchRequest)
        let batchDeleteMetadataRequest = NSBatchDeleteRequest(fetchRequest: metadataFetchRequest)
        
        do {
            try context.execute(batchDeleteHeartRateRequest)
            try context.execute(batchDeleteMetadataRequest)
            try context.save()
            completion(nil)
        } catch {
            print("Failed to reset Core Data: \(error)")
            completion(error)
        }
    }
    
    func cleanAndRefetchData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        resetCoreData { error in
            if let error = error {
                completion(nil, error)
                return
            }
            self.fetchData(from: startDate, to: endDate, completion: completion)
        }
    }
}
