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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()
        // Do any additional setup after loading the view.
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
        let commentButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(comment))
        buttonItems.append(commentButtonItem)
        buttonItems.append(flexibleSpace)
        
        customToolbar.setItems(buttonItems, animated: true)
    }
    
    @objc
    func save() {
    }
    @objc
    func comment() {
    }

}
