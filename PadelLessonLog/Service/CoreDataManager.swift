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
    case lessonStep = "LessonStep"
 }

protocol CoreDataProtocol {
    func createNewLesson(image: UIImage, steps: [String]) -> Lesson
    func loadAllLessonData() -> [Lesson]
    func loadAllFavoriteLessonData() -> [Lesson]
    func loadAllLessonDataWithImage() -> [Lesson]
    func loadAllFavoriteLessonDataWithImage() -> [Lesson]
    func updateLessonOrder(lessonArray: [Lesson]) 
}

final class CoreDataManager: CoreDataProtocol {
    static let shared = CoreDataManager()
    
    private init() { }
    
    // アプリケーション内のオブジェクトとデータベースの間のやり取りを行う
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "PadelLessonLog")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // リリースビルドでは通っても何も起きない
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // persistentContainerデータベース情報を表す
    // 管理オブジェクトコンテキスト。NSManagedObject 群を管理するクラス
    var managerObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

extension CoreDataManager {
    // MARK: - Lesson - create
    func createNewLesson(image: UIImage, steps: [String]) -> Lesson {
        let lesson = createNewObject(objecteType: .lesson) as! Lesson
        lesson.id = UUID()
        lesson.timeStamp = Date()
        // UIImageをNSDataに変換
        let imageData = image.pngData()
        
        // UIImageの方向を確認
        var imageOrientation: Int = 0
        if image.imageOrientation == UIImage.Orientation.down {
            imageOrientation = 2
        } else {
            imageOrientation = 1
        }
        
        lesson.setValue(imageData, forKey: "image")
        lesson.setValue(imageOrientation, forKey: "imageOrientation")
    
        if !steps.isEmpty {
            for (index, step) in steps.enumerated() {
                let lessonStep = createNewObject(objecteType: .lessonStep) as! LessonStep
                lessonStep.lessonID = lesson.id
                lessonStep.orderNum = Int16(index)
                lessonStep.explication = step
                lesson.addToSteps(lessonStep)
            }
        }
        saveContext()
        return lesson
    }
    
    // MARK: - Lesson - read
    func loadLessonData(lessonID: String) -> Lesson? {
        let fetchRequest = createRequest(objecteType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return nil }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
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
    func loadAllFavoriteLessonDataWithImage() -> [Lesson] {
        let fetchRequest = createRequest(objecteType: .lesson)
        let predicate = NSPredicate(format: "%K == %@", "favorite", NSNumber(value: true))
        fetchRequest.predicate = predicate
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            var lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            lessons = lessons.filter { $0.imageSaved }
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
    
    func loadAllLessonDataWithImage() -> [Lesson] {
        let fetchRequest = createRequest(objecteType: .lesson)
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            var lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            lessons = lessons.filter { $0.imageSaved }
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    // MARK: - Lesson - update
    func resetLessonImage(lessonID: String, image: UIImage) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            // UIImageをNSDataに変換
            let imageData = image.pngData()
            
            // UIImageの方向を確認
            var imageOrientation: Int = 0
            if image.imageOrientation == UIImage.Orientation.down {
                imageOrientation = 2
            } else {
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
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            // UIImageをNSDataに変換
            let imageData = image.pngData()
            // UIImageの方向を確認
            var imageOrientation: Int = 0
            if image.imageOrientation == UIImage.Orientation.down {
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
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
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
        guard let uuid = NSUUID(uuidString: lessonID) else { return }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
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
    
    // MARK: - Lesson - delete
    func deleteLessonData(lessonID: String) -> Bool {
        let fetchRequest = createRequest(objecteType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
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
    
    // MARK: - Steps - fetch
    func featchSteps(lessonID: String) -> [LessonStep] {
        let fetchRequest = createRequest(objecteType: .lessonStep)
        guard let uuid = NSUUID(uuidString: lessonID) else { return Array() }
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonStep]
            return lessonSteps
        } catch {
            fatalError("loadData error")
        }
    }
    
    // MARK: - Steps - create
    
    func createStep(lesson: Lesson) {
        let steps = lesson.steps?.allObjects as! [LessonStep]
        var numbers: [Int16] = []
        steps.forEach { numbers.append($0.orderNum) }
        let lessonStep = createNewObject(objecteType: .lessonStep) as! LessonStep
        lessonStep.lessonID = lesson.id
        lessonStep.orderNum = (numbers.max() ?? 0) + 1
        lessonStep.explication = ""
        lesson.addToSteps(lessonStep)
        saveContext()
    }
    
    // MARK: - Steps - delete
    func deleteAllSteps(lessonID: String) {
        let fetchRequest = createRequest(objecteType: .lessonStep)
        guard let uuid = NSUUID(uuidString: lessonID) else { return }
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonStep]
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
    
    func deleteStep(lesson: Lesson, step: LessonStep, stpes: [LessonStep]) {
        stpes.forEach {
            if $0.orderNum > step.orderNum {
                $0.orderNum -= 1
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
        managerObjectContext.mergePolicy = NSOverwriteMergePolicy

        if managerObjectContext.hasChanges {
            do {
                try managerObjectContext.save()
            } catch let error {
                print(error)
//                abort()
            }
        }
    }
    
    func saveContextFromAppDelegate () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
