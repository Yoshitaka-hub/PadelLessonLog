//
//  NewLessonViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

class NewLessonViewModel {
    @Published var tableViewCellNum: Int = 0
    @Published var tableViewCellData: [LessonStep] = []
    @Published var addImageButtonIsSelected: Bool = false
}
