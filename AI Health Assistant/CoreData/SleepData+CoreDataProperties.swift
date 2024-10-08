import Foundation
import CoreData


extension SleepData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepData> {
        return NSFetchRequest<SleepData>(entityName: "SleepData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var sleepDuration: Int64

}

extension SleepData : Identifiable {

}
