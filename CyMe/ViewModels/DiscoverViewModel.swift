//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.

import Foundation
import SigmaSwiftStatistics
import HealthKit



class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    var selfReports: [ReviewReportModel] = []
    
    var reportingDatabaseService: ReportingDatabaseService
    
    var symptomsCurrentCycle : [SymptomModel] = []
    var symptomsLastFullCycle : [SymptomModel] = []
    var symptomsSecondToLastFullCycle : [SymptomModel] = []

    var combinedDataModelCurrent : CombinedDataModel
    var combinedDataModelLast : CombinedDataModel
    var combinedDataModelSecondToLast : CombinedDataModel
    var availableCycles : Int = 0
     
    var relevantDataClass : RelevantData
    var menstruationRanges : MenstruationRanges
    

    init() {
        reportingDatabaseService =  ReportingDatabaseService()
        
        combinedDataModelCurrent = CombinedDataModel()
        combinedDataModelLast = CombinedDataModel()
        combinedDataModelSecondToLast = CombinedDataModel()
        
        relevantDataClass = RelevantData()
        menstruationRanges = MenstruationRanges()
        
        Task{
            await updateSymptoms()
        }
    }
    
    
    func updateSymptoms (currentCycle : Bool = true) async {
        
        //await menstruationRanges.getLastPeriodDates()
        //await relevantDataClass.getRelevantDataLists()
        
        let fillCombinedDataModel = await fillCombinedDataModel(menstruationRanges: menstruationRanges, relevantData: relevantDataClass)
            
        combinedDataModelCurrent = fillCombinedDataModel.combinedDataDict[.current]!
        combinedDataModelLast = fillCombinedDataModel.combinedDataDict[.last]!
        combinedDataModelSecondToLast = fillCombinedDataModel.combinedDataDict[.secondToLast]!
        
        selfReports = fillCombinedDataModel.selfReports
        availableCycles = fillCombinedDataModel.availableCycles
        
        
        if availableCycles >= 1 {
                    symptomsCurrentCycle = buildSymptomModels(relevantDataList : relevantDataClass.relevantForDisplay, dateRange: menstruationRanges.currentDateRange, combinedDataModel : combinedDataModelCurrent)
                }
                else {
                    symptomsCurrentCycle = []
                }
                
                if availableCycles >= 2 {
                    symptomsLastFullCycle = buildSymptomModels(relevantDataList : relevantDataClass.relevantForDisplay, dateRange: menstruationRanges.lastFullCycleDateRange, combinedDataModel : combinedDataModelLast)
                }
                else {
                    symptomsLastFullCycle = []
                }
                if availableCycles >= 3 {
                    symptomsSecondToLastFullCycle = buildSymptomModels(relevantDataList : relevantDataClass.relevantForDisplay, dateRange: menstruationRanges.secondToLastFullCycleDateRange, combinedDataModel : combinedDataModelSecondToLast)
                }
                else{
                    symptomsSecondToLastFullCycle = []
                }
        
        // Refactor from here
        DispatchQueue.main.async {
            print("Hi")
            if currentCycle{
                self.symptoms = self.symptomsCurrentCycle
            }
            else { // Display the last full cycle
                self.symptoms = self.symptomsLastFullCycle
            }
        }
    }
    
    func buildSingleSymptomModel (title: String, symptomList : [DataProtocoll], dateRange : [Date], appetiteChange : Bool = false, statistics : [String], covarianceAndList : (Float, [[Int?]])) -> SymptomModel {
        let cycleOverview : [Int?] =  buildSymptomGraphArray(symptomList: symptomList, dateRange: dateRange, appetiteChange: appetiteChange)
        let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange: dateRange, title: title, removeMaxMinHint: appetiteChange)
        
        var questionType : QuestionType
        
        if appetiteChange { questionType = .changeEmoticonRating }
        else { questionType = .painEmoticonRating }
        
        let symptomModel = SymptomModel(
            title: title,
            dateRange: dateRange,
            cycleOverview: cycleOverview,
            hints: hints,
            min: statistics[0],
            max: statistics[1],
            average: statistics[2],
            covariance: covarianceAndList.0,
            correlationOverview: covarianceAndList.1,
            questionType: questionType
        )
        return symptomModel
    }
    
    func buildSymptomModels (relevantDataList : [availableHealthMetrics], dateRange: [Date], combinedDataModel : CombinedDataModel) -> [SymptomModel]{
        var symptomListToReturn  : [SymptomModel] = []
        
        let startDate = menstruationRanges.getAppropriateStartDate(firstEntry: dateRange[0])
        let endDate =  menstruationRanges.getAppropriateEndDate(lastEntry: dateRange[dateRange.count-1])
        
        
        // We will always display bleeding
        let title = "Menstrual Bleeding"
        var symptomList : [DataProtocoll] = []
        
        for period in combinedDataModel.periodDataList{
            if (period.startdate >= startDate) && (period.startdate <= endDate){
                symptomList.append(period)
            }
        }
    
    
        let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange, period: true)
        let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange: dateRange, title: title)
        let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.periodDataList, symptomListLast: self.combinedDataModelLast.periodDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.periodDataList, title: title, availableCycles: availableCycles)
        let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildCyMeGraphArray(symptomList: combinedDataModelCurrent.periodDataList, dateRange: menstruationRanges.currentDateRange, period: true), cycleOverviewLast:  buildCyMeGraphArray(symptomList: combinedDataModelLast.periodDataList, dateRange: menstruationRanges.lastFullCycleDateRange, period: true), cycleOverviewSecondToLast:  buildCyMeGraphArray(symptomList: combinedDataModelSecondToLast.periodDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange, period: true), cyclesAvailable: availableCycles)
        
        let symptomModel = SymptomModel(
            title: title,
            dateRange: dateRange,
            cycleOverview: cycleOverview,
            hints: hints,
            min: statistics[0],
            max: statistics[1],
            average: statistics[2],
            covariance: covarianceAndList.0,
            correlationOverview: covarianceAndList.1,
            questionType: .menstruationEmoticonRating)
        symptomListToReturn.append(symptomModel)
        
        
        
        if relevantDataList.contains(.headache){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.headacheDataList, symptomListLast: self.combinedDataModelLast.headacheDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.headacheDataList, title: "Headaches", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.headacheDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.headacheDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.headacheDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Headaches", symptomList: combinedDataModel.headacheDataList, dateRange: dateRange, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.abdominalCramps){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.abdominalCrampsDataList, symptomListLast: self.combinedDataModelLast.abdominalCrampsDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.abdominalCrampsDataList, title: "Abdominal Cramps", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.abdominalCrampsDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.abdominalCrampsDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.abdominalCrampsDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Abdominal Cramps", symptomList: combinedDataModel.abdominalCrampsDataList, dateRange: dateRange, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.lowerBackPain){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.lowerBackPainDataList, symptomListLast: self.combinedDataModelLast.lowerBackPainDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.lowerBackPainDataList, title: "Lower Back Pain", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.lowerBackPainDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.lowerBackPainDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.lowerBackPainDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Lower Back Pain", symptomList: combinedDataModel.lowerBackPainDataList, dateRange: dateRange, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.pelvicPain){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.pelvicPainDataList, symptomListLast: self.combinedDataModelLast.pelvicPainDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.pelvicPainDataList, title: "Pelvic Pain", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.pelvicPainDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.pelvicPainDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.pelvicPainDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Pelvic Pain", symptomList: combinedDataModel.pelvicPainDataList, dateRange: dateRange, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.acne){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.acneDataList, symptomListLast: self.combinedDataModelLast.acneDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.acneDataList, title: "Acne", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.acneDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.acneDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.acneDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Acne", symptomList: combinedDataModel.acneDataList, dateRange: dateRange, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.chestTightnessOrPainDataList, symptomListLast: self.combinedDataModelLast.chestTightnessOrPainDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.chestTightnessOrPainDataList, title: "Chest Tightness or Pain", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.chestTightnessOrPainDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.chestTightnessOrPainDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.chestTightnessOrPainDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Chest Tightness or Pain", symptomList: combinedDataModel.chestTightnessOrPainDataList, dateRange: dateRange, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
           
        }
        
        if relevantDataList.contains(.appetiteChange){
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.appetiteChangeDataList, symptomListLast: self.combinedDataModelLast.appetiteChangeDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.appetiteChangeDataList, title: "Appetite Change", availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildSymptomGraphArray(symptomList: combinedDataModelCurrent.appetiteChangeDataList, dateRange: menstruationRanges.currentDateRange, appetiteChange: true), cycleOverviewLast:  buildSymptomGraphArray(symptomList: combinedDataModelLast.appetiteChangeDataList, dateRange: menstruationRanges.lastFullCycleDateRange, appetiteChange: true), cycleOverviewSecondToLast:  buildSymptomGraphArray(symptomList: combinedDataModelSecondToLast.appetiteChangeDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange, appetiteChange: true), cyclesAvailable: availableCycles)
            let symptomModel = buildSingleSymptomModel(title: "Appetite Change", symptomList: combinedDataModel.appetiteChangeDataList, dateRange: dateRange, appetiteChange: true, statistics: statistics, covarianceAndList: covarianceAndList)
            symptomListToReturn.append(symptomModel)
        }
        
        
        if relevantDataList.contains(.sleepLength){
            let title = "Sleep Length"
            let symptomList = combinedDataModel.sleepLengthDataList
            
            let cycleOverview : [Int?] =  buildcollectedDataGraphArray(symptomList: symptomList, dateRange: dateRange, sleepLength: true)
            
            let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverview, title: title, type : .sleepLength)
            let statistics : [String] = buildCollectedQuantityMinMaxAverage(cycleOverviewCurrent: buildcollectedDataGraphArray(symptomList: combinedDataModelCurrent.sleepLengthDataList, dateRange: menstruationRanges.currentDateRange, sleepLength: true), cycleOverviewLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelLast.sleepLengthDataList, dateRange: menstruationRanges.lastFullCycleDateRange, sleepLength: true), cycleOverviewSecondToLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelSecondToLast.sleepLengthDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange, sleepLength: true), availableCycles: availableCycles, title: title, type: .sleepLength)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildcollectedDataGraphArray(symptomList: combinedDataModelCurrent.sleepLengthDataList, dateRange: menstruationRanges.currentDateRange, sleepLength: true), cycleOverviewLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelLast.sleepLengthDataList, dateRange: menstruationRanges.lastFullCycleDateRange, sleepLength: true), cycleOverviewSecondToLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelSecondToLast.sleepLengthDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange, sleepLength: true), cyclesAvailable: availableCycles)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covarianceAndList.0,
                correlationOverview: covarianceAndList.1,
                questionType: .amountOfhour //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.exerciseTime){
            let title = "Exercise Time"
            let symptomList = combinedDataModel.exerciseTimeDataList
            
            let cycleOverview : [Int?] =  buildcollectedDataGraphArray(symptomList: symptomList, dateRange: dateRange)
            let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverview, title: title, type : .exerciseTime)
            let statistics : [String] = buildCollectedQuantityMinMaxAverage(cycleOverviewCurrent: buildcollectedDataGraphArray(symptomList: combinedDataModelCurrent.exerciseTimeDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelLast.exerciseTimeDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelSecondToLast.exerciseTimeDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), availableCycles: availableCycles, title: title, type: .exerciseTime)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildcollectedDataGraphArray(symptomList: combinedDataModelCurrent.exerciseTimeDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelLast.exerciseTimeDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelSecondToLast.exerciseTimeDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covarianceAndList.0,
                correlationOverview: covarianceAndList.1,
                questionType: .amountOfhour //TODO
            )
            
            symptomListToReturn.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.stepCount){
            let title = "Step Count"
            let symptomList = combinedDataModel.stepCountDataList
            
            let cycleOverview : [Int?] =  buildcollectedDataGraphArray(symptomList: symptomList, dateRange: dateRange)
            let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverview, title: title, type : .stepCount)
            let statistics : [String] = buildCollectedQuantityMinMaxAverage(cycleOverviewCurrent: buildcollectedDataGraphArray(symptomList: combinedDataModelCurrent.stepCountDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelLast.stepCountDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelSecondToLast.stepCountDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), availableCycles: availableCycles, title: title, type: .stepCount)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildcollectedDataGraphArray(symptomList: combinedDataModelCurrent.stepCountDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelLast.stepCountDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildcollectedDataGraphArray(symptomList: combinedDataModelSecondToLast.stepCountDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)

                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covarianceAndList.0,
                correlationOverview: covarianceAndList.1,
                questionType: .amountOfhour //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.mood){
            let title = "Mood"
            let symptomList = combinedDataModel.moodDataList
            
            let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange)
           
            let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange:  dateRange, title: title, removeMaxMinHint: true)
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.moodDataList, symptomListLast: self.combinedDataModelLast.moodDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.moodDataList, title: title, availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildCyMeGraphArray(symptomList: combinedDataModelCurrent.moodDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildCyMeGraphArray(symptomList: combinedDataModelLast.moodDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildCyMeGraphArray(symptomList: combinedDataModelSecondToLast.moodDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
             
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covarianceAndList.0,
                correlationOverview: covarianceAndList.1,
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.stress){
            let title = "Stress"
            let symptomList = combinedDataModel.stressDataList
            
            let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange)
           
            let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange:  dateRange, title: title, removeMaxMinHint: true)
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.stressDataList, symptomListLast: self.combinedDataModelLast.stressDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.stressDataList, title: title, availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildCyMeGraphArray(symptomList: combinedDataModelCurrent.stressDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildCyMeGraphArray(symptomList: combinedDataModelLast.stressDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildCyMeGraphArray(symptomList: combinedDataModelSecondToLast.stressDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
             
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covarianceAndList.0,
                correlationOverview: covarianceAndList.1,
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.sleepQuality){
            let title = "Sleep Quality"
            let symptomList = combinedDataModel.sleepQualityDataList
            
            let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange)
           
            let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange:  dateRange, title: title, removeMaxMinHint: true)
            let statistics : [String] = buildSymptomMinMaxAverage(symptomListCurrent: self.combinedDataModelCurrent.sleepQualityDataList, symptomListLast: self.combinedDataModelLast.sleepQualityDataList, symptomListSecondToLast: self.combinedDataModelSecondToLast.sleepQualityDataList, title: title, availableCycles: availableCycles)
            let covarianceAndList : (Float, [[Int?]]) = buildCorrelation(cycleOverviewCurrent: buildCyMeGraphArray(symptomList: combinedDataModelCurrent.sleepQualityDataList, dateRange: menstruationRanges.currentDateRange), cycleOverviewLast:  buildCyMeGraphArray(symptomList: combinedDataModelLast.sleepQualityDataList, dateRange: menstruationRanges.lastFullCycleDateRange), cycleOverviewSecondToLast:  buildCyMeGraphArray(symptomList: combinedDataModelSecondToLast.sleepQualityDataList, dateRange: menstruationRanges.secondToLastFullCycleDateRange), cyclesAvailable: availableCycles)
             
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covarianceAndList.0,
                correlationOverview: covarianceAndList.1,
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
            
        }
        return symptomListToReturn
    }
}
