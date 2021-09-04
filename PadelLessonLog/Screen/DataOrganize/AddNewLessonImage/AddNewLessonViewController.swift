//
//  AddNewLessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit

class AddNewLessonViewController: UIViewController {

    @IBOutlet weak var courtImageView: UIImageView!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var customToolbar: UIToolbar!
    
    private var viewModel = AddNewLessonViewModel()
    
    private var coreDataMangaer = CoreDataManager.shared
    var lessonID: String?
    var lessonImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courtImageView.image = lessonImage
        configureToolbar()
        
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage(systemName: "chevron.backward.circle")!, select: #selector(back))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        drawingView.setup()
    }
    
    func configureToolbar() {
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.gray
        customToolbar.barStyle = .default
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var buttonItems: [UIBarButtonItem] = [flexibleSpace]
        
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        buttonItems.append(doneButtonItem)
        buttonItems.append(flexibleSpace)
        let commentButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(comment))
        buttonItems.append(commentButtonItem)
        buttonItems.append(flexibleSpace)
        let objectButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(objectTable))
        buttonItems.append(objectButtonItem)
        buttonItems.append(flexibleSpace)
        let colorButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(colorTable))
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
        guard let image = courtImageView.image else { return }
        let savingImage = drawingView.drawIntoImage(image: image)
        let isSaved = coreDataMangaer.updateLessonImage(lessonID: id, image: savingImage)
        if isSaved {
            navigationController?.popViewController(animated: true)
        } else {
            fatalError("画像が更新できない")
        }
    }
    @objc
    func comment() {
        if !drawingView.objectViews.isEmpty {
            drawingView.objectViews = drawingView.objectViews.dropLast()
        }
    }
    @objc
    func colorTable() {
        let storyboard = UIStoryboard(name: "ColorTable", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ColorTable")
        if let colorTableVC = vc as? ColorTableViewController {
            colorTableVC.delegate = self
            colorTableVC.objectColor = drawingView.objectColor
        }
        openPopUpController(popUpController: vc, sourceView: customToolbar, rect: CGRect(x: 120, y: 0, width: 150, height: 180), arrowDirections: .down, canOverlapSourceViewRect: true)
    }
    @objc
    func objectTable() {
        let storyboard = UIStoryboard(name: "ObjectTable", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ObjectTable")
        if let objectTableVC = vc as? ObjectTableViewController {
            objectTableVC.delegate = self
            objectTableVC.objectType = drawingView.objectType
        }
        openPopUpController(popUpController: vc, sourceView: customToolbar, rect: CGRect(x: 50, y: 0, width: 150, height: 180), arrowDirections: .down, canOverlapSourceViewRect: true)
    }
}

extension AddNewLessonViewController: ColorTableViewControllerDelegate {
    func ColorTableViewController(colorTableViewController: ColorTableViewController, didSelectColor: ObjectColor) {
        drawingView.objectColor = didSelectColor
        colorTableViewController.dismiss(animated: true)
    }
}

extension AddNewLessonViewController: ObjectTableViewControllerDelegate {
    func ObjectTableViewController(objectTableViewController: ObjectTableViewController, didSelectObject: ObjectType) {
        drawingView.objectType = didSelectObject
        objectTableViewController.dismiss(animated: true)
    }
}
