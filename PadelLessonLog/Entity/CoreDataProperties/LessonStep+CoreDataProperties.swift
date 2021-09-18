//
//  LessonStep+CoreDataProperties.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/13.
//
//

import Foundation
import CoreData


extension LessonStep {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonStep> {
        return NSFetchRequest<LessonStep>(entityName: "LessonStep")
    }

    @NSManaged public var explication: String?
    @NSManaged public var lessonID: UUID?
    @NSManaged public var orderNum: Int16
    @NSManaged public var lesson: Lesson?

}

extension LessonStep : Identifiable {

}
