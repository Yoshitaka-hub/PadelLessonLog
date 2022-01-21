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
        
        starButton.isSelected.toggle()
        starButton.tintColor = safeLesson.favorite ? .systemYellow : .lightGray
    }
}
