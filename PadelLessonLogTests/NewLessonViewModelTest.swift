//
//  NewLessonViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/07.
//

import Quick
@testable import PadelLessonLog
import Combine
import CoreData

class NewLessonViewModelTest: QuickSpec {
    override func spec() {
        describe("NewLessonViewModel") {
            let newLessonViewModel = NewLessonViewModel()
            let stubManager = StubManager()
            var subscriptions = Set<AnyCancellable>()
            
            var flag: Bool?
            
            describe("動作検証") {
                newLessonViewModel.lessonData.send(stubManager.createStubLessonData())
                context("画像追加ボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.transiton.sink { value in
                            switch value {
                            case .addEditImage(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.imageButtonPressed.send(false)
                    }
                    it("画像追加画面に遷移") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("画像削除ボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.deleteImageAlert.sink { _ in
                            flag = true
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.imageButtonPressed.send(true)
                    }
                    it("画像削除アラート表示") {
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}
