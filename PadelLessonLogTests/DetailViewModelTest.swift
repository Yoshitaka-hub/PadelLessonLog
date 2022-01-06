//
//  DetailViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/05.
//

import Quick
@testable import PadelLessonLog
import Combine

class DetailViewModelTest: QuickSpec {
    override func spec() {
        describe("DetailViewModel") {
            let detailViewModel = DetailViewModel()
            var subscriptions = Set<AnyCancellable>()
            var recievedTransitionStream: DetailTransition?
            
            detailViewModel.transiton.sink { value in
                recievedTransitionStream = value
            }.store(in: &subscriptions)
            
            describe("動作検証") {
                context("画像表示画面に遷移") {
                    beforeEach {
                        detailViewModel.transiton.sink { value in
                            recievedTransitionStream = value
                        }.store(in: &subscriptions)
                        
                        detailViewModel.imageViewButtonPressed.send()
                    }
                    it("lessonDataがnilだと何も流れてくこない") {
                        var flag: Bool?
                        switch recievedTransitionStream {
                        case .imgaeView(_):
                            flag = true
                        default:
                            flag = false
                        }
                        XCTAssertEqual(flag, false)
                    }
                }
                context("修正画面に遷移") {
                    beforeEach {
                        recievedTransitionStream = nil
                        detailViewModel.editViewButtonPressed.send()
                    }
                    it("lessonDataがnilだと何も流れてくこない") {
                        var flag: Bool?
                        switch recievedTransitionStream {
                        case .editView(_):
                            flag = true
                        default:
                            flag = false
                        }
                        XCTAssertEqual(flag, false)
                    }
                }
                context("前の画面に戻る") {
                    beforeEach {
                        recievedTransitionStream = nil
                        detailViewModel.backButtonPressed.send()
                    }
                    it(".backが流れてくること") {
                        var flag: Bool?
                        switch recievedTransitionStream {
                        case .back:
                            flag = true
                        default:
                            flag = false
                        }
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}
