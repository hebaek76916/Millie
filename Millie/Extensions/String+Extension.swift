//
//  String+Extension.swift
//  Millie
//
//  Created by 현은백 on 10/13/24.
//

import Foundation

extension String {

    func toFormattedDateString(
        locale: Locale = .current,
        dateFormat: String = "yyyy년 MM월 dd일 a h시 m분",
        timeZone: TimeZone = .current
    ) -> String? {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = isoDateFormatter.date(from: self) else {
            return nil
        }
        
        // 원하는 형식의 날짜 문자열로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: date)
    }
}
