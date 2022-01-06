//
//  NewLessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

protocol NewLessonViewControllerDelegate {
    func pushToLessonView()
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
    
    var lessonData: Lesson?

    var delegate: NewLessonViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lessonNameTextField.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib(nibName: "StepTableViewCell", bundle: nil), forCellReuseIdentifier: "StepTableViewCellIdentifier")
        
        mainTableView.tableFooterView = UIView()
        addImageButton.isSelected = false
        editImageButton.isHidden = true
        
        lessonNameTextField.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "trash.circle")!, color: .red, select: #selector(deleteData))
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage(systemName: "checkmark.circle")!, select: #selector(save))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.lessonData.send(lessonData)
    }
    
    override func bind() {
        viewModel.lessonTitleText
            .assign(to: \.text, on: lessonNameTextField)
            .store(in: &subscriptions)
        
        viewModel.loadView.sink { [weak self] lesson in
            guard let self = self else { return }
            self.mainTableView.reloadData()
        }.store(in: &subscriptions)
        
        viewModel.imageButtonIsOn.sink { [weak self] isOn in
            guard let self = self else { return }
            self.addImageButton.isSelected = isOn
            self.addImageButton.tintColor = isOn ? .systemRed : .systemBlue
        }.store(in: &subscriptions)
        
        viewModel.editImageButtonIsHidden
            .assign(to: \.isHidden, on: editImageButton)
            .store(in: &subscriptions)
        
        viewModel.editStepButtonIsOn.sink { [weak self] isOn in
            guard let self = self else { return }
            self.editStepButton.isSelected = isOn
            self.mainTableView.setEditing(isOn, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.deleteImageAlert.sink { [weak self] _ in
            guard let self = self else { return }
            self.destructiveAlertView(withTitle: NSLocalizedString("Are you sure?", comment: ""), cancelString: NSLocalizedString("Cancel", comment: ""), destructiveString: NSLocalizedString("Delete", comment: "")) {
                self.viewModel.deleteImageConfirmed.send()
            }
        }.store(in: &subscriptions)
        
        viewModel.imageDeleted.sink { [weak self] _ in
            guard let self = self else { return }
            self.infoAlertViewWithTitle(title: NSLocalizedString("Image deleted", comment: ""))
        }.store(in: &subscriptions)
        
        viewModel.dataDeleted.sink { [weak self] _ in
            guard let self = self else { return }
            self.infoAlertViewWithTitle(title: NSLocalizedString("Data deleted", comment: ""), message: "") {
                self.viewModel.transiton.send(.deleted)
            }
        }.store(in: &subscriptions)
        
        viewModel.titleEmptyAlert.sink { [weak self] _ in
            guard let self = self else { return }
            self.warningAlertView(withTitle: NSLocalizedString("The title is blank", comment: ""))
        }.store(in: &subscriptions)
        
        viewModel.titleStringCountOverAlert.sink { [weak self] _ in
            guard let self = self else { return }
            self.warningAlertView(withTitle: NSLocalizedString("The number of characters is exceeded", comment: ""))
        }.store(in: &subscriptions)
        
        viewModel.dataSaved.sink { [weak self] _ in
            guard let self = self else { return }
            self.infoAlertViewWithTitle(title: NSLocalizedString("Data saved", comment: ""), message: "") {
                self.viewModel.transiton.send(.saved)
            }
        }.store(in: &subscriptions)
        
        viewModel.scrolStepTable.sink { [weak self] _ in
            guard let self = self else { return }
            self.mainTableView.scrollToRow(at: IndexPath(row: self.viewModel.lessonStepData.value.count - 1, section: 0) , at: .top, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.transiton.sink { [weak self] transition in
            guard let self = self else { return }
            switch transition {
            case let .addEditImage(lesson):
                guard let id = lesson.id else { return }
                guard let addNewImageVC = R.storyboard.addNewImage.addNewImage() else { return }
                addNewImageVC.lessonImage = lesson.getImage()
                addNewImageVC.lessonID = id.uuidString
                self.navigationController?.pushViewController(addNewImageVC, animated: true)
            case .saved:
                guard let safeDelegate = self.delegate else { return }
                safeDelegate.pushToLessonView()
                self.navigationController?.popViewController(animated: true)
            case .deleted:
                self.navigationController?.popViewController(animated: true)
            }
        }.store(in: &subscriptions)
    }

    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        viewModel.imageButtonPressed.send(sender.isSelected)
    }
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        viewModel.editImageButtonPressed.send()
    }
    @IBAction func addStepButtonPressed(_ sender: UIButton) {
        viewModel.addStepButtonPressed.send()
    }
    @IBAction func editStepButtonPressed(_ sender: UIButton) {
        viewModel.editStepButtonPressed.send(sender.isSelected)
    }
    @objc
    func deleteData() {
        destructiveAlertView(withTitle: NSLocalizedString("Data will be deleted", comment: ""), cancelString: NSLocalizedString("Cancel", comment: ""), destructiveString: NSLocalizedString("Delete", comment: "")) {
            self.viewModel.deleteData.send()
        }
    }
    @objc
    func save() {
        self.viewModel.textFieldDidEndEditing.send(lessonNameTextField.text)
        viewModel.saveData.send()
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

extension NewLessonViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.viewModel.textFieldDidEndEditing.send(textField.text)
    }
}

extension NewLessonViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lessonStepData.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepTableViewCellIdentifier", for: indexPath) as! StepTableViewCell
        for step in viewModel.lessonStepData.value where step.orderNum == indexPath.row {
            cell.delegate = self
            cell.setup(index: indexPath.row, stepData: step)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.lessonStepDidDelete.send(indexPath)
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
        guard let lessonStep = cell.stepData else { return }
        viewModel.lessonStepDidEndEditing.send((lessonStep, value))
        guard let view = imageButtonsAreaView else { return }
        view.isHidden = false
    }
}
