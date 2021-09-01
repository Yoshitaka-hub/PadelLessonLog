//
//  CoreDataManager.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/26.
//

import UIKit
import CoreData

enum CoreDataObjectType: String {
    case lesson = "Lesson"
    case lessonSteps = "LessonSteps"
 }

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // persistentContainerデータベース情報を表す
    // 管理オブジェクトコンテキスト。NSManagedObject 群を管理するクラス
    lazy var managerObjectContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
}

extension CoreDataManager {
    func createNewLesson(image: UIImage, steps: [String]) -> Lesson {
        let lesson = createNewObject(objecteType: .lesson) as! Lesson
        lesson.id = UUID()
        
        //UIImageをNSDataに変換
        let imageData = image.pngData()
        
        //UIImageの方向を確認
        var imageOrientation:Int = 0
        if (image.imageOrientation == UIImage.Orientation.down){
            imageOrientation = 2
        }else{
            imageOrientation = 1
        }
        
        lesson.setValue(imageData, forKey: "image")
        lesson.setValue(imageOrientation, forKey: "imageOrientation")
    
        if !steps.isEmpty {
            for (index, step) in steps.enumerated() {
                let lessonStep = createNewObject(objecteType: .lessonSteps) as! LessonSteps
                lessonStep.lessonID = lesson.id
                lessonStep.number = Int16(index)
                lessonStep.explication = step
                lesson.addToSteps(lessonStep)
            }
        }
        saveContext()
        return lesson
    }
    
    func loadLessonData(lessonID: String) -> Lesson? {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            return lessons.first
        } catch {
            fatalError("loadData error")
        }
    }
    
    func loadAllLessonData() -> [Lesson] {
        let fetchRequest = createRequest(objecteType: .lesson)
        
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    func deleteLessonData(lessonID: String) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            managerObjectContext.delete(lesson)
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func resetLessonImage(lessonID: String, image: UIImage) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            //UIImageをNSDataに変換
            let imageData = image.pngData()
            
            //UIImageの方向を確認
            var imageOrientation:Int = 0
            if (image.imageOrientation == UIImage.Orientation.down){
                imageOrientation = 2
            }else{
                imageOrientation = 1
            }
            
            lesson.setValue(imageData, forKey: "image")
            lesson.setValue(imageOrientation, forKey: "imageOrientation")
            lesson.imageSaved = false
            
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonTitleAndSteps(lessonID: String, title: String, steps: [String]) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            lesson.title = title
            deleteAllSteps(lessonID: lessonID)
            if !steps.isEmpty {
                for (index, step) in steps.enumerated() {
                    let lessonStep = createNewObject(objecteType: .lessonSteps) as! LessonSteps
                    lessonStep.lessonID = lesson.id
                    lessonStep.number = Int16(index)
                    lessonStep.explication = step
                    lesson.addToSteps(lessonStep)
                }
            }
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func deleteAllSteps(lessonID: String) {
        let fetchRequest = createRequest(objecteType: .lessonSteps)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonSteps]
            if !lessonSteps.isEmpty {
                lessonSteps.forEach {
                    managerObjectContext.delete($0)
                }
            }
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonImage(lessonID: String, image: UIImage) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            //UIImageをNSDataに変換
            let imageData = image.pngData()
            
            //UIImageの方向を確認
            var imageOrientation:Int = 0
            if (image.imageOrientation == UIImage.Orientation.down){
                imageOrientation = 2
            }else{
                imageOrientation = 1
            }
            
            lesson.setValue(imageData, forKey: "image")
            lesson.setValue(imageOrientation, forKey: "imageOrientation")
            lesson.imageSaved = true
            
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func createRequest(objecteType: CoreDataObjectType) -> NSFetchRequest<NSFetchRequestResult> {
        NSFetchRequest<NSFetchRequestResult>(entityName: objecteType.rawValue)
    }
    func createNewObject(objecteType: CoreDataObjectType) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: objecteType.rawValue, into: managerObjectContext)
    }
 
    
    func saveContext() {
        if managerObjectContext.hasChanges {
            do {
                try managerObjectContext.save()
            } catch let error {
                print(error)
                abort()
            }
        }
    }
}
