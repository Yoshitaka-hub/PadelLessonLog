//
//  Lesson+Additions.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/31.
//

import UIKit

extension Lesson {
    func getImage() -> UIImage? {
        var image = UIImage(data: self.image! as Data)
        if (imageOrientation == 2) {
            image = UIImage(cgImage: image!.cgImage!, scale: image!.scale, orientation: UIImage.Orientation.down)
        }
        return image
    }
}
