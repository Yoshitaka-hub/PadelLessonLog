//
//  Lesson+Additions.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/31.
//

import UIKit

extension Lesson {
    func getImage() -> UIImage? {
        guard let image = self.image else { return nil }
        var imageData = UIImage(data: image as Data)
        if imageOrientation == 2, let data = imageData {
            guard let cdImage = data.cgImage else { return imageData }
            imageData = UIImage(cgImage: cdImage, scale: data.scale, orientation: UIImage.Orientation.down)
        }
        return imageData
    }
}
