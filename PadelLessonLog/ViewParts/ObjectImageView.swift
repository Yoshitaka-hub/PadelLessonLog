//
//  PinImageView.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit
class ObjectImageView: UIImageView, UIGestureRecognizerDelegate {
    var origin = CGPoint.zero
    var originalTransform: CGAffineTransform = .identity

    init(objectColor color: ObjectColor, objectType type: ObjectType ) {
        let image = type == .pin ? color.pinImage : color.ballImage
        super.init(image: image)

        isUserInteractionEnabled = true

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(imagePanned))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(imageRotated))
        rotationGestureRecognizer.delegate = self
        addGestureRecognizer(rotationGestureRecognizer)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    @objc func imagePanned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            origin = center
        case .changed:
            let point = gestureRecognizer.translation(in: superview!)
            center = CGPoint(x: origin.x + point.x, y: origin.y + point.y)
        default:
            break
        }
    }

    @objc func imageRotated(gestureRecognizer: UIRotationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            originalTransform = transform
        case .changed:
            // 回転の速度が遅いので1.5倍にしている
            let rotation = gestureRecognizer.rotation * 1.5
            transform = originalTransform.rotated(by: rotation)
        default:
            break
        }
    }

    func rotatedImage() -> UIImage {
        let largeImage = self.largeImage()

        let rotatedImageContextSize: CGSize = largeImage!.size

        UIGraphicsBeginImageContext(rotatedImageContextSize)
        let rotatedImageContext: CGContext = UIGraphicsGetCurrentContext()!

        let moveX = CGFloat(rotatedImageContextSize.width / 2)
        let moveY = CGFloat(rotatedImageContextSize.height / 2)

        let radians = atan2f(Float(transform.b), Float(transform.a))
        rotatedImageContext.translateBy(x: moveX, y: moveY)
        rotatedImageContext.rotate(by: CGFloat(radians))
        rotatedImageContext.translateBy(x: -moveX, y: -moveY)

        let rotatedImageRect = CGRect(x: 0, y: 0, width: rotatedImageContextSize.width, height: rotatedImageContextSize.height)
        largeImage?.draw(in: rotatedImageRect)

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage!
    }

    // self.imageの対角線の長さの辺を持つUIImageを返す
    func largeImage() -> UIImage? {
        let imageSize = image!.size
        let diagonal = sqrt(imageSize.width * imageSize.width + imageSize.height * imageSize.height)

        let largeImageContextSize: CGSize = CGSize(width: diagonal, height: diagonal)

        UIGraphicsBeginImageContext(largeImageContextSize)
        let _: CGContext = UIGraphicsGetCurrentContext()!

        let largeImageDrawingRect = CGRect(x: (largeImageContextSize.width - imageSize.width) / 2, y: (largeImageContextSize.height - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        image?.draw(in: largeImageDrawingRect)

        let largeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return largeImage
    }
}
