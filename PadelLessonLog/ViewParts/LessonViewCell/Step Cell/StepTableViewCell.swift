//
//  StepTableViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

protocol InputTextTableCellDelegate: AnyObject {
    func textViewDidEndEditing(cell: StepTableViewCell, value: String)
    func textViewDidBeingEditing(index: Int?)
}

final class StepTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet private weak var cellLabel: UILabel!
    @IBOutlet private  weak var stepTextView: UITextView! {
        didSet {
            stepTextView.delegate = self
        }
    }
    
    var index: Int?
    var stepData: LessonStep?
    weak var delegate: InputTextTableCellDelegate?
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.textViewDidBeingEditing(index: index)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing(cell: self, value: stepTextView.text)
    }

    func setup(index: Int, stepData: LessonStep) {
        self.stepData = stepData
        self.index = index
        cellLabel.text = String(index + 1)
        stepTextView.text = stepData.explication
    }
}
