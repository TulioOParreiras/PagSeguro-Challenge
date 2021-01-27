//
//  ManagedBeerImage.swift
//  BeerList
//
//  Created by Tulio Parreiras on 27/01/21.
//

import CoreData

@objc(ManagedBeerImage)
class ManagedBeerImage: NSManagedObject {
    @NSManaged var url: URL
    @NSManaged var data: Data?
}

extension ManagedBeerImage {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedBeerImage? {
        let request = NSFetchRequest<ManagedBeerImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedBeerImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
