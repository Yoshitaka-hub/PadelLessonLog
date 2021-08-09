//
//  DrawingView.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit

enum LineColor: Int {
    case red = 0, green, blue

    func toColor() -> UIColor {
        switch self {
        case .red:
            return UIColor(red: 0.984, green: 0.000, blue: 0.039, alpha: 1.000)
        case .green:
            return UIColor(red: 0.133, green: 0.937, blue: 0.043, alpha: 1.000)
        case .blue:
            return UIColor(red: 0.133, green: 0.000, blue: 1.000, alpha: 1.000)
        }
    }

    var pinImage: UIImage {
        let baseName = "img"
        var imageName = baseName
        switch self {
        case .red:
            imageName = baseName + "_pin_red"
        case .green:
            imageName = baseName + "_pin_Yellow"
        case .blue:
            imageName = baseName + "_pin_Blue"
        }
        let arrowImage = UIImage(named: imageName)!
        return arrowImage
    }
}

enum EditingMode: Int {
    case line = 0, pin

    static func defaultValue() -> EditingMode {
        return EditingMode.pin
    }
}

class DrawingView: UIView, UIGestureRecognizerDelegate {
    var lineWeight = 8.0
    var lineColor = LineColor.red
    var editingMode: EditingMode = .defaultValue()

    var touchedPoints = [CGPoint]()

    let drawnImageView = UIImageView()
    let drawingImageView = UIImageView()
    var arrowViews = [PinImageView]()

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
            return editingMode == .pin
        } else if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return editingMode == .line
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
        let arrowView = PinImageView(lineColor: lineColor)
        arrowView.frame.origin = tapGestureRecognizer.location(in: self)
        addSubview(arrowView)
        arrowViews.append(arrowView)
    }

    // MARK: drawing methods

    func setupDrawingContext(scale: CGFloat) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()!.setLineWidth(8.0)
        UIGraphicsGetCurrentContext()!.setStrokeColor(lineColor.toColor().cgColor)
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
        for arrow in arrowViews {
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
