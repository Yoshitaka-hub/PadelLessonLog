//
//  StepTableViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

protocol InputTextTableCellDelegate {
    func textViewDidEndEditing(cell: StepTableViewCell, value: String)
}

class StepTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var stepTextView: UITextView! {
        didSet {
            stepTextView.delegate = self
        }
    }
    
    var index: Int?
    var delegate: InputTextTableCellDelegate?
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing(cell: self, value: stepTextView.text)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
