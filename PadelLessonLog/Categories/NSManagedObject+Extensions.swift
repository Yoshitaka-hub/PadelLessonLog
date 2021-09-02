//
//  NSManagedObject+Extensions.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/02.
//

import CoreData

extension NSManagedObject {
    func save() {
        do {
            try managedObjectContext?.save()
        } catch let error {
            print(error)
            abort()
        }
    }
}
