//
//  NewLessonViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

enum NewLessonTransition {
    case editImage(Lesson)
    case saved
    case deleted
}

class NewLessonViewModel: BaseViewModel {
    
    let imageButtonPressed = PassthroughSubject<Bool, Never>()
    let editImageButtonPressed = PassthroughSubject<Void, Never>()
    let deleteImageConfirmed = PassthroughSubject<Void, Never>()
    let addStepButtonPressed = PassthroughSubject<Void, Never>()
    let editStepButtonPressed = PassthroughSubject<Bool, Never>()
    
    let deleteDataButtonPressed = PassthroughSubject<Void, Never>()
    let saveDataButtonPressed = PassthroughSubject<Void, Never>()
    
    let dataReload = PassthroughSubject<Void, Never>()
    
    var lessonData = CurrentValueSubject<Lesson?, Never>(nil)
    var lessonStepData = CurrentValueSubject<[LessonStep], Never>([])
    
    private(set) var deleteImageAlert = PassthroughSubject<Void, Never>()
    private(set) var imageDeleted = PassthroughSubject<Void, Never>()
    private(set) var imageButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var editImageButtonIsHidden = CurrentValueSubject<Bool, Never>(false)
    private(set) var editStepButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var loadView = PassthroughSubject<Lesson, Never>()
    private(set) var scrolStepTable = PassthroughSubject<Void, Never>()
    private(set) var transiton = PassthroughSubject<NewLessonTransition, Never>()
    
    let coreDataMangaer = CoreDataManager.shared
    
    override func mutate() {
        lessonData.sink { [weak self] lessonData in
            guard let self = self else { return }
            guard let lesson = lessonData else { return }
            let steps = lesson.steps?.allObjects as? [LessonStep]
            guard let safeSteps = steps, !safeSteps.isEmpty else { return }
            self.lessonStepData.send(safeSteps)
            self.loadView.send(lesson)
            
            self.imageButtonIsOn.send(lesson.imageSaved)
            self.editImageButtonIsHidden.send(!lesson.imageSaved)
            
        }.store(in: &subscriptions)
        
        imageButtonPressed.sink { [weak self] isSelected in
            guard let self = self else { return }
            if isSelected {
                guard let lesson = self.lessonData.value else { return }
                self.transiton.send(.editImage(lesson))
            } else {
                self.deleteImageAlert.send()
            }
        }.store(in: &subscriptions)
        
        deleteImageConfirmed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard let id = lesson.id else { return }
            if self.coreDataMangaer.resetLessonImage(lessonID: id.uuidString, image: R.image.img_court(compatibleWith: .current)!) {
                self.lessonData.send(self.coreDataMangaer.loadLessonData(lessonID: id.uuidString))
                self.imageDeleted.send()
            } else {
                fatalError("画像が更新できない")
            }
        }.store(in: &subscriptions)
        
        editImageButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.transiton.send(.editImage(lesson))
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
        
        deleteDataButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
        }.store(in: &subscriptions)
        
        saveDataButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
        }.store(in: &subscriptions)
    }
}
