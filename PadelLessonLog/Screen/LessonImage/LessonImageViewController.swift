//
//  LessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit
import Combine

final class LessonImageViewController: BaseViewController {

    @IBOutlet weak var customToolbar: UIToolbar!
    @IBOutlet weak var allBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var arBarButton: UIBarButtonItem!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var customCollectionView: UICollectionView!
    
    private let viewModel = LessonImageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = .colorButtonOn
        UITabBar.appearance().unselectedItemTintColor = .colorButtonOff
        
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.systemBackground
        customToolbar.barStyle = .default
        allBarButton.style = .done
        favoriteBarButton.style = .done
        
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
        
        customCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        customCollectionView.setCollectionViewLayout(layout, animated: true)
        
        if let tabBarCon = parent as? UITabBarController {
            tabBarCon.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage.gearshape, select: #selector(setting))
            tabBarCon.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage.plusCircle, select: #selector(addNewLesson))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.allButtonPressed.send()
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
        
        viewModel.detailButtonIsHidden
            .assign(to: \.isHidden, on: detailButton)
            .store(in: &subscriptions)
        
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
            self.customCollectionView.reloadData()
        }.store(in: &subscriptions)
        
        viewModel.scrollToCellIndex.sink { [weak self] cellIndex in
            guard let self = self else { return }
            self.customCollectionView.scrollToItem(at: IndexPath(item: cellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }.store(in: &subscriptions)
    }
    
    override func setting() {
        viewModel.settingButtonPressed.send()
    }
    
    override func addNewLesson() {
        viewModel.addLessonButtonPressed.send()
    }
    
    @IBAction func allButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.allButtonPressed.send()
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.favoriteButtonPressed.send()
    }
    
    @IBAction func arButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.arButtonPressed.send()
    }
    @IBAction func detailButtonPressed(_ sender: UIButton) {
        let cell = self.customCollectionView.visibleCells.first as? ImageCollectionViewCell
        guard let safeCell = cell else { return }
        guard let lesson = safeCell.lesson else { return }
        viewModel.detailButtonPressed.send(lesson)
    }
}

extension LessonImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.lessonsArray.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        guard let imageCell = customCell as? ImageCollectionViewCell else { return customCell }
        imageCell.setLessonData(lesson: viewModel.lessonsArray.value[indexPath.row], row: indexPath.row)
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.scrollViewDidTouch.send(scrollView.contentOffset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.scrollViewDidScroll.send(scrollView.contentOffset)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = customCollectionView.visibleCells
        var indexArray: [Int] = []
        for cell in cells {
            guard let safeCell = cell as? ImageCollectionViewCell else { return }
            indexArray.append(safeCell.row ?? 0)
        }
        guard !indexArray.isEmpty else { return }
        viewModel.scrollViewDidStop.send(indexArray)
    }
}

extension LessonImageViewController: DetailViewControllerDelegate {
    func pushToEditView(lesson: Lesson) {
        viewModel.pushToEditLessonView.send(lesson)
    }
}

extension LessonImageViewController: NewLessonViewControllerDelegate {
    func pushToLessonView() {
        viewModel.pushBackFromNewLessonView.send()
    }
}
