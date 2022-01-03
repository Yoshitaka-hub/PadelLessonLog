//
//  LessonImageViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/01/02.
//

import Combine
import UIKit

enum ImageTransition {
    case setting
    case lesson(Lesson, Bool)
    case arView
    case detail(Lesson)
}

final class LessonImageViewModel {
    let settingButtonPressed = PassthroughSubject<Void, Never>()
    let addLessonButtonPressed = PassthroughSubject<Void, Never>()
    let arButtonPressed = PassthroughSubject<Void, Never>()
    let detailButtonPressed = PassthroughSubject<Lesson, Never>()
    
    let pushToEditLessonView = PassthroughSubject<Lesson, Never>()
    let pushBackFromNewLessonView = PassthroughSubject<Void, Never>()
    
    let allButtonPressed = PassthroughSubject<Void, Never>()
    let favoriteButtonPressed = PassthroughSubject<Void, Never>()
    
    let scrollViewDidTouch = PassthroughSubject<CGPoint, Never>()
    let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
    let scrollViewDidStop = PassthroughSubject<[Int], Never>()
    
    let loadAllLessonData = PassthroughSubject<Void, Never>()
    let loadFavoriteLessonData = PassthroughSubject<Void, Never>()
    
    private(set) var allBarButtonIsOn = CurrentValueSubject<Bool, Never>(true)
    private(set) var favoriteBarButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var detailButtonIsHidden = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var scrollBeginingPoint = CurrentValueSubject<CGPoint, Never>(CGPoint.zero)
    private(set) var scrollDirection = CurrentValueSubject<Bool, Never>(true)
    private(set) var scrollToCellIndex = PassthroughSubject<Int, Never>()
    
    private(set) var transiton = PassthroughSubject<ImageTransition, Never>()
    
    private var coreDataMangaer = CoreDataManager.shared
    private(set) var lessonsArray = CurrentValueSubject<[Lesson], Never>([])
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        mutate()
    }
    
    func mutate() {
        loadAllLessonData.sink { [weak self] _ in
            guard let self = self else { return }
            self.lessonsArray.send(self.coreDataMangaer.loadAllLessonDataWithImage())
            self.detailButtonIsHidden.send(self.lessonsArray.value.isEmpty)
        }.store(in: &subscriptions)
        
        loadFavoriteLessonData.sink { [weak self] _ in
            guard let self = self else { return }
            self.lessonsArray.send(self.coreDataMangaer.loadAllFavoriteLessonDataWithImage())
            self.detailButtonIsHidden.send(self.lessonsArray.value.isEmpty)
        }.store(in: &subscriptions)
        
        settingButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.transiton.send(.setting)
        }.store(in: &subscriptions)
        
        addLessonButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            let newLessonData = self.coreDataMangaer.createNewLesson(image: R.image.img_court(compatibleWith: .current)!, steps: [""])
            self.transiton.send(.lesson(newLessonData, true))
        }.store(in: &subscriptions)
        
        arButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.transiton.send(.arView)
        }.store(in: &subscriptions)
        
        detailButtonPressed.sink { [weak self] lessonData in
            guard let self = self else { return }
            self.transiton.send(.detail(lessonData))
        }.store(in: &subscriptions)
        
        pushToEditLessonView.sink { [weak self] editLessonData in
            guard let self = self else { return }
            self.transiton.send(.lesson(editLessonData, false))
        }.store(in: &subscriptions)
        
        pushBackFromNewLessonView.sink { [weak self] editLessonData in
            guard let self = self else { return }
            guard !self.lessonsArray.value.isEmpty else { return }
            self.scrollToCellIndex.send(0)
        }.store(in: &subscriptions)
        
        allButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.allBarButtonIsOn.send(true)
            self.favoriteBarButtonIsOn.send(false)
        }.store(in: &subscriptions)
        
        favoriteButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.allBarButtonIsOn.send(false)
            self.favoriteBarButtonIsOn.send(true)
        }.store(in: &subscriptions)
        
        scrollViewDidTouch.sink { [weak self] point in
            guard let self = self else { return }
            self.scrollBeginingPoint.send(point)
            self.detailButtonIsHidden.send(true)
        }.store(in: &subscriptions)
        
        scrollViewDidScroll.sink { [weak self] currentPoint in
            guard let self = self else { return }
            if self.scrollBeginingPoint.value.x < currentPoint.x {
                self.scrollDirection.send(true)
            } else {
                self.scrollDirection.send(false)
            }
        }.store(in: &subscriptions)
        
        scrollViewDidStop.sink { [weak self] indexArray in
            guard let self = self else { return }
            guard let cellIndex = self.scrollDirection.value ? indexArray.max() : indexArray.min() else { return }
            self.scrollToCellIndex.send(cellIndex)
            self.detailButtonIsHidden.send(false)
        }.store(in: &subscriptions)
    }
}
