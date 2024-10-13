//
//  ArticleEntity+CoreDataProperties.swift
//  Millie
//
//  Created by 현은백 on 10/13/24.
//
//

import Foundation
import CoreData


extension ArticleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        return NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var imageData: Data?
    @NSManaged public var url: String?
    @NSManaged public var title: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var content: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var order: String?

}

extension ArticleEntity : Identifiable {

}
