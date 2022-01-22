//
//  NewLessonViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

enum NewLessonTransition {
    case addEditImage(Lesson)
    case saved
    case deleted
}

final class NewLessonViewModel: BaseViewModel {
    
    let imageButtonPressed = PassthroughSubject<Bool, Never>()
    let editImageButtonPressed = PassthroughSubject<Void, Never>()
    let deleteImageConfirmed = PassthroughSubject<Void, Never>()
    let addStepButtonPressed = PassthroughSubject<Void, Never>()
    let editStepButtonPressed = PassthroughSubject<Bool, Never>()
    var textFieldDidEndEditing = PassthroughSubject<String?, Never>()
    
    let deleteData = PassthroughSubject<Void, Never>()
    let saveData = PassthroughSubject<Void, Never>()
    
    let dataReload = PassthroughSubject<Void, Never>()
    
    var lessonData = CurrentValueSubject<Lesson?, Never>(nil)
    var lessonStepData = CurrentValueSubject<[LessonStep], Never>([])
    var lessonTitleText = CurrentValueSubject<String?, Never>("")
    var lessonStepDidEndEditing = PassthroughSubject<(LessonStep, String), Never>()
    var lessonStepDidDelete = PassthroughSubject<IndexPath, Never>()
    
    private(set) var deleteImageAlert = PassthroughSubject<Void, Never>()
    private(set) var titleEmptyAlert = PassthroughSubject<Void, Never>()
    private(set) var titleStringCountOverAlert = PassthroughSubject<Void, Never>()
    private(set) var imageDeleted = PassthroughSubject<Void, Never>()
    private(set) var dataDeleted = PassthroughSubject<Void, Never>()
    private(set) var dataSaved = PassthroughSubject<Void, Never>()
    private(set) var imageButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var editImageButtonIsHidden = CurrentValueSubject<Bool, Never>(false)
    private(set) var editStepButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var loadView = PassthroughSubject<Lesson, Never>()
    private(set) var scrolStepTable = PassthroughSubject<Void, Never>()
    private(set) var transiton = PassthroughSubject<NewLessonTransition, Never>()
    
    let coreDataMangaer = CoreDataManager.shared
    let validateManager = ValidateManager.shared
    
    override func mutate() {
        lessonData.sink { [weak self] lessonData in
            guard let self = self else { return }
            guard let lesson = lessonData else { return }
            let steps = lesson.steps?.allObjects as? [LessonStep]
            guard let safeSteps = steps, !safeSteps.isEmpty else { return }
            self.lessonTitleText.send(lesson.title)
            self.lessonStepData.send(safeSteps)
            self.loadView.send(lesson)
            
            self.imageButtonIsOn.send(lesson.imageSaved)
            self.editImageButtonIsHidden.send(!lesson.imageSaved)
        }.store(in: &subscriptions)
        
        textFieldDidEndEditing.sink { [weak self] inputText in
            guard let self = self else { return }
            self.lessonTitleText.send(inputText)
            guard let text = inputText else { return }
            let maxCount = 40
            let result: ValidateResult = self.validateManager.validate(word: text, maxCount: maxCount)
            if result == .countOverError {
                let dif = text.count - maxCount
                let dropedText = text.dropLast(dif)
                self.titleStringCountOverAlert.send()
                self.lessonTitleText.send(dropedText.description)
            }
        }.store(in: &subscriptions)
        
        imageButtonPressed.sink { [weak self] isSelected in
            guard let self = self else { return }
            if !isSelected {
                guard let lesson = self.lessonData.value else { return }
                self.transiton.send(.addEditImage(lesson))
            } else {
                self.deleteImageAlert.send()
            }
        }.store(in: &subscriptions)
        
        deleteImageConfirmed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard let id = lesson.id else { return }
            guard let courtImage = R.image.img_court(compatibleWith: .current) else { return }
            if self.coreDataMangaer.resetLessonImage(lessonID: id.uuidString, image: courtImage) {
                self.lessonData.send(self.coreDataMangaer.loadLessonData(lessonID: id.uuidString))
                self.imageDeleted.send()
            } else {
                fatalError("画像が更新できない")
            }
        }.store(in: &subscriptions)
        
        editImageButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.transiton.send(.addEditImage(lesson))
        }.store(in: &subscriptions)
        
        addStepButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.coreDataMangaer.createStep(lesson: lesson)
            self.lessonData.send(lesson)
            self.scrolStepTable.send()
        }.store(in: &subscriptions)
        
        editStepButtonPressed.sink { [weak self] isSelected in
            guard let self = self else { return }
            self.editStepButtonIsOn.send(!isSelected)
        }.store(in: &subscriptions)
        
        lessonStepDidEndEditing.sink { [weak self] lessonStep, text in
            guard self != nil else { return }
            lessonStep.explication = text
            lessonStep.save()
        }.store(in: &subscriptions)
        
        lessonStepDidDelete.sink { [weak self] indexPath in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard self.lessonStepData.value.count > 1 else { return }
            var deleteStep: LessonStep?
            for step in self.lessonStepData.value where step.orderNum == indexPath.row {
                deleteStep = step
            }
            guard let step = deleteStep else { return }
            self.coreDataMangaer.deleteStep(lesson: lesson, step: step, stpes: self.lessonStepData.value)
            self.lessonData.send(lesson)
        }.store(in: &subscriptions)
        
        deleteData.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard let id = lesson.id else { return }
            if self.coreDataMangaer.deleteLessonData(lessonID: id.uuidString) {
                self.dataDeleted.send()
            } else {
                fatalError("データ削除失敗")
            }
        }.store(in: &subscriptions)
        
        saveData.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard let id = lesson.id else { return }
            guard let title = self.lessonTitleText.value else {
                self.titleEmptyAlert.send()
                return
            }
            let trinmingTitle = title.trimmingCharacters(in: .whitespaces)
            let result: ValidateResult = self.validateManager.validate(word: trinmingTitle, maxCount: 0)
            guard result == .valid else {
                self.titleEmptyAlert.send()
                return
            }
            
            if self.coreDataMangaer.updateLessonTitle(lessonID: id.uuidString, title: title) {
                self.dataSaved.send()
            } else {
                fatalError("データ保存失敗")
            }
        }.store(in: &subscriptions)
    }
}
