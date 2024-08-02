import Foundation
import CoreData


extension HeartRateData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeartRateData> {
        return NSFetchRequest<HeartRateData>(entityName: "HeartRateData")
    }

    @NSManaged public var avgRestingHeartRate: Int64
    @NSManaged public var date: Date?
    @NSManaged public var maxHeartRate: Int64
    @NSManaged public var minHeartRate: Int64

}

extension HeartRateData : Identifiable {

}
