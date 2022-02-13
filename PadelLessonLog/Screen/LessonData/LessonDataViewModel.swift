//
//  LessonDataViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/01/04.
//

import Foundation
import Combine

final class LessonDataViewModel: LessonViewModel {
    struct Dependency {
        let coreDataProtocol: CoreDataProtocol
    }
    init (dependency: Dependency) {
        coreDataManager = dependency.coreDataProtocol
        super.init()
    }
    let coreDataManager: CoreDataProtocol
        
    let addLessonButtonPressed = PassthroughSubject<Void, Never>()
    let pushBackFromNewLessonView = PassthroughSubject<Void, Never>()
    let didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    let reorderData = PassthroughSubject<(from: IndexPath, to: IndexPath), Never>()
    let searchAndFilterData = PassthroughSubject<String, Never>()
    private(set) var scrollToTableIndex = PassthroughSubject<Int, Never>()
    
    override func mutate() {
        super.mutate()
        addLessonButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let courtImg = R.image.img_court(compatibleWith: .current) else { return }
            let newLessonData = self.coreDataManager.createNewLesson(image: courtImg, steps: [""])
            self.transition.send(.lesson(newLessonData, true))
        }.store(in: &subscriptions)
        
        dataReload.sink { [weak self] _ in
            guard let self = self else { return }
            if self.tableMode.value == .allTableView {
                self.lessonsArray.send(self.coreDataManager.loadAllLessonData())
            } else {
                self.lessonsArray.send(self.coreDataManager.loadAllFavoriteLessonData())
            }
        }.store(in: &subscriptions)
        
        didSelectRowAt.sink { [weak self] indexPath in
            guard let self = self else { return }
            let lessonData = self.lessonsArray.value[indexPath.row]
            self.transition.send(.detail(lessonData))
        }.store(in: &subscriptions)
        
        reorderData.sink { [weak self] from, to in
            guard let self = self else { return }
            guard from.row != to.row else { return }
            let lessonData = self.lessonsArray.value[from.row]
            self.lessonsArray.value.remove(at: from.row)
            self.lessonsArray.value.insert(lessonData, at: to.row)
            self.coreDataManager.updateLessonOrder(lessonArray: self.lessonsArray.value)
        }.store(in: &subscriptions)
        
        searchAndFilterData.sink { [weak self] text in
            guard let self = self else { return }
            let filteredData = self.lessonsArray.value.filter {
                guard let title = $0.title else { return false }
                return title.contains(text)
            }
            self.lessonsArray.send(filteredData)
        }.store(in: &subscriptions)
        
        pushBackFromNewLessonView.sink { [weak self] _ in
            guard let self = self else { return }
            guard !self.lessonsArray.value.isEmpty else { return }
            self.scrollToTableIndex.send(0)
        }.store(in: &subscriptions)
    }
}
