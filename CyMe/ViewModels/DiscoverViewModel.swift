//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.

import Foundation
import SigmaSwiftStatistics
import HealthKit



enum availableHealthMetrics: String {
    case headache
    case abdominalCramps
    case lowerBackPain
    case pelvicPain
    case acne
    case chestTightnessOrPain
    case appetiteChange
    case sleepLength
    case exerciseTime
    case stepCount
    case stress
    case sleepQuality
    case mood
    case menstrualBleeding
    case menstrualStart
}

enum timeRange : String{
    case current
    case last
    case secondToLast
}

class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    
    var healthKitService: HealthKitService
    var reportingDatabaseService: ReportingDatabaseService
    
    var symptomsCurrentCycle : [SymptomModel] = []
    var symptomsLastFullCycle : [SymptomModel] = []
    var symptomsSecondToLastFullCycle : [SymptomModel] = []

    var combinedDataModelCurrent : CombinedDataModel
    var combinedDataModelLast : CombinedDataModel
    var combinedDataModelSecondToLast : CombinedDataModel
    
    var relevantDataClass : RelevantData
    var menstruationRanges : MenstruationRanges
    
    var availableCycles = 0
    
    let verbose = false

    

    init() {
        healthKitService = HealthKitService()
        reportingDatabaseService =  ReportingDatabaseService()
        
        combinedDataModelCurrent = CombinedDataModel()
        combinedDataModelLast = CombinedDataModel()
        combinedDataModelSecondToLast = CombinedDataModel()
        
        
        relevantDataClass = RelevantData()
        menstruationRanges = MenstruationRanges()
        
        Task {
            await self.updateSymptoms()
        }
    }
    
    
    
    func updateSymptoms (currentCycle : Bool = true) async {
        
        if self.verbose{
            let combinedDataModel = self.combinedDataModelCurrent
            print(combinedDataModel)
            
            print(" Period")
            for period in combinedDataModel.periodDataList { period.print() }
            
            print("\n Headache")
            for data in combinedDataModel.headacheDataList { data.print() }
            
            print("\n Abdominal Cramps")
            for data in combinedDataModel.abdominalCrampsDataList { data.print() }
            
            print("\n Lower Back Pain")
            for data in combinedDataModel.lowerBackPainDataList { data.print() }
            
            print("\n Pelvic Pain")
            for data in combinedDataModel.pelvicPainDataList { data.print() }
            
            print("\n Acne")
            for data in combinedDataModel.acneDataList { data.print() }
            
            print("\n Chest Tightness or Pain")
            for data in combinedDataModel.chestTightnessOrPainDataList { data.print() }
            
            print("\n Appetite Change")
            for data in combinedDataModel.appetiteChangeDataList { data.print() }
            
            print("\n Sleep Length")
            for date in combinedDataModel.sleepLengthDataList.keys.sorted() {
                print(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none), SleepDataModel.formatDuration(duration: Double(combinedDataModel.sleepLengthDataList[date]!))) }
            
            print("\n Exercise Time")
            displayDateDictionary(dict: combinedDataModel.exerciseTimeDataList)
            
            print("\n Step Count")
            displayDateDictionary(dict: combinedDataModel.stepCountDataList)
            
            print("\n Sleep Quality")
            for data in combinedDataModel.sleepQualityDataList { data.print() }
            
            print("\n Mood")
            for data in combinedDataModel.moodDataList { data.print() }
            
            print("\n Stress")
            for data in combinedDataModel.stressDataList { data.print() }
        }
        
        
        combinedDataModelCurrent = CombinedDataModel()
        combinedDataModelLast = CombinedDataModel()
        combinedDataModelSecondToLast = CombinedDataModel()
        await relevantDataClass.getRelevantDataLists()
        
        
        await menstruationRanges.getLastPeriodDates()
        if menstruationRanges.currentDateRange.count == 0 {
            return // There is no period date to be detected
        }
        
        if(menstruationRanges.currentDateRange.count > 0){
            await getCombinedDataModel(dateRange: menstruationRanges.currentDateRange, label: .current)
            availableCycles = 1
        }
        
        if(menstruationRanges.lastFullCycleDateRange.count > 0){
            await getCombinedDataModel(dateRange: menstruationRanges.lastFullCycleDateRange, label: .last)
            availableCycles = 2
        }
        
        if(menstruationRanges.secondToLastFullCycleDateRange.count > 0){
            await getCombinedDataModel(dateRange: menstruationRanges.secondToLastFullCycleDateRange, label: .secondToLast)
            availableCycles = 3
        }
        
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
        
        DispatchQueue.main.async {
            if currentCycle{
                self.symptoms = self.symptomsCurrentCycle
            }
            else { // Display the last full cycle
                self.symptoms = self.symptomsLastFullCycle
            }
        }
        
    }
    
    
    func getCombinedDataModel(dateRange : [Date], label: timeRange) async  {
        
        var combinedDataModelToReturn = CombinedDataModel()
        
        let startDate = menstruationRanges.getAppropriateStartDate(firstEntry: dateRange[0])
        let endDate =  menstruationRanges.getAppropriateEndDate(lastEntry: dateRange[dateRange.count-1])
        
        await fetchRelevantAppleHealthData(relevantDataList : relevantDataClass.relevantForAppleHealthFetch, startDate: startDate, endDate: endDate, combinedDataModel: &combinedDataModelToReturn)
        
        if label == .current{
            self.combinedDataModelCurrent = combinedDataModelToReturn
            let cyMeModel = await fetchRelevantCyMeData(startDate: startDate, endDate: endDate, timeRange: label)
            self.combinedDataModelCurrent.append(otherModel: cyMeModel)
        }
        if label == .last{
            self.combinedDataModelLast = combinedDataModelToReturn
            let cyMeModel = await fetchRelevantCyMeData(startDate: startDate, endDate: endDate, timeRange: label)
            self.combinedDataModelLast.append(otherModel: cyMeModel)
            
        }
        if label == .secondToLast{
            self.combinedDataModelSecondToLast = combinedDataModelToReturn
            let cyMeModel = await fetchRelevantCyMeData(startDate: startDate, endDate: endDate, timeRange: label)
            self.combinedDataModelSecondToLast.append(otherModel: cyMeModel)
        }
    }
    
   
    
    func fetchRelevantCyMeData(startDate: Date, endDate: Date, timeRange: timeRange) async -> CombinedDataModel  { // Gets the desired data and stores them in class variables
        
        let periodLabelToValue = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 5 ]
        let selfreportedLabelToIntensity = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 1 ]
        let appetiteLabelToIntensity = ["No" : 1, "Less" : 2, "More" :3]
        
        var combinedDataModel : CombinedDataModel
        
        if timeRange == .current{
            combinedDataModel = self.combinedDataModelCurrent
        }
        else if timeRange == .last{
            combinedDataModel = self.combinedDataModelLast
        }
        else if timeRange == .secondToLast{
            combinedDataModel = self.combinedDataModelSecondToLast
        }
        else{
            print("Daterange is not defined", timeRange)
            return CombinedDataModel()
        }
 
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let reports = self.reportingDatabaseService.getReports(from: startDate, to: endDate)
                    
                    for report in reports {
                        let startDate : Date = report.startTime
                        
                        if let menstruationDate = report.menstruationDate{
                            combinedDataModel.periodDataList.append(PeriodSampleModel(startdate: startDate, value: periodLabelToValue[menstruationDate]!, startofPeriod: -1))
                        }
                        
                        if let headache = report.headache{
                            combinedDataModel.headacheDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[headache]!))
                        }
                        
                        if let abdominalCramps = report.abdominalCramps {
                            combinedDataModel.abdominalCrampsDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[abdominalCramps]!))
                        }
                        
                        if let lowerBackPain = report.lowerBackPain {
                            combinedDataModel.lowerBackPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[lowerBackPain]!))
                        }
                        
                        if let pelvicPain = report.pelvicPain   {
                            combinedDataModel.pelvicPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[pelvicPain]!))
                        }
                        
                        if let acne = report.acne   {
                            combinedDataModel.acneDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[acne]!))
                        }
                        
                        if let chestPain = report.chestPain   {
                            combinedDataModel.chestTightnessOrPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[chestPain]!))
                        }
                        
                        if let appetiteChanges = report.appetiteChanges   {
                            combinedDataModel.appetiteChangeDataList.append(AppetiteChangeModel(startdate: startDate, intensity: appetiteLabelToIntensity[appetiteChanges]!))
                        }
                        
                        if let sleepQuality = report.sleepQuality {
                            combinedDataModel.sleepQualityDataList.append(CyMeSefReportModel(startdate: startDate, label: sleepQuality))
                        }
                        
                        if let stress = report.stress {
                            combinedDataModel.stressDataList.append(CyMeSefReportModel(startdate: startDate, label: stress))
                        }
                        
                        if let mood = report.mood {
                            combinedDataModel.moodDataList.append(CyMeSefReportModel(startdate: startDate, label: mood))
                        }
                        
                        if let sleepLenght = report.sleepLenght {
                            let sleepLengthInMinutes = getTimeRepresentationFromString(timeString : sleepLenght)
                            if sleepLengthInMinutes != -1 {
                                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
                                let noonOfSelfreportDate = Calendar.current.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: 12, minute: 00, second: 00))!
                                let nightDate = Calendar.current.date(byAdding: .hour, value: -24, to: noonOfSelfreportDate)!
                                combinedDataModel.sleepLengthDataList[nightDate] = sleepLengthInMinutes*60 // We consider seconds
                                // We give priority to internal data
                            }
                        }
                    }
                continuation.resume(returning: combinedDataModel)
            }
        }
        
        }

    func fetchRelevantAppleHealthData(relevantDataList : [availableHealthMetrics], startDate: Date, endDate: Date, combinedDataModel : inout CombinedDataModel) async { // Gets the desired data and stores them in class variables
        
        do { combinedDataModel.periodDataList  = try await healthKitService.fetchPeriodData(startDate : startDate, endDate : endDate) }
        catch { print("Error: \(error)") }
        
        
        if relevantDataList.contains(.headache){
            do { combinedDataModel.headacheDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.abdominalCramps){
            do { combinedDataModel.abdominalCrampsDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.abdominalCramps, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.lowerBackPain){
            do { combinedDataModel.lowerBackPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.lowerBackPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        if relevantDataList.contains(.pelvicPain){
            do { combinedDataModel.pelvicPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.pelvicPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.acne){
            do { combinedDataModel.acneDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.acne, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            do { combinedDataModel.chestTightnessOrPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.chestTightnessOrPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.appetiteChange){
            do { combinedDataModel.appetiteChangeDataList = try await healthKitService.fetchAppetiteChanges(startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.sleepLength){
            var sleepDetailList : [SleepDataModel] = []
            do { sleepDetailList = try await healthKitService.fetchSleepData(startDate: startDate, endDate: endDate)}
            catch { print("Error: \(error)") }
            combinedDataModel.sleepLengthDataList = healthKitService.simplifySleepDataToSleepLength(sleepDataModel: sleepDetailList)
        }
        
        if relevantDataList.contains(.exerciseTime){
            do { combinedDataModel.exerciseTimeDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.appleExerciseTime) }
            catch { print("Error: \(error)") }
            
        }
        
        if relevantDataList.contains(.stepCount){
            do { combinedDataModel.stepCountDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.stepCount) }
            catch { print("Error: \(error)") }
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
            covarianceOverview: covarianceAndList.1,
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
            covarianceOverview: covarianceAndList.1,
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
                covarianceOverview: covarianceAndList.1,
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
                covarianceOverview: covarianceAndList.1,
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
                covarianceOverview: covarianceAndList.1,
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
                covarianceOverview: covarianceAndList.1,
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
                covarianceOverview: covarianceAndList.1,
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
                covarianceOverview: covarianceAndList.1,
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
            
        }
        return symptomListToReturn
    }
}

