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
    
    @IBOutlet weak var customCollectionView: UICollectionView!
    
    private var coreDataMangaer = CoreDataManager.shared
    private var lessonsArray = [Lesson]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.systemBackground
        customToolbar.barStyle = .default
        allBarButton.tintColor = .blue
        allBarButton.style = .done
        favoriteBarButton.tintColor = .lightGray
        favoriteBarButton.style = .plain
        
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
        
        customCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        customCollectionView.setCollectionViewLayout(layout, animated: true)
        
        if let tabBarCon = parent as? UITabBarController {
            tabBarCon.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "gearshape")!, select: #selector(setting))
            tabBarCon.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.plus")!, select: #selector(addNewLesson))
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lessonsArray = coreDataMangaer.loadAllLessonData()
        customCollectionView.reloadData()
        allBarButton.tintColor = .blue
        favoriteBarButton.tintColor = .lightGray
    }
    
    @objc
    func setting() {
      
    }
    
    @objc
    func addNewLesson() {
        let storyboard = UIStoryboard(name: "NewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "NewLesson")
        if let newLessonVC = vc as? NewLessonViewController {
            newLessonVC.lessonData = coreDataMangaer.createNewLesson(image: UIImage(named: "img_court")!, steps: [""])
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func allButtonPressed(_ sender: UIBarButtonItem) {
        lessonsArray = coreDataMangaer.loadAllLessonData()
        customCollectionView.reloadData()
        allBarButton.tintColor = .systemBlue
        favoriteBarButton.tintColor = .lightGray
    }
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        lessonsArray = coreDataMangaer.loadAllFavoriteLessonData()
        customCollectionView.reloadData()
        favoriteBarButton.tintColor = .systemBlue
        allBarButton.tintColor = .lightGray
    }
}

extension LessonImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        guard let imageCell = customCell as? ImageCollectionViewCell else { return customCell }
        imageCell.titleLabel.text = lessonsArray[indexPath.row].title
        imageCell.lessonImageView.image = lessonsArray[indexPath.row].getImage()
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}
