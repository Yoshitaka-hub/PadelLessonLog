//
//  TechniqueViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

class TechniqueViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configureToolbar() {
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var buttonItems: [UIBarButtonItem] = [flexibleSpace]
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewLesson))
        buttonItems.append(addButtonItem)
        buttonItems.append(flexibleSpace)
        
//        customToolbar.setItems(buttonItems, animated: true)
    }
    
    @objc
    func addNewLesson() {
    }
    

}
