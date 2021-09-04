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
    //MARK: - Lesson - create
    func createNewLesson(image: UIImage, steps: [String]) -> Lesson {
        let lesson = createNewObject(objecteType: .lesson) as! Lesson
        lesson.id = UUID()
        lesson.timeStamp = Date()
        //UIImageをNSDataに変換
        let imageData = image.pngData()
        
        //UIImageの方向を確認
        var imageOrientation:Int = 0
        if (image.imageOrientation == UIImage.Orientation.down){
            imageOrientation = 2
        } else {
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
    
    //MARK: - Lesson - read
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
    
    func loadAllFavoriteLessonData() -> [Lesson] {
        let fetchRequest = createRequest(objecteType: .lesson)
        let predicate = NSPredicate(format: "%K == %@", "favorite", NSNumber(value: true))
        fetchRequest.predicate = predicate
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    func loadAllLessonData() -> [Lesson] {
        let fetchRequest = createRequest(objecteType: .lesson)
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    //MARK: - Lesson - update
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
    
    func updateLessonImage(lessonID: String, image: UIImage) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            // UIImageをNSDataに変換
            let imageData = image.pngData()
            // UIImageの方向を確認
            var imageOrientation:Int = 0
            if (image.imageOrientation == UIImage.Orientation.down) {
                imageOrientation = 2
            } else {
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
    
    func updateLessonTitle(lessonID: String, title: String) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            lesson.title = title
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonFavorite(lessonID: String, favorite: Bool) {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return }
            lesson.favorite = favorite
            saveContext()
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonOrder(lessonArray: [Lesson]) {
        for (index, lesson) in lessonArray.enumerated() {
            lesson.orderNum = Int16(index)
        }
        saveContext()
    }
    
    //MARK: - Lesson - delete
    func deleteLessonData(lessonID: String) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "id", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            deleteAllSteps(lessonID: lessonID)
            managerObjectContext.delete(lesson)
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    //MARK: - Steps - fetch
    func featchSteps(lessonID: String) -> [LessonSteps] {
        let fetchRequest = createRequest(objecteType: .lessonSteps)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid!)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonSteps]
            return lessonSteps
        } catch {
            fatalError("loadData error")
        }
    }
    
    //MARK: - Steps - create
    
    func createStep(lesson: Lesson) {
        let steps = lesson.steps?.allObjects as! [LessonSteps]
        var numbers: [Int16] = []
        steps.forEach { numbers.append($0.number) }
        let lessonStep = createNewObject(objecteType: .lessonSteps) as! LessonSteps
        lessonStep.lessonID = lesson.id
        lessonStep.number = (numbers.max() ?? 0) + 1
        lessonStep.explication = ""
        lesson.addToSteps(lessonStep)
        saveContext()
    }
    
    //MARK: - Steps - delete
    func deleteAllSteps(lessonID: String) {
        let fetchRequest = createRequest(objecteType: .lessonSteps)
        let uuid = NSUUID(uuidString: lessonID)
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid!)
        fetchRequest.predicate = predicate
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonSteps]
            let lesson = loadLessonData(lessonID: lessonID)
            if !lessonSteps.isEmpty {
                lessonSteps.forEach {
                    lesson?.removeFromSteps($0)
                    managerObjectContext.delete($0)
                }
            }
        } catch {
            fatalError("loadData error")
        }
    }
    
    func deleteStep(lesson: Lesson, step: LessonSteps, stpes: [LessonSteps]) {
        stpes.forEach {
            if $0.number > step.number {
                $0.number -= 1
            }
        }
        lesson.removeFromSteps(step)
        managerObjectContext.delete(step)
        saveContext()
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
