//
//  DetailViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var stepTableView: UITableView!
    @IBOutlet weak var lessonTitleLabel: UILabel!
    
    var lessonData: Lesson?
    
    private var coreDataMangaer = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepTableView.delegate = self
        stepTableView.dataSource = self
        stepTableView.tableFooterView = UIView()
        
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage(systemName: "chevron.backward.circle")!, select: #selector(back))
    }
    
    @objc
    func back() {
        self.dismiss(animated: true)
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lesson = lessonData else {
            return 0
        }
        let steps = coreDataMangaer.featchSteps(lessonID: lesson.id!.uuidString)
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        let stepLabel = cell.contentView.viewWithTag(1) as! UILabel
        
        guard let lesson = lessonData else { return cell }
        guard let steps = lesson.steps?.allObjects as? [LessonSteps] else { return cell }
        stepLabel.text = steps[indexPath.row].explication
        
        lessonTitleLabel.text = lesson.title
        return cell
    }
}


