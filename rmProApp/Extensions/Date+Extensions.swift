//
//  Date+Extensions.swift
//  rmProApp
//
//  Created by Claude Code on 10/29/25.
//

import Foundation

extension Date {
    /// Converts the date to a string in the RentManager API format: "yyyy-MM-dd'T'HH:mm:ss"
    /// - Returns: A formatted date string compatible with RentManager API
    func toRentManagerAPIString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: self)
    }
}
