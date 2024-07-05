//
//  CombinedDataModel.swift
//  CyMe
//
//  Created by Deborah on 04.07.2024.
//

import Foundation


struct CombinedDataModel  { // Holds all Data of a selected Cycle (AppleHealth and CyMe Data in an aggregated way
    
    var periodDataList : [PeriodSampleModel] = []
    var headacheDataList : [AppleHealthSefReportModel] = []
    var abdominalCrampsDataList : [AppleHealthSefReportModel] = []
    var lowerBackPainDataList : [AppleHealthSefReportModel] = []
    var pelvicPainDataList : [AppleHealthSefReportModel] = []
    var acneDataList : [AppleHealthSefReportModel] = []
    var chestTightnessOrPainDataList : [AppleHealthSefReportModel] = []
    var appetiteChangeDataList : [AppetiteChangeModel] = []
    var sleepLengthDataList : [Date : Int] = [:]
    var exerciseTimeDataList : [Date : Int] = [:]
    var stepCountDataList : [Date : Int] = [:]
    var sleepQualityDataList : [CyMeSefReportModel] = []
    var stressDataList : [CyMeSefReportModel] = []
    var moodDataList : [CyMeSefReportModel] = []
    
    
    
}

