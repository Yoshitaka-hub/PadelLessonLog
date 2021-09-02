//
//  DataTableViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/02.
//

import UIKit

class DataTableViewCell: UITableViewCell {

    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var lesson: Lesson?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLessonData(lesson: Lesson) {
        self.lesson = lesson
        titleLabel.text = lesson.title
        starButton.isSelected = lesson.favorite
        starButton.tintColor = lesson.favorite ? .systemYellow : .lightGray
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        guard let safeLesson = lesson else { return }
        safeLesson.favorite = !starButton.isSelected
        safeLesson.save()
        
        starButton.isSelected = !starButton.isSelected
        starButton.tintColor = safeLesson.favorite ? .systemYellow : .lightGray
    }
}
