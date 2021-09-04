//
//  ImageViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var lesson: Lesson?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage(systemName: "chevron.backward.circle")!, select: #selector(back))
        navigationItem.rightBarButtonItem = createBarButtonItem(image: UIImage(systemName: "pencil.circle")!, select: #selector(editImage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let safeLesson = lesson else { return }
        imageView.image = safeLesson.getImage()
    }
    
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
    @objc
    func editImage() {
        guard let safeLesson = lesson else { return }
        let storyboard = UIStoryboard(name: "AddNewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddNewLesson")
        if let addNewLessonVC = vc as? AddNewLessonViewController {
            addNewLessonVC.lessonImage = safeLesson.getImage()
            addNewLessonVC.lessonID = safeLesson.id!.uuidString
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
