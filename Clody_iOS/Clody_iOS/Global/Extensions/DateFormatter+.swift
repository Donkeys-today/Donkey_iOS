//
//  DateFormatter+.swift
//  Clody_iOS
//
//  Created by Seonwoo Kim on 7/5/24.
//

import Foundation


extension DateFormatter {
    static func string(from date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    static func date(from string: String, format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }

    static func convertToDoubleDigitMonth(from monthString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        
        guard let date = formatter.date(from: monthString) else {
            return nil
        }
        
        formatter.dateFormat = "M"
        return formatter.string(from: date)
    }
    
    static func convertToDoubleDigitDay(from dayString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        guard let date = formatter.date(from: dayString) else {
            return nil
        }
        
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
