//
//  BuildCMSelfReportedSymptoms.swift
//  CyMe
//
//  Created by Deborah on 02.08.2024.
//

import Foundation
class BuildCMSelfReportedSymptoms{
    
    let handeledByThisClass : [availableHealthMetrics] = [.menstrualBleeding, .stress, .sleepQuality, .mood, ]

    
    var relevantDataList : [availableHealthMetrics]
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel]
    var availableCycles : Int
    var menstruationRanges : MenstruationRanges
    
    let healthMetricToTitle : [availableHealthMetrics : String] = [.stress : "Stress", .sleepQuality : "Sleep Quality", .mood : "Mood", .menstrualBleeding : "Menstruation"]
    let healthMetricToQuestionType : [availableHealthMetrics : QuestionType] =  [.stress : .emoticonRating, .sleepQuality : .emoticonRating, .mood : .emoticonRating, .menstrualBleeding : .menstruationEmoticonRating]
    
    
    
    init(relevantDataList: [availableHealthMetrics], combinedDataDict : [cycleTimeOptions : CombinedDataModel], menstruationRanges : MenstruationRanges, availableCycles : Int) {
        self.relevantDataList = relevantDataList
        self.combinedDataDict = combinedDataDict
        self.availableCycles = availableCycles
        self.menstruationRanges = menstruationRanges
        
    }
    
    func buildSelfReportedSymptoms() -> [cycleTimeOptions : [SymptomModel]] {
        let dateRangeDict : [cycleTimeOptions : [Date]] = [.current : menstruationRanges.currentDateRange, .last : menstruationRanges.lastFullCycleDateRange, .secondToLast : menstruationRanges.secondToLastFullCycleDateRange]
        
        var collectedSymptomDict : [cycleTimeOptions : [SymptomModel]] = [.current : [], .last : [], .secondToLast : []]
        
        
        for healthMetric in relevantDataList{
            if handeledByThisClass.contains(healthMetric) {
                
                let title = healthMetricToTitle[healthMetric]!
                let questionType = healthMetricToQuestionType[healthMetric]!
                
                
                var cycleOverviewCurrent : [Int?] = []
                var cycleOverviewLast : [Int?] = []
                var cycleOverviewSecondToLast : [Int?] = []
                
                if availableCycles == 0 {
                    return collectedSymptomDict
                }
                
                if availableCycles >= 1 {
                    cycleOverviewCurrent = buildCyMeGraphArray(symptomList: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, period: healthMetric == .menstrualBleeding)
                }
                
                if availableCycles >= 2 {
                    cycleOverviewLast = buildCyMeGraphArray(symptomList: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, period: healthMetric == .menstrualBleeding)
                }
                
                if availableCycles >= 3 {
                    cycleOverviewSecondToLast = buildCyMeGraphArray(symptomList: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, period: healthMetric == .menstrualBleeding)
                }
            
                let statistics = buildSymptomMinMaxAverage(symptomListCurrent: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), symptomListLast:combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), symptomListSecondToLast: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), title: title, availableCycles: availableCycles)
                let covarianceAndList =  buildCorrelation(cycleOverviewCurrent: cycleOverviewCurrent, cycleOverviewLast:  cycleOverviewLast, cycleOverviewSecondToLast:  cycleOverviewSecondToLast, cyclesAvailable: availableCycles)
                
                
                if availableCycles >= 1 {
                    let hints : [String] = buildSymptomHints(cycleOverview: cycleOverviewCurrent, symptomList: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, title: title, removeMaxMinHint: healthMetric != .menstrualBleeding)
                    
                    let symptomModel = SymptomModel(
                        title: title,
                        dateRange: dateRangeDict[.current]!,
                        cycleOverview: cycleOverviewCurrent,
                        hints: hints,
                        min: statistics[0],
                        max: statistics[1],
                        average: statistics[2],
                        covariance: covarianceAndList.0,
                        correlationOverview: covarianceAndList.1,
                        questionType: questionType)
                    
                    var preexistingSymptomList = collectedSymptomDict[.current]!
                    preexistingSymptomList.append(symptomModel)
                    collectedSymptomDict[.current] = preexistingSymptomList
                }
                
                if availableCycles >= 2 {
                    let hints : [String] = buildSymptomHints(cycleOverview: cycleOverviewLast, symptomList: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, title: title, removeMaxMinHint: healthMetric != .menstrualBleeding)
                    
                    let symptomModel = SymptomModel(
                        title: title,
                        dateRange: dateRangeDict[.last]!,
                        cycleOverview: cycleOverviewLast,
                        hints: hints,
                        min: statistics[0],
                        max: statistics[1],
                        average: statistics[2],
                        covariance: covarianceAndList.0,
                        correlationOverview: covarianceAndList.1,
                        questionType: questionType)
                    
                    var preexistingSymptomList = collectedSymptomDict[.last]!
                    preexistingSymptomList.append(symptomModel)
                    collectedSymptomDict[.last] = preexistingSymptomList
                    
                }
                
                if availableCycles >= 3 {
                    let hints : [String] = buildSymptomHints(cycleOverview: cycleOverviewSecondToLast, symptomList: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, title: title, removeMaxMinHint: healthMetric != .menstrualBleeding)
                    
                    let symptomModel = SymptomModel(
                        title: title,
                        dateRange: dateRangeDict[.secondToLast]!,
                        cycleOverview: cycleOverviewSecondToLast,
                        hints: hints,
                        min: statistics[0],
                        max: statistics[1],
                        average: statistics[2],
                        covariance: covarianceAndList.0,
                        correlationOverview: covarianceAndList.1,
                        questionType: questionType)
                    
                    var preexistingSymptomList = collectedSymptomDict[.secondToLast]!
                    preexistingSymptomList.append(symptomModel)
                    collectedSymptomDict[.secondToLast] = preexistingSymptomList
                }
            }
        }
        return collectedSymptomDict
    }
    
}
