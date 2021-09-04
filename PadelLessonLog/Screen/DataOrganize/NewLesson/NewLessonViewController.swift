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
    private var coreDataMangaer = CoreDataManager.shared
 
    private var cancellables = Set<AnyCancellable>()
    
    var lessonData: Lesson?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lessonNameTextField.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib(nibName: "StepTableViewCell", bundle: nil), forCellReuseIdentifier: "StepCell")
        
        mainTableView.tableFooterView = UIView()
        addImageButton.isSelected = false
        editImageButton.isHidden = true
        
        lessonNameTextField.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: .remove, select: #selector(deleteData))
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: .checkmark, select: #selector(save))
        
        if let lesson = lessonData {
            lessonNameTextField.text = lesson.title
            let steps = coreDataMangaer.featchSteps(lessonID: lesson.id!.uuidString)
            viewModel.tableViewCellNum = steps.count
            if !steps.isEmpty {
                for step in steps {
                    viewModel.tableViewCellString.append(step.explication ?? "")
                }
            }
        }
        
        viewModel.$addImageButtonIsSelected
            .sink { [self] (isSelected) in
                guard isSelected != addImageButton.isSelected else { return }
                addImageButton.isSelected.toggle()
                addImageButton.tintColor = isSelected ? .systemRed : .systemBlue
                editImageButton.isHidden = !addImageButton.isSelected
                if isSelected {
                    pushToAddNewLessonVC()
                } else {
                    guard let id = lessonData?.id?.uuidString else { return }
                    let isSaved = coreDataMangaer.resetLessonImage(lessonID: id, image: UIImage(named: "img_court")!)
                    if isSaved {
                        lessonData = coreDataMangaer.loadLessonData(lessonID: id)
                        infoAlertViewWithTitle(title: "Image deleted")
                    } else {
                        fatalError("画像が更新できない")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let flag = lessonData?.imageSaved else { return }
        addImageButton.isSelected = flag
        addImageButton.tintColor = flag ? .systemRed : .systemBlue
        editImageButton.isHidden = !flag
    }

    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        viewModel.addImageButtonIsSelected = !addImageButton.isSelected
    }
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        pushToAddNewLessonVC()
    }
    @IBAction func addStepButtonPressed(_ sender: UIButton) {
        guard let lesson = lessonData else { return }
        coreDataMangaer.createStep(lesson: lesson)
        viewModel.tableViewCellNum += 1
        viewModel.tableViewCellString.append("")
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
    func deleteData() {
        guard let id = lessonData?.id?.uuidString else { return }
        if coreDataMangaer.deleteLessonData(lessonID: id) {
            self.navigationController?.popViewController(animated: true)
        } else {
            fatalError("fail to delete")
        }
    }
    
    @objc
    func save() {
        guard let id = lessonData?.id?.uuidString else { return }
        let title = lessonNameTextField.text ?? ""
        if coreDataMangaer.updateLessonTitle(lessonID: id, title: title) {
            self.navigationController?.popViewController(animated: true)
        } else {
            fatalError("steps saving failed")
        }
    }
}

extension NewLessonViewController {
    func pushToAddNewLessonVC() {
        let storyboard = UIStoryboard(name: "AddNewLesson", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddNewLesson")
        if let addNewLessonVC = vc as? AddNewLessonViewController {
            guard let data = lessonData else { return }
            addNewLessonVC.lessonImage = data.getImage()
            addNewLessonVC.lessonID = data.id?.uuidString
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NewLessonViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let result: ValidationResult = validationManager.validate(textField.text ?? "")
        if result != .valid {
            self.warningAlertView(withTitle: "登録できません")
        }
    }
}

extension NewLessonViewController: UITextViewDelegate {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as! StepTableViewCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.cellLabel.text = String(indexPath.row + 1)
        cell.stepTextView.text = viewModel.tableViewCellString[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let lesson = lessonData else { return }
        let stpes = lesson.steps?.allObjects as? [LessonSteps]
        guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
        
        var deleteStep: LessonSteps?
        for step in safeSteps where step.number == Int16(indexPath.row) {
            deleteStep = step
        }
        if let step = deleteStep {
            coreDataMangaer.deleteStep(lesson: lesson, step: step, stpes: safeSteps)
        }
        viewModel.tableViewCellNum -= 1
        viewModel.tableViewCellString.remove(at: indexPath.row)
        
//        mainTableView.deleteRows(at: [indexPath], with: .automatic)
        mainTableView.reloadData()
    }
}

extension NewLessonViewController: InputTextTableCellDelegate {
    func textViewDidEndEditing(cell: StepTableViewCell, value: String) {
//        let result: ValidationResult = validationManager.validate(value)
//        if result != .valid {
//            self.warningAlertView(withTitle: "保存できません")
//            return
//        }
        guard let lesson = lessonData else { return }
        let stpes = lesson.steps?.allObjects as? [LessonSteps]
        guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
        guard let num = cell.index else { return }
        for step in safeSteps where step.number == Int16(num) {
            step.explication = value
            step.save()
        }
    }
}
