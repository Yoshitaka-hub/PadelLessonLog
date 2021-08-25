//
//  LessonDataManager.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/25.
//

import UIKit

class LessonDataManager {
    
    private let fileNameFormat = "yyyyMMddHHmmss"
    let fileManager = FileManager.default
    
    func saveLessonDataWithImage(fileData: Data) {
        let nowDate = Date().stringWithFormat(dateFormat: fileNameFormat)
        let filePath = URL(string: createFilePath(fileName: "\(nowDate).jpg"))!
        
        do {
            try fileData.write(to: filePath)
        } catch let error {
            print("Unresolved error \(error)")
            abort()
        }
    }
    
    private func createFilePath(fileName: String) -> String {
        let fileDir = URL(string: NSHomeDirectory())!.appendingPathComponent(filesPath).relativePath
        
        if !fileManager.fileExists(atPath: fileDir) {
            do {
                try fileManager.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Unresolved error \(error)")
                abort()
            }
        }
        return URL(fileURLWithPath: fileDir).appendingPathComponent(fileName).absoluteString
    }
    
    func updateLessonImage(newImage: UIImage, imagePath: String) {
        let jpegImage = newImage.jpegData(compressionQuality: 0.8)
        do {
            try jpegImage?.write(to: URL(fileURLWithPath: imagePath))
        } catch let error {
            print("Unresolved Error \(error)")
            abort()
        }
    }
}
