//
//  DetailViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

protocol DetailViewControllerDelegate {
    func pushToEditView(lesson: Lesson)
}

class DetailViewController: UIViewController {

    @IBOutlet weak var stepTableView: UITableView!
    @IBOutlet weak var lessonTitleLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    var lessonData: Lesson?
    
    private var coreDataMangaer = CoreDataManager.shared
    private let viewModel = DetailViewModel()
    var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepTableView.delegate = self
        stepTableView.dataSource = self
        stepTableView.tableFooterView = UIView()

        navigationItem.title = NSLocalizedString("Detail", comment: "")
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage(systemName: "chevron.backward.circle")!, select: #selector(back))
        navigationItem.rightBarButtonItem = createBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.plus")!, select: #selector(edit))
        
        guard let lesson = lessonData else { return }
        lessonTitleLabel.text = lesson.title
        imageButton.isHidden = !lesson.imageSaved
    }

    override func viewWillAppear(_ animated: Bool) {
        if let lesson = lessonData {
            let stpes = lesson.steps?.allObjects as? [LessonStep]
            guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
            viewModel.tableViewCellNum = safeSteps.count
            viewModel.tableViewCellData = safeSteps
        }
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        guard let lesson = lessonData else { return }
        let storyboard = UIStoryboard(name: "ImageView", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ImageView")
        if let imageVC = vc as? ImageViewController {
            imageVC.lesson = lesson
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc
    func back() {
        self.dismiss(animated: true)
    }
    @objc
    func edit() {
        guard let lesson = lessonData else { return }
        self.dismiss(animated: true) {
            self.delegate?.pushToEditView(lesson: lesson)
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewCellNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        let stepLabel = cell.contentView.viewWithTag(1) as! UILabel
        var data: LessonStep?
        for step in viewModel.tableViewCellData where step.orderNum == indexPath.row {
            data = step
        }
        guard let safeData = data else { fatalError() }
        stepLabel.text = safeData.explication
        return cell
    }
}


