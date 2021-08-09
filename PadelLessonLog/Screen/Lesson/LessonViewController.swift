//
//  LessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit

class LessonViewController: UIViewController {

    @IBOutlet weak var customToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()
    }
    
    func configureToolbar() {
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.gray
        customToolbar.barStyle = .default
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var buttonItems: [UIBarButtonItem] = [flexibleSpace]
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewLesson))
        buttonItems.append(addButtonItem)
        buttonItems.append(flexibleSpace)
        
        customToolbar.setItems(buttonItems, animated: true)
    }
    
    @objc
    func addNewLesson() {
        let storyboard = UIStoryboard(name: "AddNewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddNewLesson")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
