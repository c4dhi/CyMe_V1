//
//  BuildSymptoms.swift
//  CyMe
//
//  Created by Deborah on 02.08.2024.
//

import Foundation

class BuildSymptoms{
    let collectedSymptoms : [availableHealthMetrics] = [.sleepLength, .exerciseTime, .stepCount]
    let appleHealthSelfreport : [availableHealthMetrics] = [.headache, .abdominalCramps, .lowerBackPain, .pelvicPain, .acne, .chestTightnessOrPain, .appetiteChange]
    let cyMeSelfReport : [availableHealthMetrics] = [.menstrualBleeding, .stress, .sleepQuality, .mood]
    
    var relevantDataList : [availableHealthMetrics]
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel]
    var availableCycles : Int
    var menstruationRanges : MenstruationRanges
    
    let healthMetricToTitle : [availableHealthMetrics : String] = [.sleepLength : "Sleep length", .exerciseTime : "Exercise time", .stepCount : "Step count", .headache : "Headache", .abdominalCramps : "Abdominal cramps", .lowerBackPain : "Lower back pain", .pelvicPain : "Pelvic pain", .acne : "Acne", .chestTightnessOrPain : "Chest tightness or pain", .appetiteChange : "Appetite change", .stress : "Stress", .sleepQuality : "Sleep quality", .mood : "Mood", .menstrualBleeding : "Menstruation"]
    let healthMetricToQuestionType : [availableHealthMetrics : QuestionType] =  [.sleepLength : .amountOfhour, .exerciseTime : .amountOfMin, .stepCount : .amountOfSteps, .headache : .painEmoticonRating, .abdominalCramps : .painEmoticonRating, .lowerBackPain : .painEmoticonRating, .pelvicPain : .painEmoticonRating, .acne : .painEmoticonRating, .chestTightnessOrPain : .painEmoticonRating, .appetiteChange : .changeEmoticonRating, .stress : .emoticonRating, .sleepQuality : .emoticonRating, .mood : .emoticonRating, .menstrualBleeding : .menstruationEmoticonRating]
    
    init(relevantDataList: [availableHealthMetrics], combinedDataDict : [cycleTimeOptions : CombinedDataModel], menstruationRanges : MenstruationRanges, availableCycles : Int) {
        self.relevantDataList = relevantDataList
        self.combinedDataDict = combinedDataDict
        self.availableCycles = availableCycles
        self.menstruationRanges = menstruationRanges
    }
    
    func buildSymptoms() -> [cycleTimeOptions : [SymptomModel]] {
        let dateRangeDict : [cycleTimeOptions : [Date]] = [.current : menstruationRanges.currentDateRange, .last : menstruationRanges.lastFullCycleDateRange, .secondToLast : menstruationRanges.secondToLastFullCycleDateRange]
        
        var symptomDict : [cycleTimeOptions : [SymptomModel]] = [.current : [], .last : [], .secondToLast : []]
        
        
        for healthMetric in relevantDataList{
            
            if healthMetric == .menstrualStart{ // Menstrual Start is integrated in Menstrual Bleeding
                continue
            }
            
            let title = healthMetricToTitle[healthMetric]!
            let questionType = healthMetricToQuestionType[healthMetric]!
            
            
            var cycleOverviewCurrent : [Int?] = []
            var cycleOverviewLast : [Int?] = []
            var cycleOverviewSecondToLast : [Int?] = []
            
            if availableCycles == 0 {
                return symptomDict
            }
        
            if availableCycles >= 1 {
                if collectedSymptoms.contains(healthMetric){
                    cycleOverviewCurrent = buildDataGraphArray(symptomList: combinedDataDict[.current]!.getDataDict(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, type : healthMetric)
                }
                else{ // Different DataRetrieval from combinedDataModel
                    cycleOverviewCurrent = buildDataGraphArray(symptomList: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, type: healthMetric)
                }
            }
            
            if availableCycles >= 2 {
                if collectedSymptoms.contains(healthMetric){
                    cycleOverviewLast = buildDataGraphArray(symptomList: combinedDataDict[.last]!.getDataDict(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, type : healthMetric )
                }
                else{ // Different DataRetrieval from combinedDataModel
                    cycleOverviewLast = buildDataGraphArray(symptomList: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, type: healthMetric )
                }
            }
            
            if availableCycles >= 3 {
                if collectedSymptoms.contains(healthMetric){
                    cycleOverviewSecondToLast = buildDataGraphArray(symptomList: combinedDataDict[.secondToLast]!.getDataDict(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, type : healthMetric)
                }
                else{ // Different DataRetrieval from combinedDataModel
                    cycleOverviewSecondToLast = buildDataGraphArray(symptomList: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, type: healthMetric)
                }
            }
            
            
            var statistics : [String]
            if availableCycles <= 2 {
                statistics = ["You don't have two cycles started to compare :(", "", ""]
            }
            else {
                if collectedSymptoms.contains(healthMetric){
                    statistics = buildMinMaxAverage(cycleOverviewCurrent: cycleOverviewCurrent, cycleOverviewLast: cycleOverviewLast, cycleOverviewSecondToLast: cycleOverviewSecondToLast, title: title, availableCycles: availableCycles, type: healthMetric)
                }
                else{
                    statistics = buildMinMaxAverage(symptomListCurrent: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), symptomListLast: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), symptomListSecondToLast: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), title: title, availableCycles: availableCycles)
                }
                
            }
            
            let correlationAndList =  buildCorrelation(cycleOverviewCurrent: cycleOverviewCurrent, cycleOverviewLast:  cycleOverviewLast, cycleOverviewSecondToLast:  cycleOverviewSecondToLast, cyclesAvailable: availableCycles)
            
            let minMaxHintDisabled = (healthMetric == .appetiteChange  || healthMetric == .menstrualBleeding) || cyMeSelfReport.contains(healthMetric)
            
            if availableCycles >= 1 {
                let hints : [String] 
                if collectedSymptoms.contains(healthMetric){
                    hints = buildHints(cycleOverview: cycleOverviewCurrent, title: title, type : healthMetric)
                }
                else{
                    hints = buildHints(cycleOverview: cycleOverviewCurrent, symptomList: combinedDataDict[.current]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.current]!, title: title, removeMaxMinHint: minMaxHintDisabled)
                }
                
                let symptomModel = SymptomModel(
                    title: title,
                    dateRange: dateRangeDict[.current]!,
                    cycleOverview: cycleOverviewCurrent,
                    hints: hints,
                    min: statistics[0],
                    max: statistics[1],
                    average: statistics[2],
                    correlation: correlationAndList.0,
                    correlationOverview: correlationAndList.1,
                    questionType: questionType)
                
                var preexistingSymptomList = symptomDict[.current]!
                preexistingSymptomList.append(symptomModel)
                symptomDict[.current] = preexistingSymptomList
            }
            
            if availableCycles >= 2 {
                let hints : [String]
                if collectedSymptoms.contains(healthMetric){
                    hints = buildHints(cycleOverview: cycleOverviewLast, title: title, type : healthMetric)
                }
                else{
                    hints = buildHints(cycleOverview: cycleOverviewLast, symptomList: combinedDataDict[.last]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.last]!, title: title, removeMaxMinHint: minMaxHintDisabled)
                }
              
                
                let symptomModel = SymptomModel(
                    title: title,
                    dateRange: dateRangeDict[.last]!,
                    cycleOverview: cycleOverviewLast,
                    hints: hints,
                    min: statistics[0],
                    max: statistics[1],
                    average: statistics[2],
                    correlation: correlationAndList.0,
                    correlationOverview: correlationAndList.1,
                    questionType: questionType)
                
                var preexistingSymptomList = symptomDict[.last]!
                preexistingSymptomList.append(symptomModel)
                symptomDict[.last] = preexistingSymptomList
                
            }
            
            if availableCycles >= 3 {
                let hints : [String]
                if collectedSymptoms.contains(healthMetric){
                    hints =  buildHints(cycleOverview: cycleOverviewSecondToLast, title: title, type : healthMetric)
                }
                else{
                    hints = buildHints(cycleOverview: cycleOverviewSecondToLast, symptomList: combinedDataDict[.secondToLast]!.getDataList(healthMetric: healthMetric), dateRange: dateRangeDict[.secondToLast]!, title: title, removeMaxMinHint: minMaxHintDisabled)
                }
               
                
                let symptomModel = SymptomModel(
                    title: title,
                    dateRange: dateRangeDict[.secondToLast]!,
                    cycleOverview: cycleOverviewSecondToLast,
                    hints: hints,
                    min: statistics[0],
                    max: statistics[1],
                    average: statistics[2],
                    correlation: correlationAndList.0,
                    correlationOverview: correlationAndList.1,
                    questionType: questionType)
                
                var preexistingSymptomList = symptomDict[.secondToLast]!
                preexistingSymptomList.append(symptomModel)
                symptomDict[.secondToLast] = preexistingSymptomList
            }
            
        }
        
        return symptomDict
    }
}

