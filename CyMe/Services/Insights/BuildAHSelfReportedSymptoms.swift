//
//  BuildAHSelfReportedSymptoms.swift
//  CyMe
//
//  Created by Deborah on 02.08.2024.
//

import Foundation

class BuildAHSelfReportedSymptoms{
    let handeledByThisClass : [availableHealthMetrics] = [.headache, .abdominalCramps, .lowerBackPain, .pelvicPain, .acne, .chestTightnessOrPain, .appetiteChange]
    
    var relevantDataList : [availableHealthMetrics]
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel]
    var availableCycles : Int
    var menstruationRanges : MenstruationRanges
    
    let healthMetricToTitle : [availableHealthMetrics : String] = [.headache : "Headache", .abdominalCramps : "Abdominal Cramps", .lowerBackPain : "Lower Back Pain", .pelvicPain : "Pelvic Pain", .acne : "Acne", .chestTightnessOrPain : "Chest Tightness or Pain", .appetiteChange : "Appetite Change"]
    let healthMetricToQuestionType : [availableHealthMetrics : QuestionType] = [.headache : .painEmoticonRating, .abdominalCramps : .painEmoticonRating, .lowerBackPain : .painEmoticonRating, .pelvicPain : .painEmoticonRating, .acne : .painEmoticonRating, .chestTightnessOrPain : .painEmoticonRating, .appetiteChange : .changeEmoticonRating]
    
    
    
    init(relevantDataList: [availableHealthMetrics], combinedDataDict : [cycleTimeOptions : CombinedDataModel], menstruationRanges : MenstruationRanges, availableCycles : Int) {
        self.relevantDataList = relevantDataList
        self.combinedDataDict = combinedDataDict
        self.availableCycles = availableCycles
        self.menstruationRanges = menstruationRanges
        
        
    }
    
    func buildSelfReportedSymptoms() -> [cycleTimeOptions : [SymptomModel]] {
        let dateRangeDict : [cycleTimeOptions : [Date]] = [.current : menstruationRanges.currentDateRange, .last : menstruationRanges.lastFullCycleDateRange, .secondToLast : menstruationRanges.secondToLastFullCycleDateRange]
        
        var selfReportedSymptomDict : [cycleTimeOptions : [SymptomModel]] = [.current : [], .last : [], .secondToLast : []]
        
        
        for healthMetric in relevantDataList{
            if handeledByThisClass.contains(healthMetric) {
                
                let title = healthMetricToTitle[healthMetric]!
                let questionType = healthMetricToQuestionType[healthMetric]!
                
                
                var cycleOverviewCurrent : [Int?] = []
                var cycleOverviewLast : [Int?] = []
                var cycleOverviewSecondToLast : [Int?] = []
                
                if availableCycles == 0 {
                    return selfReportedSymptomDict
                }
                
                if availableCycles >= 1 {
                    cycleOverviewCurrent = buildSymptomGraphArray(symptomList: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, appetiteChange: healthMetric == .appetiteChange)
                }
                
                if availableCycles >= 2 {
                    cycleOverviewLast = buildSymptomGraphArray(symptomList: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, appetiteChange: healthMetric == .appetiteChange)
                }
                
                if availableCycles >= 3 {
                    cycleOverviewSecondToLast = buildSymptomGraphArray(symptomList: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, appetiteChange: healthMetric == .appetiteChange)
                }
                
                var statistics : [String]
                if availableCycles < 2 {
                    statistics = ["You don't have two cycles started to compare :(", "", ""]
                }
                else {
                    statistics = buildSymptomMinMaxAverage(symptomListCurrent: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), symptomListLast: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), symptomListSecondToLast: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), title: title, availableCycles: availableCycles)
                }
                
                let covarianceAndList =  buildCorrelation(cycleOverviewCurrent: cycleOverviewCurrent, cycleOverviewLast:  cycleOverviewLast, cycleOverviewSecondToLast:  cycleOverviewSecondToLast, cyclesAvailable: availableCycles)
                
                
                if availableCycles >= 1 {
                    let hints : [String] = buildSymptomHints(cycleOverview: cycleOverviewCurrent, symptomList: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, title: title, removeMaxMinHint: healthMetric == .appetiteChange)
                    
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
                    
                    var preexistingSymptomList = selfReportedSymptomDict[.current]!
                    preexistingSymptomList.append(symptomModel)
                    selfReportedSymptomDict[.current] = preexistingSymptomList
                }
                
                if availableCycles >= 2 {
                    let hints : [String] = buildSymptomHints(cycleOverview: cycleOverviewLast, symptomList: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, title: title, removeMaxMinHint: healthMetric == .appetiteChange)
                    
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
                    
                    var preexistingSymptomList = selfReportedSymptomDict[.last]!
                    preexistingSymptomList.append(symptomModel)
                    selfReportedSymptomDict[.last] = preexistingSymptomList
                    
                }
                
                if availableCycles >= 3 {
                    let hints : [String] = buildSymptomHints(cycleOverview: cycleOverviewSecondToLast, symptomList: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, title: title, removeMaxMinHint: healthMetric == .appetiteChange)
                    
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
                    
                    var preexistingSymptomList = selfReportedSymptomDict[.secondToLast]!
                    preexistingSymptomList.append(symptomModel)
                    selfReportedSymptomDict[.secondToLast] = preexistingSymptomList
                }
            }
        }
        
        return selfReportedSymptomDict
    }
}
