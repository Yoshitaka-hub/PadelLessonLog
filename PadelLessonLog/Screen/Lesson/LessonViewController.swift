//
//  LessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit

class LessonViewController: UIViewController {

    @IBOutlet weak var customToolbar: UIToolbar!
    @IBOutlet weak var titleBarButton: UIBarButtonItem!
    @IBOutlet weak var imageBarButton: UIBarButtonItem!
    
    @IBOutlet weak var customCollectionView: UICollectionView!
    
    private var mode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.systemBackground
        customToolbar.barStyle = .default
        
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
        
        customCollectionView.register(UINib(nibName: "TitleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TitleCell")
        customCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        customCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    @IBAction func titleBarButtonPressed(_ sender: UIBarButtonItem) {
        mode = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        customCollectionView.setCollectionViewLayout(layout, animated: true)
        customCollectionView.reloadData()
    }
    @IBAction func imageBarButtonPressed(_ sender: UIBarButtonItem) {
        mode = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        customCollectionView.setCollectionViewLayout(layout, animated: true)
        customCollectionView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "NewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "NewLesson")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LessonViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if mode {
            let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath)
            guard let titelCell = customCell as? TitleCollectionViewCell else { return customCell }
            titelCell.titleLabel.text = "タイトル"
            return titelCell
        } else {
            let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
            guard let imageCell = customCell as? ImageCollectionViewCell else { return customCell }
            imageCell.titleLabel.text = "イメージ"
            imageCell.lessonImageView.image = UIImage(named: "img_court")
            return imageCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if mode {
            return CGSize(width: collectionView.frame.width, height: 60)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
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
