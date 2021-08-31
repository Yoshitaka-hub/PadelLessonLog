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
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        //UIImageの方向を確認
        var imageOrientation:Int = 0
        if (image.imageOrientation == UIImage.Orientation.down){
            imageOrientation = 2
        }else{
            imageOrientation = 1
        }
        
        lesson.setValue(imageData, forKey: "image")
        lesson.setValue(imageOrientation, forKey: "imageOrientation")
    
        var lessonStepsArray = [LessonSteps]()
        if !steps.isEmpty {
            for (index, step) in steps.enumerated() {
                let lessonStep = createNewObject(objecteType: .lessonSteps) as! LessonSteps
                lessonStep.number = Int16(index)
                lessonStep.explication = step
                lessonStepsArray.append(lessonStep)
            }
            lesson.setValue(lessonStepsArray, forKey: "steps")
        }
        saveContext()
        return lesson
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
