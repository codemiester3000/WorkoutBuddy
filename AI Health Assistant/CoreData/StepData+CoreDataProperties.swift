import Foundation
import CoreData


extension StepData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StepData> {
        return NSFetchRequest<StepData>(entityName: "StepData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var stepsCount: Int64

}

extension StepData : Identifiable {

}
