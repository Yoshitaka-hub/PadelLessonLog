//
//  AddNewImageViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/10.
//

import Quick
@testable import PadelLessonLog
import Combine
import CoreData

class AddNewImageViewModelTestTest: QuickSpec {
    override func spec() {
        describe("AddNewImageViewModel") {
            let newLessonViewModel = AddNewImageViewModel()
            var subscriptions = Set<AnyCancellable>()
            
            var flag: Bool?
            
            describe("動作検証") {
                context("ViewからViewModelにデータを渡す(初期表示)") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.loadLessonImageData.send((UUID().uuidString, UIImage()))
                    }
                    it("IDと画像がNULLでないこと") {
                        XCTAssertNotNil(newLessonViewModel.lessonID.value)
                        XCTAssertNotNil(newLessonViewModel.lessonImage.value)
                    }
                }
                context("カラーボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.action.sink { action in
                            switch action {
                            case .colorTableShow(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.colorTableButtonPressed.send()
                    }
                    it("カラー選択タブが表示されること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("オブジェクトボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.action.sink { action in
                            switch action {
                            case .objectTableShow(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.objectTableButtonPressed.send()
                    }
                    it("オブジェクト選択タブが表示されること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                
                context("UNDOボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.action.sink { action in
                            switch action {
                            case .undo:
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.undoButtonPressed.send()
                    }
                    it("UNDOがされること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("戻るボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.action.sink { action in
                            switch action {
                            case .back:
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.backButtonPressed.send()
                    }
                    it("全画面に戻ること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                
                context("カラー設定_赤色") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectColor.send(.black)
                    }
                    it("赤色が設定されいる") {
                        XCTAssertEqual(newLessonViewModel.lineColor.value, .black)
                    }
                }
                context("カラー設定_黄色") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectColor.send(.yellow)
                    }
                    it("黄色が設定されいる") {
                        XCTAssertEqual(newLessonViewModel.lineColor.value, .yellow)
                    }
                }
                context("カラー設定_青色") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectColor.send(.blue)
                    }
                    it("青色が設定されいる") {
                        XCTAssertEqual(newLessonViewModel.lineColor.value, .blue)
                    }
                }
                context("カラー設定_赤色") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectColor.send(.red)
                    }
                    it("赤色が設定されいる") {
                        XCTAssertEqual(newLessonViewModel.lineColor.value, .red)
                    }
                }
                context("オブジェクト設定_ペン") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.pen)
                    }
                    it("ペンが設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .pen)
                    }
                }
                context("オブジェクト設定_ライン") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.line)
                    }
                    it("ラインが設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .line)
                    }
                }
                context("オブジェクト設定_ペン") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.pen)
                    }
                    it("ペンが設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .pen)
                    }
                }
                context("オブジェクト設定_矢印") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.arrow)
                    }
                    it("矢印が設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .arrow)
                    }
                }
                context("オブジェクト設定_ボール") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.ball)
                    }
                    it("スタンプ・モードがtureが設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .stamp)
                        XCTAssertEqual(newLessonViewModel.stampMode.value, true)
                    }
                }
                context("オブジェクト設定_ピン") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.pin)
                    }
                    it("スタンプ・モードがfalseが設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .stamp)
                        XCTAssertEqual(newLessonViewModel.stampMode.value, false)
                    }
                }
                context("オブジェクト設定_レクタングル") {
                    beforeEach {
                        subscriptions.removeAll()
                        flag = nil
                        newLessonViewModel.didSelectObject.send(.rect)
                    }
                    it("レクタングルが設定されいる") {
                        XCTAssertEqual(newLessonViewModel.toolType.value, .rectangleFill)
                    }
                }
            }
        }
    }
}

