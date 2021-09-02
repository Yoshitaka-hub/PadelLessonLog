//
//  TechniqueViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

class LessonDataViewController: UIViewController {

    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var customToolbar: UIToolbar!
    @IBOutlet weak var allBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    private var coreDataMangaer = CoreDataManager.shared
    private var lessonsArray = [Lesson]()
    
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
        allBarButton.tintColor = .blue
        favoriteBarButton.tintColor = .lightGray
        
        customTableView.register(UINib(nibName: "DataTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        lessonsArray = coreDataMangaer.loadAllLessonData()
        customTableView.reloadData()
        allBarButton.tintColor = .blue
        favoriteBarButton.tintColor = .lightGray
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    }
    @IBAction func allButtonPressed(_ sender: UIBarButtonItem) {
        lessonsArray = coreDataMangaer.loadAllLessonData()
        customTableView.reloadData()
        allBarButton.tintColor = .blue
        favoriteBarButton.tintColor = .lightGray
    }
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        lessonsArray = coreDataMangaer.loadAllFavoriteLessonData()
        customTableView.reloadData()
        favoriteBarButton.tintColor = .blue
        allBarButton.tintColor = .lightGray
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
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
