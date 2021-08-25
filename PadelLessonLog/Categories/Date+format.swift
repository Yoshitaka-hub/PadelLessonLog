//
//  Date+format.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/25.
//

import Foundation

extension Date {
    func stringWithFormat(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}

extension String {
    func dateWithFormat(dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
    func stringChangeFormat(fromFormat: String, toFormat: String) -> String {
        guard let date = self.dateWithFormat(dateFormat: fromFormat) else { return "" }
        return date.stringWithFormat(dateFormat: toFormat)
    }
}
