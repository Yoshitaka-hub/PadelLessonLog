//
//  LessonDataViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/05.
//


import Quick
@testable import PadelLessonLog
import Combine

class LessonDataViewModelTest: QuickSpec {
    override func spec() {
        describe("ValidateManager") {
            let lessonDataViewModel = LessonDataViewModel()
            var subscriptions = Set<AnyCancellable>()
            var recievedReloadStreamFlag = false
            var recievedAllButtonStateStreamFlag: Bool?
            var recievedFavoriteButtonStateStreamFlag: Bool?
            var recievedTransitionStream: lessonTransition?
            
            lessonDataViewModel.dataReload.sink { _ in
                recievedReloadStreamFlag = true
            }.store(in: &subscriptions)
            
            lessonDataViewModel.allBarButtonIsOn.sink { value in
                recievedAllButtonStateStreamFlag = value
            }.store(in: &subscriptions)
            
            lessonDataViewModel.favoriteBarButtonIsOn.sink { value in
                recievedFavoriteButtonStateStreamFlag = value
            }.store(in: &subscriptions)
            
            lessonDataViewModel.transiton.sink { value in
                recievedTransitionStream = value
            }.store(in: &subscriptions)
            
            describe("入力文字検証") {
                context("Allボタンタップ") {
                    beforeEach {
                        lessonDataViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        recievedReloadStreamFlag = false
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonDataViewModel.allButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonDataViewModel.tableMode.value, .allTableView)
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
                        lessonDataViewModel.favoriteButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonDataViewModel.tableMode.value, .favoriteTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, false)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, true)
                    }
                }
                
                context("設定画面に遷移") {
                    beforeEach {
                        recievedTransitionStream = nil
                        lessonDataViewModel.settingButtonPressed.send()
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
                        lessonDataViewModel.detailButtonPressed.send(dummyLesson)
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
