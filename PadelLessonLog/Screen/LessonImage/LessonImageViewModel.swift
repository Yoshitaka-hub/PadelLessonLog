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
    let allButtonPressed = PassthroughSubject<Void, Never>()
    let favoriteButtonPressed = PassthroughSubject<Void, Never>()
    
    private(set) var allBarButtonIsOn = CurrentValueSubject<Bool, Never>(true)
    private(set) var favoriteBarButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var transiton = PassthroughSubject<ImageTransition, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        mutate()
    }
    
    func mutate() {
        settingButtonPressed.sink { _ in
            self.transiton.send(.setting)
        }
        .store(in: &subscriptions)
        
        addLessonButtonPressed.sink { _ in
            self.transiton.send(.addNew)
        }
        .store(in: &subscriptions)

        allButtonPressed.sink { _ in
            self.allBarButtonIsOn.send(true)
            self.favoriteBarButtonIsOn.send(false)
        }
        .store(in: &subscriptions)
        
        favoriteButtonPressed.sink { _ in
            self.allBarButtonIsOn.send(false)
            self.favoriteBarButtonIsOn.send(true)
        }
        .store(in: &subscriptions)
    }
}
