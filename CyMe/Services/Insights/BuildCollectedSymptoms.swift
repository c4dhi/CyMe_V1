//
//  BuildCollectedSymptoms.swift
//  CyMe
//
//  Created by Deborah on 02.08.2024.
//

import Foundation

class BuildCollectedSymptoms{
    let handeledByThisClass : [availableHealthMetrics] = [.sleepLength, .exerciseTime, .stepCount]
    
    var relevantDataList : [availableHealthMetrics]
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel]
    var availableCycles : Int
    var menstruationRanges : MenstruationRanges
    
    let healthMetricToTitle : [availableHealthMetrics : String] = [.sleepLength : "Sleep Length", .exerciseTime : "Exercise Time", .stepCount : "Step Count"]
    let healthMetricToQuestionType : [availableHealthMetrics : QuestionType] =  [.sleepLength : .amountOfhour, .exerciseTime : .amountOfhour, .stepCount : .amountOfSteps]
    
    
    
    init(relevantDataList: [availableHealthMetrics], combinedDataDict : [cycleTimeOptions : CombinedDataModel], menstruationRanges : MenstruationRanges, availableCycles : Int) {
        self.relevantDataList = relevantDataList
        self.combinedDataDict = combinedDataDict
        self.availableCycles = availableCycles
        self.menstruationRanges = menstruationRanges
        
        
    }
    
    func buildCollectedSymptoms() -> [cycleTimeOptions : [SymptomModel]] {
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
                    cycleOverviewCurrent = buildcollectedDataGraphArray(symptomList: combinedDataDict[.current]!.getDataDict(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, sleepLength : healthMetric == .sleepLength)
                }
                
                if availableCycles >= 2 {
                    cycleOverviewLast = buildcollectedDataGraphArray(symptomList: combinedDataDict[.last]!.getDataDict(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, sleepLength : healthMetric == .sleepLength)
                }
                
                if availableCycles >= 3 {
                    cycleOverviewSecondToLast = buildcollectedDataGraphArray(symptomList: combinedDataDict[.secondToLast]!.getDataDict(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, sleepLength : healthMetric == .sleepLength)
                }
                
                let statistics = buildCollectedQuantityMinMaxAverage(cycleOverviewCurrent: cycleOverviewCurrent, cycleOverviewLast: cycleOverviewLast, cycleOverviewSecondToLast: cycleOverviewSecondToLast, availableCycles: availableCycles, title: title, type: healthMetric)
                let covarianceAndList =  buildCorrelation(cycleOverviewCurrent: cycleOverviewCurrent, cycleOverviewLast:  cycleOverviewLast, cycleOverviewSecondToLast:  cycleOverviewSecondToLast, cyclesAvailable: availableCycles)
                
                
                if availableCycles >= 1 {
                    let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverviewCurrent, title: title, type : healthMetric)
                    
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
                    let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverviewLast, title: title, type : healthMetric)
                    
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
                    let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverviewSecondToLast, title: title, type : healthMetric)
                    
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

