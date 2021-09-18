//
//  TechniqueViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

enum TableMode {
    case allTableView
    case favoriteTableView
}

class LessonDataViewController: UIViewController {
    
    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var customToolbar: UIToolbar!
    @IBOutlet weak var allBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    private var coreDataMangaer = CoreDataManager.shared
    private var lessonsArray = [Lesson]()
    private var tableMode: TableMode = .allTableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customTableView.delegate = self
        customTableView.dataSource = self
        customTableView.tableFooterView = UIView()
        customTableView.isEditing = true
        customTableView.allowsSelectionDuringEditing = true
        
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.systemBackground
        customToolbar.barStyle = .default
        allBarButton.tintColor = .colorButtonOn
        allBarButton.style = .done
        favoriteBarButton.tintColor = .colorButtonOff
        favoriteBarButton.style = .done
        
        customTableView.register(UINib(nibName: "DataTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allButtonPressed(allBarButton)
    }
    
    @IBAction func allButtonPressed(_ sender: UIBarButtonItem) {
        tableMode = .allTableView
        
        lessonsArray = coreDataMangaer.loadAllLessonData()
        customTableView.reloadData()
        allBarButton.tintColor = .colorButtonOn
        favoriteBarButton.tintColor = .colorButtonOff
    }
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        tableMode = .favoriteTableView
        
        lessonsArray = coreDataMangaer.loadAllFavoriteLessonData()
        customTableView.reloadData()
        favoriteBarButton.tintColor = .colorButtonOn
        allBarButton.tintColor = .colorButtonOff
    }
}

extension LessonDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! DataTableViewCell
        customCell.setLessonData(lesson: lessonsArray[indexPath.row])
        return customCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Detail")
        if let detailVC = vc as? DetailViewController {
            detailVC.lessonData = lessonsArray[indexPath.row]
            detailVC.delegate = self
        }
        let nvc = UINavigationController.init(rootViewController: vc)
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(nvc, animated: true)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableMode == .allTableView ?  true : false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let lesson = lessonsArray[sourceIndexPath.row]
        lessonsArray.remove(at: sourceIndexPath.row)
        lessonsArray.insert(lesson, at: destinationIndexPath.row)
        coreDataMangaer.updateLessonOrder(lessonArray: lessonsArray)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension LessonDataViewController: DetailViewControllerDelegate {
    func pushToEditView(lesson: Lesson) {
        let storyboard = UIStoryboard(name: "NewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "NewLesson")
        if let newLessonVC = vc as? NewLessonViewController {
            newLessonVC.lessonData = lesson
            newLessonVC.navigationItem.title = NSLocalizedString("Edit Data", comment: "")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
