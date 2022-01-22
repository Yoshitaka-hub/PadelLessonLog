//
//  TechniqueViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

final class LessonDataViewController: BaseViewController {
    
    @IBOutlet private weak var customTableView: UITableView!
    @IBOutlet private weak var customToolbar: UIToolbar!
    @IBOutlet private weak var allBarButton: UIBarButtonItem!
    @IBOutlet private weak var favoriteBarButton: UIBarButtonItem!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchButton: UIBarButtonItem!
    
    private let viewModel = LessonDataViewModel()
    
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
        allBarButton.style = .done
        favoriteBarButton.style = .done
        
        customTableView.register(UINib(nibName: "DataTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        
        if let tabBarCon = parent as? UITabBarController {
            tabBarCon.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage.gearshape, select: #selector(setting))
            tabBarCon.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage.plusCircle, select: #selector(addNewLesson))
        }
        searchBar.delegate = self
        searchBar.isHidden = true
        searchBar.autocapitalizationType = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allButtonPressed(allBarButton)
    }
    
    override func bind() {
        viewModel.allBarButtonIsOn
            .map { $0 ? .colorButtonOn : .colorButtonOff }
            .assign(to: \.tintColor, on: allBarButton)
            .store(in: &subscriptions)
        
        viewModel.favoriteBarButtonIsOn.sink { [weak self] isOn in
            guard let self = self else { return }
            self.favoriteBarButton.tintColor = isOn ? .colorButtonOn : .colorButtonOff
        }.store(in: &subscriptions)
        
        viewModel.transiton.sink { [weak self] transition in
            guard let self = self else { return }
            switch transition {
            case .setting:
                let storyboard = UIStoryboard(name: "Setting", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "Setting")
                self.navigationController?.pushViewController(vc, animated: true)
            case let .lesson(lessonData, isNew):
                let storyboard = UIStoryboard(name: "NewLesson", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "NewLesson")
                guard let newLessonVC = vc as? NewLessonViewController else { return }
                newLessonVC.lessonData = lessonData
                newLessonVC.delegate = self
                
                if isNew {
                    newLessonVC.navigationItem.title = R.string.localizable.createNewData()
                } else {
                    newLessonVC.navigationItem.title = R.string.localizable.editData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            case .arView:
                guard let vc = R.storyboard.padelAR.padelAR() else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            case let .detail(lessonData):
                let storyboard = UIStoryboard(name: "Detail", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "Detail")
                guard let detailVC = vc as? DetailViewController else { return }
                detailVC.lessonData = lessonData
                detailVC.delegate = self
                
                let nvc = UINavigationController(rootViewController: vc)
                self.present(nvc, animated: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.lessonsArray.sink { [weak self] _ in
            guard let self = self else { return }
            self.customTableView.reloadData()
        }.store(in: &subscriptions)
        
        viewModel.scrollToTableIndex.sink { [weak self] tableIndex in
            guard let self = self else { return }
            self.customTableView.scrollToRow(at: IndexPath(row: tableIndex, section: 0), at: .top, animated: true)
        }.store(in: &subscriptions)
    }
    
    override func setting() {
        viewModel.settingButtonPressed.send()
    }
    
    override func addNewLesson() {
        viewModel.addLessonButtonPressed.send()
    }
    
    @IBAction private func searchButtonPressed(_ sender: UIBarButtonItem) {
        searchBar.isHidden.toggle()
        searchButton.tintColor = searchBar.isHidden ? UIColor.colorButtonOff : UIColor.colorButtonOn
        if searchBar.isHidden {
            viewModel.dataReload.send()
        }
    }
    @IBAction private func allButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.allButtonPressed.send()
    }
    @IBAction private func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.favoriteButtonPressed.send()
    }
}

extension LessonDataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lessonsArray.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! DataTableViewCell
        customCell.setLessonData(lesson: viewModel.lessonsArray.value[indexPath.row])
        return customCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt.send(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return viewModel.tableMode.value == .allTableView
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.reorderData.send((sourceIndexPath, destinationIndexPath))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension LessonDataViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.dataReload.send()
        guard let text = searchBar.text else { return }
        if !text.isEmpty {
            viewModel.searchAndFilterData.send(text)
        }
    }
}

extension LessonDataViewController: DetailViewControllerDelegate {
    func pushToEditView(lesson: Lesson) {
        viewModel.pushToEditLessonView.send(lesson)
    }
}

extension LessonDataViewController: NewLessonViewControllerDelegate {
    func pushToLessonView() {
        viewModel.pushBackFromNewLessonView.send()
    }
}
