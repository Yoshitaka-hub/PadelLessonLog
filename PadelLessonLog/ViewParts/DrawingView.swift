//
//  DrawingView.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit

enum ObjectColor: Int {
    case yellow = 0, red, blue

    func toColor() -> UIColor {
        switch self {
        case .red:
            return UIColor.systemRed
        case .yellow:
            return UIColor.systemYellow
        case .blue:
            return UIColor.systemBlue
        }
    }

    var pinImage: UIImage {
        let baseName = "img"
        var imageName = baseName
        switch self {
        case .red:
            imageName = baseName + "_pin_red"
        case .yellow:
            imageName = baseName + "_pin_yellow"
        case .blue:
            imageName = baseName + "_pin_blue"
        }
        let pinImage = UIImage(named: imageName)!
        return pinImage
    }
    
    var ballImage: UIImage {
        let baseName = "img"
        var imageName = baseName
        switch self {
        case .red:
            imageName = baseName + "_ball_red"
        case .yellow:
            imageName = baseName + "_ball_yellow"
        case .blue:
            imageName = baseName + "_ball_blue"
        }
        let ballImage = UIImage(named: imageName)!
        return ballImage
    }
    
    static func defaultValue() -> ObjectColor {
        return ObjectColor.yellow
    }
}

enum ObjectType: Int {
    case line = 0, pin, ball

    static func defaultValue() -> ObjectType {
        return ObjectType.pin
    }
}

class DrawingView: UIView, UIGestureRecognizerDelegate {
    var lineWeight = 5.0
    var objectColor: ObjectColor = .defaultValue()
    var objectType: ObjectType = .defaultValue()

    var touchedPoints = [CGPoint]()

    let drawnImageView = UIImageView()
    let drawingImageView = UIImageView()
    var objectViews = [ObjectImageView]()

    var panGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!

    // MARK: initializer

    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    func setup() {
        drawnImageView.frame = bounds
        drawingImageView.frame = bounds
        guard !subviews.contains(drawingImageView) else { return }
        addSubview(drawnImageView)
        addSubview(drawingImageView)

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drawingViewPanned))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(drawingViewTapped))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - gesture recognizer delegate

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return objectType == .pin || objectType == .ball
        } else if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return objectType == .line
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }

    @objc func drawingViewPanned() {
        switch panGestureRecognizer.state {
        case .began:
            touchedPoints = [panGestureRecognizer.location(in: self)]
        case .changed:
            let currentPoint = panGestureRecognizer.location(in: self)
            let touchPoint = touchedPoints.last! as CGPoint

            setupDrawingContext(scale: 1.0)

            if let image = self.drawingImageView.image {
                image.draw(in: bounds)
            }

            drawLine(from: touchPoint, to: currentPoint)

            endDrawingContext(targetImageView: drawingImageView)
            touchedPoints.append(currentPoint)
        case .ended, .cancelled:
            setupDrawingContext(scale: 1.0)

            if let image = self.drawnImageView.image {
                image.draw(in: bounds)
            }

            var beginPoint = touchedPoints.remove(at: 0)

            for endPoint in touchedPoints {
                drawLine(from: beginPoint, to: endPoint)
                beginPoint = endPoint
            }

            endDrawingContext(targetImageView: drawnImageView)
            touchedPoints.removeAll(keepingCapacity: false)
            drawingImageView.image = nil
        default:
            break
        }
    }

    @objc func drawingViewTapped() {
        let objectView = ObjectImageView(objectColor: objectColor, objectType: objectType)
        objectView.frame.origin = tapGestureRecognizer.location(in: self)
        addSubview(objectView)
        objectViews.append(objectView)
    }

    // MARK: drawing methods

    func setupDrawingContext(scale: CGFloat) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()!.setLineWidth(5.0)
        UIGraphicsGetCurrentContext()!.setStrokeColor(objectColor.toColor().cgColor)
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsGetCurrentContext()?.move(to: fromPoint)
        UIGraphicsGetCurrentContext()?.addLine(to: toPoint)
        UIGraphicsGetCurrentContext()!.strokePath()
    }

    func endDrawingContext(targetImageView: UIImageView) {
        targetImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    func drawIntoImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .none
        let originalImageSize = image.size
        var rect = CGRect.zero
        rect.size = originalImageSize
        let size = bounds.size

        _ = CGSize.zero

        let widthRate = originalImageSize.width / size.width
        let heightRate = originalImageSize.height / size.height
        let rate = widthRate < heightRate ? widthRate : heightRate

        var drawingRect = CGRect(x: 0, y: 0, width: size.width * rate, height: size.height * rate)
        drawingRect = drawingRect.offsetBy(dx: rect.midX - drawingRect.width / 2, dy: rect.midY - drawingRect.height / 2).integral
        image.draw(in: rect)
        drawnImageView.image?.draw(in: drawingRect)
        for arrow in objectViews {
            let arrowRect = arrow.frame
            let image = arrow.rotatedImage()
            let marginX = (image.size.width - arrowRect.width) / 2
            let marginY = (image.size.height - arrowRect.height) / 2
            let arrowDrawingRect = CGRect(x: (arrowRect.minX - marginX) * rate,
                                          y: (arrowRect.minY - marginY) * rate,
                                          width: image.size.width * rate,
                                          height: image.size.height * rate).offsetBy(dx: drawingRect.minX, dy: drawingRect.minY).integral
            image.draw(in: arrowDrawingRect)
        }
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return drawnImage!
    }
}
