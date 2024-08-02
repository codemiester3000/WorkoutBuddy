import Foundation
import CoreData


extension Metadata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Metadata> {
        return NSFetchRequest<Metadata>(entityName: "Metadata")
    }

    @NSManaged public var dataType: String?
    @NSManaged public var isAvailable: Bool
    @NSManaged public var timestamp: Date?

}

extension Metadata : Identifiable {

}
