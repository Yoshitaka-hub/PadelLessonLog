//
//  LessonImageViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/01/02.
//

import Combine
import UIKit

final class LessonImageViewModel: LessonViewModel {
    let arButtonPressed = PassthroughSubject<Void, Never>()
    
    let scrollViewDidTouch = PassthroughSubject<CGPoint, Never>()
    let scrollViewDidScroll = PassthroughSubject<CGPoint, Never>()
    let scrollViewDidStop = PassthroughSubject<[Int], Never>()
    
    private(set) var detailButtonIsHidden = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var scrollBeginingPoint = CurrentValueSubject<CGPoint, Never>(CGPoint.zero)
    private(set) var scrollDirection = CurrentValueSubject<Bool, Never>(true)
    private(set) var scrollToCellIndex = PassthroughSubject<Int, Never>()
    
    override func mutate() {
        super.mutate()
        dataReload.sink { [weak self] _ in
            guard let self = self else { return }
            if self.tableMode.value == .allTableView {
                self.lessonsArray.send(self.coreDataMangaer.loadAllLessonDataWithImage())
            } else {
                self.lessonsArray.send(self.coreDataMangaer.loadAllFavoriteLessonDataWithImage())
            }
            
            self.detailButtonIsHidden.send(self.lessonsArray.value.isEmpty)
        }.store(in: &subscriptions)
        
        arButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.transiton.send(.arView)
        }.store(in: &subscriptions)
        
        pushBackFromNewLessonView.sink { [weak self] _ in
            guard let self = self else { return }
            guard !self.lessonsArray.value.isEmpty else { return }
            self.scrollToCellIndex.send(0)
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
