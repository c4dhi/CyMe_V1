//
//  UserReportingOptions.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 08.05.24.
//

import Foundation

class UserReportingOptions: ObservableObject {
    @Published var periodTrackingEnabled: Bool = true
    @Published var headacheTrackingEnabled: Bool = true
}
