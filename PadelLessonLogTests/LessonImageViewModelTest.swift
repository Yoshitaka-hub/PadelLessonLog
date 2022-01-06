//
//  LessonImageViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/05.
//


import Quick
@testable import PadelLessonLog
import Combine

class LessonImageViewModelTest: QuickSpec {
    override func spec() {
        describe("LessonImageViewModel") {
            let lessonImageViewModel = LessonImageViewModel()
            var subscriptions = Set<AnyCancellable>()
            var recievedReloadStreamFlag = false
            var recievedAllButtonStateStreamFlag: Bool?
            var recievedFavoriteButtonStateStreamFlag: Bool?
            var recievedTransitionStream: LessonTransition?
            
            lessonImageViewModel.dataReload.sink { _ in
                recievedReloadStreamFlag = true
            }.store(in: &subscriptions)
            
            lessonImageViewModel.allBarButtonIsOn.sink { value in
                recievedAllButtonStateStreamFlag = value
            }.store(in: &subscriptions)
            
            lessonImageViewModel.favoriteBarButtonIsOn.sink { value in
                recievedFavoriteButtonStateStreamFlag = value
            }.store(in: &subscriptions)
            
            lessonImageViewModel.transiton.sink { value in
                recievedTransitionStream = value
            }.store(in: &subscriptions)
            
            describe("動作検証") {
                context("Allボタンタップ") {
                    beforeEach {
                        lessonImageViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        recievedReloadStreamFlag = false
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonImageViewModel.allButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonImageViewModel.tableMode.value, .allTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, true)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, false)
                    }
                }
                context("Favoriteボタンタップ") {
                    beforeEach {
                        recievedReloadStreamFlag = false
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonImageViewModel.favoriteButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonImageViewModel.tableMode.value, .favoriteTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, false)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, true)
                    }
                }
                
                context("設定画面に遷移") {
                    beforeEach {
                        recievedTransitionStream = nil
                        lessonImageViewModel.settingButtonPressed.send()
                    }
                    it(".settingが流れてくること") {
                        var flag = false
                        switch recievedTransitionStream {
                        case .setting:
                            flag = true
                        default:
                            break
                        }
                        XCTAssertEqual(flag, true)
                    }
                }
                context("詳細画面に遷移") {
                    beforeEach {
                        let dummyLesson = Lesson()
                        recievedTransitionStream = nil
                        lessonImageViewModel.detailButtonPressed.send(dummyLesson)
                    }
                    it(".detail(dummyLesson)が流れてくること") {
                        var flag = false
                        switch recievedTransitionStream {
                        case .detail(_):
                            flag = true
                        default:
                            break
                        }
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}
