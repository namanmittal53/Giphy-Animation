//
//  Entity+CoreDataProperties.swift
//  Giphy Animation
//
//  Created by Admin on 21/08/23.
//
//

import Foundation
import CoreData


extension GIFLocalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GIFLocalEntity> {
        return NSFetchRequest<GIFLocalEntity>(entityName: "GIFLocalEntity")
    }

    @NSManaged public var urlString: String?
    @NSManaged public var gifData: Data?

}

extension GIFLocalEntity : Identifiable {

}
