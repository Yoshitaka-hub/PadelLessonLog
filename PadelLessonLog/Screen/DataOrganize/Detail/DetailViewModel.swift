//
//  DetailViewMode.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/12.
//

import UIKit
import Combine

class DetailViewModel {
    @Published var tableViewCellNum: Int = 0
    @Published var tableViewCellData: [LessonStep] = []
}
