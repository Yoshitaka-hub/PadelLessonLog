//
//  LessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit

class LessonImageViewController: UIViewController {

    @IBOutlet weak var customToolbar: UIToolbar!
    @IBOutlet weak var allBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var detailButton: UIButton!
    
    @IBOutlet weak var customCollectionView: UICollectionView!
    
    private var coreDataMangaer = CoreDataManager.shared
    private var lessonsArray = [Lesson]()

    var scrollBeginingPoint: CGPoint!
    var scrollDirection: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = .colorButtonOn
        UITabBar.appearance().unselectedItemTintColor = .colorButtonOff
        
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.systemBackground
        customToolbar.barStyle = .default
        allBarButton.tintColor = .colorButtonOn
        allBarButton.style = .done
        favoriteBarButton.tintColor = .colorButtonOff
        favoriteBarButton.style = .done
        
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
        
        customCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        customCollectionView.setCollectionViewLayout(layout, animated: true)
        
        if let tabBarCon = parent as? UITabBarController {
            tabBarCon.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "gearshape")!, select: #selector(setting))
            tabBarCon.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "plus.circle")!, select: #selector(addNewLesson))
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lessonsArray = coreDataMangaer.loadAllLessonDataWithImage()
        customCollectionView.reloadData()
        allBarButton.tintColor = .colorButtonOn
        favoriteBarButton.tintColor = .colorButtonOff
    }
    
    @objc
    func setting() {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Setting")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func addNewLesson() {
        let storyboard = UIStoryboard(name: "NewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "NewLesson")
        if let newLessonVC = vc as? NewLessonViewController {
            newLessonVC.lessonData = coreDataMangaer.createNewLesson(image: UIImage(named: "img_court")!, steps: [""])
            newLessonVC.delegate = self
            newLessonVC.navigationItem.title = NSLocalizedString("Create New Data", comment: "")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func allButtonPressed(_ sender: UIBarButtonItem) {
        lessonsArray = coreDataMangaer.loadAllLessonDataWithImage()
        customCollectionView.reloadData()
        allBarButton.tintColor = .colorButtonOn
        favoriteBarButton.tintColor = .colorButtonOff
    }
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        lessonsArray = coreDataMangaer.loadAllFavoriteLessonDataWithImage()
        customCollectionView.reloadData()
        favoriteBarButton.tintColor = .colorButtonOn
        allBarButton.tintColor = .lightGray
    }
    @IBAction func detailButtonPressed(_ sender: UIButton) {
        let cell = customCollectionView.visibleCells.first as? ImageCollectionViewCell
        guard let safeCell = cell else { return }
        guard let lesson = safeCell.lesson else { return }
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Detail")
        if let detailVC = vc as? DetailViewController {
            detailVC.lessonData = lesson
            detailVC.delegate = self
        }
        let nvc = UINavigationController.init(rootViewController: vc)
        self.present(nvc, animated: true)
    }
}

extension LessonImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        guard let imageCell = customCell as? ImageCollectionViewCell else { return customCell }
        imageCell.setLessonData(lesson: lessonsArray[indexPath.row], row: indexPath.row)
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = customCollectionView.visibleCells
        var indexArray: [Int] = []
        var indexRow: Int?
        for cell in cells {
            guard let safeCell = cell as? ImageCollectionViewCell else { return }
            indexArray.append(safeCell.row ?? 0)
        }
        guard !indexArray.isEmpty else { return }
        if scrollDirection {
            indexRow = indexArray.max()
        } else {
            indexRow = indexArray.min()
        }
        customCollectionView.scrollToItem(at: IndexPath(item: indexRow ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        detailButton.isHidden = false
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset;
        detailButton.isHidden = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset;
        if scrollBeginingPoint.x < currentPoint.x {
            scrollDirection = true
        } else {
            scrollDirection = false
        }
    }
}

extension LessonImageViewController: DetailViewControllerDelegate {
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

extension LessonImageViewController: NewLessonViewControllerDelegate {
    func pushToLessonImageView() {
        customCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
    }
}


