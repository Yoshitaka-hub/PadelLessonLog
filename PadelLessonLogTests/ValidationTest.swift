//
//  ValidationTest.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/12.
//  
//

import Quick
import Nimble
@testable import PadelLessonLog

class ValidationTest: QuickSpec {
    override func spec() {
        describe("ValidationManager") {
            // テスト用の変数
            var validationManager = ValidationManager()
            var inputString: String!
            var subject: ValidationResult {
                return validationManager.validate(inputString)
            }
            
            // 概要
            describe("入力文字検証") {
                // 条件1:空文字列
                context("空文字列") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = "" }
                    
                    // 期待する結果
                    it("invalidが返ってくること") {
                        XCTAssertEqual(subject, .invalid)
                    }
                }
                
                // 条件2:ブランク文字列
                context("ブランク文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = " " }
                    // 期待する結果
                    it("validが返ってくること") {
                        XCTAssertEqual(subject, .valid)
                    }
                }
                // 条件3:4文字
                context("4文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = "ABCD" }
                    // 期待する結果
                    it("validが返ってくること") {
                        expect(subject).to(equal(.valid))
                    }
                }
                // 条件3:9文字
                context("9文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = "ABCDEFGHI" }
                    // 期待する結果
                    it("invalidが返ってくること") {
                        expect(subject).to(equal(.invalid))
                    }
                }
                // 条件3:9文字
                context("12文字をMaxに変えて、9文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach {
                        validationManager = ValidationManager()
                        validationManager.maxTextNum = 12
                        inputString = "ABCDEFGHI"
                        
                    }
                    // 期待する結果
                    it("invalidが返ってくること") {
                        expect(subject).to(equal(.valid))
                    }
                }
            }
        }
    }
}
