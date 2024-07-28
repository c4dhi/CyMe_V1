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
    
    
    
    mutating func append(otherModel: CombinedDataModel){
        periodDataList += otherModel.periodDataList
        headacheDataList += otherModel.headacheDataList
        abdominalCrampsDataList += otherModel.abdominalCrampsDataList
        lowerBackPainDataList += otherModel.lowerBackPainDataList
        pelvicPainDataList += otherModel.pelvicPainDataList
        acneDataList += otherModel.acneDataList
        chestTightnessOrPainDataList += otherModel.chestTightnessOrPainDataList
        appetiteChangeDataList += otherModel.appetiteChangeDataList
        //sleepLengthDataList : [Date : Int] = [:]
        sleepQualityDataList += otherModel.sleepQualityDataList
        stressDataList += otherModel.stressDataList
        moodDataList += otherModel.moodDataList
    }
    
}

