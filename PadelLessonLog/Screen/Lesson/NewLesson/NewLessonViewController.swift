//
//  NewLessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

class NewLessonViewController: BaseViewController {

    @IBOutlet weak var lessonNameTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var addStepButton: UIButton!
    @IBOutlet weak var editStepButton: UIButton!
    @IBOutlet weak var mainTableView: UITableView!
    
    private let viewModel = NewLessonViewModel()
    private let validationManager = ValidationManager.shared
 
    private var cancellables = Set<AnyCancellable>()
    
    var lessonData: Lesson?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lessonNameTextField.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        mainTableView.tableFooterView = UIView()
        addImageButton.isSelected = false
        editImageButton.isHidden = true
        
        lessonNameTextField.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: .checkmark, select: #selector(save))
        
        viewModel.$addImageButtonIsSelected
            .sink { [self] (isSelected) in
                guard isSelected != addImageButton.isSelected else { return }
                addImageButton.isSelected.toggle()
                addImageButton.tintColor = isSelected ? .systemRed : .systemBlue
                editImageButton.isHidden = !addImageButton.isSelected
                if isSelected {
                    let storyboard = UIStoryboard(name: "AddNewLesson", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "AddNewLesson")
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    infoAlertViewWithTitle(title: "画像を削除しました")
                }
            }
            .store(in: &cancellables)
    }

    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        viewModel.addImageButtonIsSelected = !addImageButton.isSelected
    }
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddNewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddNewLesson")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func addStepButtonPressed(_ sender: UIButton) {
        viewModel.tableViewCellNum += 1
        mainTableView.reloadData()
        if editStepButton.isSelected {
            editStepButton.isSelected = false
            mainTableView.setEditing(false, animated: true)
        }
    }
    @IBAction func editStepButtonPressed(_ sender: UIButton) {
        editStepButton.isSelected = !editStepButton.isSelected
        mainTableView.setEditing(!mainTableView.isEditing, animated: true)
    }
    
    @objc
    func save() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension NewLessonViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let result: ValidationResult = validationManager.validate(textField.text ?? "")
        if result != .valid {
            self.warningAlertView(withTitle: "グループ名が登録できません")
        }
    }
}

extension NewLessonViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        let result: ValidationResult = validationManager.validate(textView.text ?? "")
        if result != .valid {
            self.warningAlertView(withTitle: "グループ名が登録できません")
        }
    }
    
    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            mainTableView.contentInset = .zero
        } else {
            mainTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        mainTableView.scrollIndicatorInsets = mainTableView.contentInset
    }
}

extension NewLessonViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewCellNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewLessonCell", for: indexPath)
        let numLabel = cell.contentView.viewWithTag(1) as? UILabel
        let textView = cell.contentView.viewWithTag(2) as? UITextView
        textView?.delegate = self
        
        numLabel?.text = String(indexPath.row + 1)

        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.tableViewCellNum -= 1
        mainTableView.deleteRows(at: [indexPath], with: .automatic)
        mainTableView.reloadData()
    }
    
}
