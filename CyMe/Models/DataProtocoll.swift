//
//  DataProtocoll.swift
//  CyMe
//
//  Created by Deborah on 22.06.2024.
//

import Foundation

protocol DataProtocoll {
    var startdate: Date {get}
    var intensity: Int {get}
    var symptomPresent : Bool {get}
}

extension Array where Element == DataProtocoll {
    func filterByStartDate(startDate: Date) -> [DataProtocoll] {
        
        return self.filter { Calendar.current.dateComponents([.day, .month, .year], from: $0.startdate) == Calendar.current.dateComponents([.day, .month, .year], from: startDate) }
    }
}
