//
//  AddNewLessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit
import Sketch

class AddNewLessonViewController: UIViewController {

    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var customToolbar: UIToolbar!
    
    private var viewModel = AddNewLessonViewModel()
    
    private var coreDataMangaer = CoreDataManager.shared
    var lessonID: String?
    var lessonImage: UIImage?
    private var stampType = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()
        navigationItem.title = NSLocalizedString("Draw View", comment: "")
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage(systemName: "chevron.backward.circle")!, select: #selector(back))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sketchView.loadImage(image: lessonImage!, drawMode: .scale)
        sketchView.drawTool = .pen
        sketchView.drawingPenType = .normal
        sketchView.lineColor = .black
        sketchView.lineAlpha = 1
        sketchView.lineWidth = 4
        UIGraphicsBeginImageContextWithOptions(sketchView.frame.size, false, 0.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
    }
    
    func configureToolbar() {
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.lightGray
        customToolbar.barStyle = .default
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var buttonItems: [UIBarButtonItem] = []
        
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveButtonItem.tintColor = .black
        buttonItems.append(saveButtonItem)
        buttonItems.append(flexibleSpace)
        buttonItems.append(flexibleSpace)
        let undoButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: #selector(undo))
        undoButtonItem.tintColor = .black
        buttonItems.append(undoButtonItem)
        buttonItems.append(flexibleSpace)
        let objectButtonItem = UIBarButtonItem(image: UIImage(systemName: "hand.draw"), style: .plain, target: self, action: #selector(objectTable))
        objectButtonItem.tintColor = .black
        buttonItems.append(objectButtonItem)
        buttonItems.append(flexibleSpace)
        let colorButtonItem = UIBarButtonItem(image: UIImage(systemName: "paintpalette"), style: .plain, target: self, action: #selector(colorTable))
        colorButtonItem.tintColor = .black
        buttonItems.append(colorButtonItem)
        buttonItems.append(flexibleSpace)

        customToolbar.setItems(buttonItems, animated: true)
    }
    
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func save() {
        guard let id = lessonID else { return }
        let size = sketchView.frame
        print(size)
        sketchView.draw(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let savingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let isSaved = coreDataMangaer.updateLessonImage(lessonID: id, image: savingImage!)
        if isSaved {
            navigationController?.popViewController(animated: true)
        } else {
            fatalError("画像が更新できない")
        }
    }
    @objc
    func undo() {
        sketchView.undo()
    }
    @objc
    func colorTable() {
        let storyboard = UIStoryboard(name: "ColorTable", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ColorTable")
        if let colorTableVC = vc as? ColorTableViewController {
            colorTableVC.delegate = self
            switch sketchView.lineColor {
            case .red:
                colorTableVC.objectColor = .red
            case .yellow:
                colorTableVC.objectColor = .yellow
            case .blue:
                colorTableVC.objectColor = .blue
            default:
                colorTableVC.objectColor = ObjectColor.defaultValue()
            }
        }
        let screenSize = UIScreen.main.bounds.size
        openPopUpController(popUpController: vc, sourceView: customToolbar, rect: CGRect(x: screenSize.width / 3.2, y: 0, width: screenSize.width / 3, height: screenSize.height / 5), arrowDirections: .down, canOverlapSourceViewRect: true)
    }
    @objc
    func objectTable() {
        let storyboard = UIStoryboard(name: "ObjectTable", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ObjectTable")
        if let objectTableVC = vc as? ObjectTableViewController {
            objectTableVC.delegate = self
            switch sketchView.drawTool {
            case .line:
                objectTableVC.objectType = .line
            case .arrow:
                objectTableVC.objectType = .arrow
            case .stamp:
                objectTableVC.objectType = stampType ? .ball : .pin
            case .rectangleFill:
                objectTableVC.objectType = .rect
            case .fill:
                objectTableVC.objectType = .fill
            default:
                objectTableVC.objectType = ObjectType.defaultValue()
            }
        }
        let screenSize = UIScreen.main.bounds.size
        openPopUpController(popUpController: vc, sourceView: customToolbar, rect: CGRect(x: screenSize.width / 8.3 , y: 0, width: screenSize.width / 3, height: screenSize.height / 4), arrowDirections: .down, canOverlapSourceViewRect: true)
    }
    private func changeStampMode(stampName: String) {
        sketchView.stampImage = UIImage(named: stampName)
        sketchView.drawTool = .stamp
    }
}

extension AddNewLessonViewController: ColorTableViewControllerDelegate {
    func ColorTableViewController(colorTableViewController: ColorTableViewController, didSelectColor: ObjectColor) {
        switch didSelectColor {
        case .black:
            sketchView.lineColor = .black
        case .yellow:
            sketchView.lineColor = .yellow
        case .blue:
            sketchView.lineColor = .blue
        case .red:
            sketchView.lineColor = .red
        }
        if sketchView.drawTool == .stamp {
            switch sketchView.lineColor {
            case .red:
                changeStampMode(stampName: stampType ? "img_ball_red" : "img_pin_red")
            case .yellow:
                changeStampMode(stampName: stampType ? "img_ball_yellow" : "img_pin_yellow")
            case .blue:
                changeStampMode(stampName: stampType ? "img_ball_blue" : "img_pin_blue")
            default:
                changeStampMode(stampName: stampType ? "img_ball_black" : "img_pin_black")
            }
        }
        colorTableViewController.dismiss(animated: true)
    }
}

extension AddNewLessonViewController: ObjectTableViewControllerDelegate {
    func ObjectTableViewController(objectTableViewController: ObjectTableViewController, didSelectObject: ObjectType) {
        switch didSelectObject {
        case .pen:
            sketchView.drawTool = .pen
            sketchView.drawingPenType = .normal
            sketchView.lineAlpha = 1
            sketchView.lineWidth = 4
        case .line:
            sketchView.drawTool = .line
            sketchView.lineAlpha = 0.8
            sketchView.lineWidth = 4
        case .arrow:
            sketchView.drawTool = .arrow
            sketchView.lineAlpha = 0.8
            sketchView.lineWidth = 4
        case .ball:
            sketchView.drawTool = .stamp
            switch sketchView.lineColor {
            case .yellow:
                changeStampMode(stampName: "img_ball_yellow")
            case .red:
                changeStampMode(stampName: "img_ball_red")
            case .blue:
                changeStampMode(stampName: "img_ball_blue")
            default:
                changeStampMode(stampName: "img_ball_black")
            }

            stampType = true

        case .pin:
            sketchView.drawTool = .stamp
            switch sketchView.lineColor {
            case .yellow:
                changeStampMode(stampName: "img_pin_yellow")
            case .red:
                changeStampMode(stampName: "img_pin_red")
            case .blue:
                changeStampMode(stampName: "img_pin_blue")
            default:
                changeStampMode(stampName: "img_pin_black")
            }

            stampType = false

        case .rect:
            sketchView.drawTool = .rectangleFill
            sketchView.lineAlpha = 0.3
            sketchView.lineWidth = 2

        case .fill:
            sketchView.drawTool = .fill

        }
        objectTableViewController.dismiss(animated: true)
    }
}
