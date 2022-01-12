//
//  LessonDataViewTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/12.
//

import Quick
@testable import PadelLessonLog
import Combine

class LessonDataViewTest: QuickSpec {
    override func spec() {
        let lessonImageView = R.storyboard.lessonData.instantiateInitialViewController()
        guard let lessonImageView = lessonImageView else { return }
        
        describe("LessonDataView") {
            describe("動作検証") {
                context("ライフサイクルをトリガする") {
                    beforeEach {
                        lessonImageView.view.layoutIfNeeded()
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.allBarButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonImageView.favoriteBarButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonImageView.searchButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonImageView.searchBar.isHidden, true)
                    }
                }
                context("Favoriteボタンをタップ") {
                    beforeEach {
                        lessonImageView.favoriteButtonPressed(lessonImageView.favoriteBarButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.allBarButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonImageView.favoriteBarButton.tintColor, .colorButtonOn)
                    }
                }
                context("Allボタンをタップ") {
                    beforeEach {
                        lessonImageView.allButtonPressed(lessonImageView.allBarButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.allBarButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonImageView.favoriteBarButton.tintColor, .colorButtonOff)
                    }
                }
                context("検索ボタンをタップ") {
                    beforeEach {
                        lessonImageView.searchButtonPressed(lessonImageView.searchButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.searchButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonImageView.searchBar.isHidden, false)
                    }
                }
            }
        }
    }
}

