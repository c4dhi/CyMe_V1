//
//  ReviewReportModel.swift
//  SharedModels
//
//  Created by Marinja Principe on 30.06.24.
//
import Foundation

struct ReviewReportModel: Codable {
    var id: Int?
    var startTime: Date
    var endTime: Date
    var isCyMeSelfReport: Bool
    var selfReportMedium: selfReportMediumType
    var menstruationDate: String?
    var sleepQuality: String?
    var sleepLenght: String?
    var headache: String?
    var stress: String?
    var abdominalCramps: String?
    var lowerBackPain: String?
    var pelvicPain: String?
    var acne: String?
    var appetiteChanges: String?
    var chestPain: String?
    var stepData: String?
    var mood: String?
    var notes: String?
}
