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
    case addNew
}

final class LessonImageViewModel {
    let settingButtonPressed = PassthroughSubject<Void, Never>()
    let addLessonButtonPressed = PassthroughSubject<Void, Never>()
    var transiton = PassthroughSubject<ImageTransition, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        mutate()
    }
    
    func mutate() {
        settingButtonPressed
            .sink { _ in
            self.transiton.send(.setting)
            }
            .store(in: &subscriptions)
        
        addLessonButtonPressed
            .sink { _ in
            self.transiton.send(.addNew)
            }
            .store(in: &subscriptions)
    }
}
