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

class LessonDataViewController: BaseViewController {
    
    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var customToolbar: UIToolbar!
    @IBOutlet weak var allBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
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
        
        if let tabBarCon = parent as? UITabBarController {
            tabBarCon.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "gearshape")!, select: #selector(setting))
            tabBarCon.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "plus.circle")!, select: #selector(addNewLesson))
        }
        searchBar.delegate = self
        searchBar.isHidden = true
        searchBar.autocapitalizationType = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allButtonPressed(allBarButton)
    }
    
    override func setting() {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Setting")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func addNewLesson() {
        let storyboard = UIStoryboard(name: "NewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "NewLesson")
        if let newLessonVC = vc as? NewLessonViewController {
            newLessonVC.lessonData = coreDataMangaer.createNewLesson(image: UIImage(named: "img_court")!, steps: [""])
            newLessonVC.delegate = self
            newLessonVC.navigationItem.title = NSLocalizedString("Create New Data", comment: "")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        searchBar.isHidden = !searchBar.isHidden
        searchButton.tintColor = searchBar.isHidden ? UIColor.colorButtonOff : UIColor.colorButtonOn
        if searchBar.isHidden {
            tableDataUpdate()
        }
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
    
    private func tableDataUpdate() {
        let isAllflag = allBarButton.tintColor == .colorButtonOn
        if isAllflag {
            lessonsArray = coreDataMangaer.loadAllLessonData()
        } else {
            lessonsArray = coreDataMangaer.loadAllFavoriteLessonData()
        }
        customTableView.reloadData()
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

extension LessonDataViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableDataUpdate()
        guard let text = searchBar.text else { return }
        if !text.isEmpty {
            lessonsArray = lessonsArray.filter {
                guard let titel = $0.title else { return false }
                return titel.contains(text)
            }
            customTableView.reloadData()
        }
    }
}

extension LessonDataViewController: NewLessonViewControllerDelegate {
    func pushToLessonImageView() {
        if !lessonsArray.isEmpty {
            customTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
