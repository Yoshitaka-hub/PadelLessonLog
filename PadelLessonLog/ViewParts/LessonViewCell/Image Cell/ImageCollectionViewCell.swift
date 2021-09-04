//
//  ImageCollectionViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lessonImageView: UIImageView!
    var lesson: Lesson?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setLessonData(lesson: Lesson) {
        self.lesson = lesson
        titleLabel.text = lesson.title
        lessonImageView.image = lesson.getImage()
    }
}
