//
//  NewLessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

protocol NewLessonViewControllerDelegate {
    func pushToLessonImageView()
}

class NewLessonViewController: BaseViewController {

    @IBOutlet weak var lessonNameTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var addStepButton: UIButton!
    @IBOutlet weak var editStepButton: UIButton!
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var imageButtonsAreaView: UIView!
    
    private let viewModel = NewLessonViewModel()
    private var coreDataMangaer = CoreDataManager.shared

    private var cancellables = Set<AnyCancellable>()
    
    var lessonData: Lesson?

    var delegate: NewLessonViewControllerDelegate?
    
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
        self.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "trash.circle")!, color: .red, select: #selector(deleteData))
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "checkmark.circle")!, select: #selector(save))
        
        if let lesson = lessonData {
            lessonNameTextField.text = lesson.title
            let stpes = lesson.steps?.allObjects as? [LessonStep]
            guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
            viewModel.tableViewCellNum = safeSteps.count
            viewModel.tableViewCellData = safeSteps
        }
        
        viewModel.$addImageButtonIsSelected
            .sink { [self] (isSelected) in
                guard isSelected != addImageButton.isSelected else { return }
                if isSelected {
                    pushToAddNewLessonVC()
                } else {
                    destructiveAlertView(withTitle: NSLocalizedString("Are you sure?", comment: ""), cancelString: NSLocalizedString("Cancel", comment: ""), destructiveString: NSLocalizedString("Delete", comment: "")) {
                        guard let id = lessonData?.id?.uuidString else { return }
                        let isSaved = coreDataMangaer.resetLessonImage(lessonID: id, image: UIImage(named: "img_court")!)
                        if isSaved {
                            lessonData = coreDataMangaer.loadLessonData(lessonID: id)
                            infoAlertViewWithTitle(title: NSLocalizedString("Image deleted", comment: ""))
                            addImageButton.isSelected.toggle()
                            addImageButton.tintColor = isSelected ? .systemRed : .systemBlue
                            editImageButton.isHidden = !addImageButton.isSelected
                        } else {
                            fatalError("画像が更新できない")
                        }
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
        let stpes = lesson.steps?.allObjects as? [LessonStep]
        guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
        viewModel.tableViewCellNum = safeSteps.count
        viewModel.tableViewCellData = safeSteps
        mainTableView.reloadData()
        if editStepButton.isSelected {
            editStepButton.isSelected = false
            mainTableView.setEditing(false, animated: true)
        }
        mainTableView.scrollToRow(at: IndexPath(row: viewModel.tableViewCellNum - 1, section: 0) , at: .top, animated: true)
    }
    @IBAction func editStepButtonPressed(_ sender: UIButton) {
        editStepButton.isSelected = !editStepButton.isSelected
        mainTableView.setEditing(!mainTableView.isEditing, animated: true)
    }
    @objc
    func deleteData() {
        destructiveAlertView(withTitle: NSLocalizedString("Data will be deleted", comment: ""), cancelString: NSLocalizedString("Cancel", comment: ""), destructiveString: NSLocalizedString("Delete", comment: "")) {
            guard let id = self.lessonData?.id?.uuidString else { return }
            if self.coreDataMangaer.deleteLessonData(lessonID: id) {
                self.infoAlertViewWithTitle(title: NSLocalizedString("Data deleted", comment: ""), message: "") {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                fatalError("データ削除失敗")
            }
        }
    }
    
    @objc
    func save() {
        let title = lessonNameTextField.text ?? ""
        let emptyCheck = ValidationManager()
        emptyCheck.emptyFlag = true
        let result: ValidationResult = emptyCheck.validate(title)
        if result != .valid {
            self.warningAlertView(withTitle: NSLocalizedString("The title is blank", comment: ""))
            return
        }
        guard let id = lessonData?.id?.uuidString else { return }
        if coreDataMangaer.updateLessonTitle(lessonID: id, title: title) {
            if let safeDelegate = delegate {
                safeDelegate.pushToLessonImageView()
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            fatalError("ステップ削除失敗")
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
        guard let text = textField.text else { return }
        guard text != "" else { return }
        let validationManager = ValidationManager()
        validationManager.maxTextNum = 40
        validationManager.emptyFlag = false
        let result: ValidationResult = validationManager.validate(text)
        if result != .valid {
            let dif = (textField.text?.count ?? validationManager.maxTextNum) - validationManager.maxTextNum
            if dif > 0 {
                let dropedText = textField.text?.dropLast(dif)
                lessonNameTextField.text = dropedText?.description
                self.warningAlertView(withTitle: NSLocalizedString("The number of characters is exceeded", comment: ""))
            } else {
                self.warningAlertView(withTitle: NSLocalizedString("Illegal characters are used", comment: ""))
            }
        }
    }
}

extension NewLessonViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewCellNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as! StepTableViewCell
        var data: LessonStep?
        for step in viewModel.tableViewCellData where step.orderNum == indexPath.row {
            data = step
        }
        guard let safeData = data else { fatalError() }
        cell.delegate = self
        cell.setup(index: indexPath.row, stepData: safeData)
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard viewModel.tableViewCellData.count > 1 else { return }
        guard let lesson = lessonData else { return }
        var deleteStep: LessonStep?
        for step in viewModel.tableViewCellData where step.orderNum == indexPath.row {
            deleteStep = step
        }
        if let step = deleteStep {
            coreDataMangaer.deleteStep(lesson: lesson, step: step, stpes: viewModel.tableViewCellData)
        }
        let stpes = lesson.steps?.allObjects as? [LessonStep]
        guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
        viewModel.tableViewCellNum = safeSteps.count
        viewModel.tableViewCellData = safeSteps
        mainTableView.reloadData()
    }
}

extension NewLessonViewController: InputTextTableCellDelegate {
    func textViewDidBeingEditing(index: Int?) {
        guard let cellIndex = index else { return }
        mainTableView.scrollToRow(at: IndexPath(row: cellIndex, section: 0), at: .top, animated: true)
        guard let view = imageButtonsAreaView else { return }
        view.isHidden = true
    }
    
    func textViewDidEndEditing(cell: StepTableViewCell, value: String) {
        guard let data = cell.stepData else { return }
        data.explication = value
        data.save()
        guard let view = imageButtonsAreaView else { return }
        view.isHidden = false
    }
}
