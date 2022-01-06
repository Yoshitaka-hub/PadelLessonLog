//
//  LessonViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/04.
//

import Quick
@testable import PadelLessonLog
import Combine

class LessonViewModelTest: QuickSpec {
    override func spec() {
        describe("LessonViewModel") {
            let lessonViewModel = LessonViewModel()
            var subscriptions = Set<AnyCancellable>()
            var recievedReloadStreamFlag = false
            var recievedAllButtonStateStreamFlag: Bool?
            var recievedFavoriteButtonStateStreamFlag: Bool?
            var recievedTransitionStream: LessonTransition?
            
            lessonViewModel.dataReload.sink { _ in
                recievedReloadStreamFlag = true
            }.store(in: &subscriptions)
            
            lessonViewModel.allBarButtonIsOn.sink { value in
                recievedAllButtonStateStreamFlag = value
            }.store(in: &subscriptions)
            
            lessonViewModel.favoriteBarButtonIsOn.sink { value in
                recievedFavoriteButtonStateStreamFlag = value
            }.store(in: &subscriptions)
            
            lessonViewModel.transiton.sink { value in
                recievedTransitionStream = value
            }.store(in: &subscriptions)
            
            describe("動作検証") {
                context("Allボタンタップ") {
                    beforeEach {
                        lessonViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        recievedReloadStreamFlag = false
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonViewModel.allButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonViewModel.tableMode.value, .allTableView)
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
                        lessonViewModel.favoriteButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonViewModel.tableMode.value, .favoriteTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, false)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, true)
                    }
                }
                
                context("設定画面に遷移") {
                    beforeEach {
                        recievedTransitionStream = nil
                        lessonViewModel.settingButtonPressed.send()
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
                        lessonViewModel.detailButtonPressed.send(dummyLesson)
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
