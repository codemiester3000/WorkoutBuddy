//
//  HeartRateData+CoreDataProperties.swift
//  AI Health Assistant
//
//  Created by Owen Khoury on 7/30/24.
//
//

import Foundation
import CoreData


extension HeartRateData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HeartRateData> {
        return NSFetchRequest<HeartRateData>(entityName: "HeartRateData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var maxHeartRate: Int64
    @NSManaged public var avgRestingHeartRate: NSObject?
    @NSManaged public var minHeartRate: NSObject?

}

extension HeartRateData : Identifiable {

}
