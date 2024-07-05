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


class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    
    var symptomsCurrentCycle : [SymptomModel] = []
    var symptomsLastFullCycle : [SymptomModel] = []
    var symptomsSecondToLastFullCycle : [SymptomModel] = []
    
    var healthKitService: HealthKitService
    var reportingDatabaseService: ReportingDatabaseService

    var combindedDataModelCurrent : CombinedDataModel
    var combindedDataModelLast : CombinedDataModel
    var combindedDataModelSecondToLast : CombinedDataModel
    
    var relevantDataClass : RelevantData
    var menstruationRanges : MenstruationRanges
    
    let verbose = false

    

    init() {
        healthKitService = HealthKitService()
        reportingDatabaseService =  ReportingDatabaseService()
        
        combindedDataModelCurrent = CombinedDataModel()
        combindedDataModelLast = CombinedDataModel()
        combindedDataModelSecondToLast = CombinedDataModel()
        
        
        relevantDataClass = RelevantData()
        menstruationRanges = MenstruationRanges()
        
        Task {
            await self.updateSymptoms()
        }
    }
    
    
    
    func updateSymptoms (currentCycle : Bool = true) async {
        
        combindedDataModelCurrent = CombinedDataModel()
        combindedDataModelLast = CombinedDataModel()
        combindedDataModelSecondToLast = CombinedDataModel()
        
        relevantDataClass.getRelevantDataLists()
        
        await menstruationRanges.getLastPeriodDates()
        if menstruationRanges.currentDateRange.count == 0 {
            return // There is no period date to be detected
        }
        
        
        symptomsCurrentCycle = await getSymptomes(dateRange: menstruationRanges.currentDateRange, combinedDataModel: &combindedDataModelCurrent)
        
        symptomsLastFullCycle = await getSymptomes(dateRange: menstruationRanges.lastFullCycleDateRange, combinedDataModel: &combindedDataModelLast)
        
        symptomsSecondToLastFullCycle = await getSymptomes(dateRange: menstruationRanges.secondToLastFullCycleDateRange, combinedDataModel: &combindedDataModelSecondToLast)
        
        DispatchQueue.main.async {
            if currentCycle{
                self.symptoms = self.symptomsCurrentCycle
            }
            else { // Display the last full cycle
                self.symptoms = self.symptomsLastFullCycle
            }
        }
    }
    
    
    func getSymptomes(dateRange : [Date], combinedDataModel : inout CombinedDataModel) async -> [SymptomModel] {
        
        let startDate = menstruationRanges.getAppropriateStartDate(firstEntry: dateRange[0])
        let endDate =  menstruationRanges.getAppropriateEndDate(lastEntry: dateRange[dateRange.count-1])
        
        await fetchRelevantAppleHealthData(relevantDataList : relevantDataClass.relevantForAppleHealthFetch, startDate: startDate, endDate: endDate, combinedDataModel: &combinedDataModel)
        fetchRelevantCyMeData(startDate: startDate, endDate: endDate, combinedDataModel: &combinedDataModel)
        
        return buildSymptomModels(relevantDataList : relevantDataClass.relevantForDisplay, dateRange: dateRange, startDate: startDate, endDate : endDate, combinedDataModel : &combinedDataModel)

    }
    
   
    
    func fetchRelevantCyMeData(startDate: Date, endDate: Date, combinedDataModel : inout CombinedDataModel)  { // Gets the desired data and stores them in class variables
        
        let periodLabelToValue = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 5 ]
        let selfreportedLabelToIntensity = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 1 ]
        let appetiteLabelToIntensity = ["No" : 1, "Less" : 2, "More" :3]
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
            
            if verbose{
                
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
        }

    func fetchRelevantAppleHealthData(relevantDataList : [availableHealthMetrics], startDate: Date, endDate: Date, combinedDataModel : inout CombinedDataModel) async { // Gets the desired data and stores them in class variables
        
        do { combinedDataModel.periodDataList  = try await healthKitService.fetchPeriodData() }
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
    
    
    func buildSingleSymptomModel (title: String, symptomList : [DataProtocoll], dateRange : [Date], appetiteChange : Bool = false) -> SymptomModel {
        let cycleOverview : [Int?] =  buildSymptomGraphArray(symptomList: symptomList, dateRange: dateRange, appetiteChange: appetiteChange)
        let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange: dateRange, title: title, removeMaxMinHint: appetiteChange)
        let statistics : [String] = buildSymptomMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
        let covariance : Float = buildSymptomCovariance(symptomList: symptomList, dateRange: dateRange)
        
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
            covariance: covariance,
            covarianceOverview: [], //TODO
            questionType: questionType
        )
        return symptomModel
    }
    
    func buildSymptomModels (relevantDataList : [availableHealthMetrics], dateRange: [Date], startDate : Date, endDate : Date, combinedDataModel : inout CombinedDataModel) -> [SymptomModel]{
        var symptomListToReturn  : [SymptomModel] = []
        
        
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
        let statistics : [String] = buildSymptomMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
        let covariance : Float = buildSymptomCovariance(symptomList: symptomList, dateRange: dateRange)
        
        let symptomModel = SymptomModel(
            title: title,
            dateRange: dateRange,
            cycleOverview: cycleOverview,
            hints: hints,
            min: statistics[0],
            max: statistics[1],
            average: statistics[2],
            covariance: covariance,
            covarianceOverview: [], //TODO
            questionType: .menstruationEmoticonRating)
        symptomListToReturn.append(symptomModel)
        
        
        
        if relevantDataList.contains(.headache){
            let symptomModel = buildSingleSymptomModel(title: "Headaches", symptomList: combinedDataModel.headacheDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.abdominalCramps){
            let symptomModel = buildSingleSymptomModel(title: "Abdominal Cramps", symptomList: combinedDataModel.abdominalCrampsDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.lowerBackPain){
            let symptomModel = buildSingleSymptomModel(title: "Lower Back Pain", symptomList: combinedDataModel.lowerBackPainDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.pelvicPain){
            let symptomModel = buildSingleSymptomModel(title: "Pelvic Pain", symptomList: combinedDataModel.pelvicPainDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.acne){
            let symptomModel = buildSingleSymptomModel(title: "Acne", symptomList: combinedDataModel.acneDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            let symptomModel = buildSingleSymptomModel(title: "Chest Tightness or Pain", symptomList: combinedDataModel.chestTightnessOrPainDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
           
        }
        
        if relevantDataList.contains(.appetiteChange){
            let symptomModel = buildSingleSymptomModel(title: "Appetite Change", symptomList: combinedDataModel.appetiteChangeDataList, dateRange: dateRange, appetiteChange: true)
            symptomListToReturn.append(symptomModel)
        }
        
        
        if relevantDataList.contains(.sleepLength){
            let title = "Sleep Length"
            let symptomList = combinedDataModel.sleepLengthDataList
            
            let cycleOverview : [Int?] =  buildcollectedDataGraphArray(symptomList: symptomList, dateRange: dateRange, sleepLength: true)
            
            let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverview, title: title, type : .sleepLength)
            let statistics : [String] = buildCollectedQuantityMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
            let covariance : Float = buildCollectedQuantityCovariance(symptomList: symptomList, dateRange: dateRange)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covariance,
                covarianceOverview: [], //TODO
                questionType: .amountOfhour //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.exerciseTime){
            let title = "Exercise Time"
            let symptomList = combinedDataModel.exerciseTimeDataList
            
            let cycleOverview : [Int?] =  buildcollectedDataGraphArray(symptomList: symptomList, dateRange: dateRange)
            let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverview, title: title, type : .exerciseTime)
            let statistics : [String] = buildCollectedQuantityMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
            let covariance : Float = buildCollectedQuantityCovariance(symptomList: symptomList, dateRange: dateRange)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covariance,
                covarianceOverview: [], //TODO
                questionType: .amountOfhour //TODO
            )
            
            symptomListToReturn.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.stepCount){
            let title = "Step Count"
            let symptomList = combinedDataModel.stepCountDataList
            
            let cycleOverview : [Int?] =  buildcollectedDataGraphArray(symptomList: symptomList, dateRange: dateRange)
            let hints : [String] = buildCollectedQuantityHint(cycleOverview: cycleOverview, title: title, type : .stepCount)
            let statistics : [String] = buildCollectedQuantityMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
            let covariance : Float = buildCollectedQuantityCovariance(symptomList: symptomList, dateRange: dateRange)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covariance,
                covarianceOverview: [], //TODO
                questionType: .amountOfhour //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.mood){
            let title = "Mood"
            let symptomList = combinedDataModel.moodDataList
            
            let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange)
           
            let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange:  dateRange, title: title, removeMaxMinHint: true)
            let statistics : [String] = buildSymptomMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
            let covariance : Float = buildSymptomCovariance(symptomList: symptomList, dateRange: dateRange)
             
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covariance,
                covarianceOverview: [], //TODO
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.stress){
            let title = "Stress"
            let symptomList = combinedDataModel.stressDataList
            
            let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange)
           
            let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange:  dateRange, title: title, removeMaxMinHint: true)
            let statistics : [String] = buildSymptomMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
            let covariance : Float = buildSymptomCovariance(symptomList: symptomList, dateRange: dateRange)
             
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covariance,
                covarianceOverview: [], //TODO
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.sleepQuality){
            let title = "Sleep Quality"
            let symptomList = combinedDataModel.sleepQualityDataList
            
            let cycleOverview : [Int?] =  buildCyMeGraphArray(symptomList: symptomList, dateRange: dateRange)
           
            let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange:  dateRange, title: title, removeMaxMinHint: true)
            let statistics : [String] = buildSymptomMinMaxAverage(symptomList: symptomList, dateRange: dateRange)
            let covariance : Float = buildSymptomCovariance(symptomList: symptomList, dateRange: dateRange)
             
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[0],
                max: statistics[1],
                average: statistics[2],
                covariance: covariance,
                covarianceOverview: [], //TODO
                questionType: .emoticonRating //TODO
            )
            
            symptomListToReturn.append(symptomModel)
            
        }
        return symptomListToReturn
    }
}

