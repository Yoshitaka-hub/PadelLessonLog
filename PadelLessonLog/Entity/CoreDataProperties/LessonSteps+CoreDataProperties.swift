//
//  LessonSteps+CoreDataProperties.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/31.
//
//

import Foundation
import CoreData


extension LessonSteps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonSteps> {
        return NSFetchRequest<LessonSteps>(entityName: "LessonSteps")
    }

    @NSManaged public var explication: String?
    @NSManaged public var number: Int16
    @NSManaged public var lessonID: Lesson?

}

extension LessonSteps : Identifiable {

}
