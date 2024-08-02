import HealthKit
import CoreData
import UIKit

class HeartRateAgent: HealthKitFetcher {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let context = CoreDataStack.shared.context
    
    func fetchData(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        let cachedDataStartDate = getCachedDataStartDate()
        
        if cachedDataStartDate <= startDate {
            print("All of the data we need is cached in core data")
            fetchFromCoreData(from: startDate, to: endDate, completion: completion)
        } else if cachedDataStartDate <= endDate {
            print("we have some cached data")
            // We have some data in Core Data, but need to fetch more from HealthKit
            let coreDataStartDate = max(startDate, cachedDataStartDate)
            fetchFromCoreData(from: coreDataStartDate, to: endDate) { coreDataResult, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                self.fetchFromHealthKit(from: startDate, to: cachedDataStartDate) { healthKitResult, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    let combinedResult = (healthKitResult ?? "") + "\n" + (coreDataResult ?? "")
                    completion(combinedResult, nil)
                }
            }
        } else {
            print("We dont have any cached data. pull it all")
            // We don't have any relevant data in Core Data, fetch everything from HealthKit
            fetchFromHealthKit(from: startDate, to: endDate, completion: completion)
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
                "Date: \(data.date ?? Date()), Average Heart Rate: \(data.heartRate)"
            }.joined(separator: "\n")
            completion(heartRateData, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    private func fetchFromHealthKit(from startDate: Date, to endDate: Date, completion: @escaping (String?, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(nil, error)
                return
            }
            
            let dailyAverageHeartRates = self.calculateDailyAverageHeartRates(samples: samples)
            self.saveToCoreData(dailyAverageHeartRates: dailyAverageHeartRates)
            
            let heartRateData = dailyAverageHeartRates.map { date, avgHeartRate in
                "Date: \(date), Average Heart Rate: \(avgHeartRate)"
            }.joined(separator: "\n")
            
            self.updateMetadata(startDate: startDate)
            
            completion(heartRateData, nil)
        }
        
        healthStore.execute(query)
    }
    
    private func calculateDailyAverageHeartRates(samples: [HKQuantitySample]) -> [(Date, Double)] {
        var dailyHeartRates: [Date: [Double]] = [:]
        
        for sample in samples {
            let date = Calendar.current.startOfDay(for: sample.startDate)
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            dailyHeartRates[date, default: []].append(heartRate)
        }
        
        return dailyHeartRates.map { date, heartRates in
            let averageHeartRate = heartRates.reduce(0, +) / Double(heartRates.count)
            return (date, averageHeartRate)
        }.sorted { $0.0 < $1.0 }
    }
    
    private func saveToCoreData(dailyAverageHeartRates: [(Date, Double)]) {
        for (date, averageHeartRate) in dailyAverageHeartRates {
            let fetchRequest: NSFetchRequest<HeartRateData> = HeartRateData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date == %@", date as NSDate)
            
            do {
                let existingData = try context.fetch(fetchRequest)
                let heartRateData: HeartRateData
                
                if let existingEntry = existingData.first {
                    heartRateData = existingEntry
                } else {
                    heartRateData = HeartRateData(context: context)
                    heartRateData.date = date
                }
                
                heartRateData.heartRate = Int64(averageHeartRate)
            } catch {
                print("Failed to fetch or create heart rate data: \(error)")
            }
        }
        
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

        // You might want to add this method to your view controller or wherever it's appropriate
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
