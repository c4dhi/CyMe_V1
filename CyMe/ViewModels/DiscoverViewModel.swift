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
}


class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    
    var healthKitService: HealthKitService
    let verbose = true
    
    
    // List (empty or not) of the different available health data
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
    
    
    
    
    init() {
        healthKitService = HealthKitService()
        Task {
            await self.getSymptomes(relevantDataList: [.headache, .abdominalCramps, .lowerBackPain, .pelvicPain, .acne, .chestTightnessOrPain, .appetiteChange, .exerciseTime, .stepCount, .sleepLength])
        }
        
        // TODO NEXT WEEK
        
        // Handle Input of what data to fetch (what is allowed to be gotten from apple health) -  make sure Apple Health is not required
        // Handle also CyMe internal Data
        
        // Many cycles
        // Covariance
        // Covariance Overview
        // Min, Max, Average // Over many cycles
        
        
        
        // Symptom Bleeding .menstruationEmoticonRating
        // Notes
        
        
        // Speichern der Symptoms models -( HealthDataSettings in Report Tabelle)
        // Write data
        // Request Authorization faster
        
        
        
        // DISCUSS
        // Selfreported Period needs a rubric: "Is it the start of your period?" "Yes", "No" - Marinja will adapt
        // Mapping is the following: 0: no, 1: mild, 2: moderate, 3: severe (!)
       
        // PER WHATSAPP GESCHRIEBEN
        // Build Symptom Graph Array
            // Missing values in list = nil
        // Broke visualization
        // Statistics are no longer aligned
        // For this to work we need at least one full cycle (2 distinct starting dates) reported
            // Error Handeling -> Return empty-type
        
        
    }
    
    func getSymptomes(relevantDataList : [availableHealthMetrics] ) async  {
        
        let dateRange = await getLastPeriodDates()
        if dateRange.count == 0 {
            return // There is no period date to be detected
        }
        
        let startDate = getAppropriateStartDate(firstEntry: dateRange[0])
        let endDate =  getAppropriateEndDate(lastEntry: dateRange[dateRange.count-1])

        await fetchRelevantData(relevantDataList: relevantDataList, startDate: startDate, endDate: endDate)
        
        buildSymptomModels(relevantDataList: relevantDataList, dateRange: dateRange)
    }
    

    func fetchRelevantData(relevantDataList: [availableHealthMetrics], startDate: Date, endDate: Date) async { // Gets the desired data and stores them in class variables
        
        if relevantDataList.contains(.headache){
            do { headacheDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.abdominalCramps){
            do { abdominalCrampsDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.abdominalCramps, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.lowerBackPain){
            do { lowerBackPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.lowerBackPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.pelvicPain){
            do { pelvicPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.pelvicPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.acne){
            do { acneDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.acne, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            do { chestTightnessOrPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.chestTightnessOrPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.appetiteChange){
            do { appetiteChangeDataList = try await healthKitService.fetchAppetiteChanges(startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.sleepLength){
            var sleepDetailList : [SleepDataModel] = []
            do { sleepDetailList = try await healthKitService.fetchSleepData(startDate: startDate, endDate: endDate)}
            catch { print("Error: \(error)") }
            sleepLengthDataList = healthKitService.simplifySleepDataToSleepLength(sleepDataModel: sleepDetailList)
        }
        
        if relevantDataList.contains(.exerciseTime){
            do { exerciseTimeDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.appleExerciseTime) }
            catch { print("Error: \(error)") }
            
        }
        
        if relevantDataList.contains(.stepCount){
            do { stepCountDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.stepCount) }
            catch { print("Error: \(error)") }
        }
        
        
        
        if verbose{
            
            print(" Period")
            for period in periodDataList { period.print() }
            
            print("\n Headache")
            for data in headacheDataList { data.print() }
            
            print("\n Abdominal Cramps")
            for data in abdominalCrampsDataList { data.print() }
            
            print("\n Lower Back Pain")
            for data in lowerBackPainDataList { data.print() }
            
            print("\n Pelvic Pain")
            for data in pelvicPainDataList { data.print() }
            
            print("\n Acne")
            for data in acneDataList { data.print() }
            
            print("\n Chest Tightness or Pain")
            for data in chestTightnessOrPainDataList { data.print() }
            
            print("\n Appetite Change")
            for data in appetiteChangeDataList { data.print() }
            
            print("\n Sleep Length")
            for date in sleepLengthDataList.keys.sorted() {
                print(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none), SleepDataModel.formatDuration(duration: Double(sleepLengthDataList[date]!))) }
            
            print("\n Exercise Time")
            displayDateDictionary(dict: exerciseTimeDataList)
            
            print("\n Step Count")
            displayDateDictionary(dict: stepCountDataList)
        }
    }
    

    func getLastPeriodDates() async -> [Date]{
        
        // Menstrual data is fetched always
        do { periodDataList = try await healthKitService.fetchPeriodData() }
        catch { print("Error: \(error)") }
        
        let periodStarts = periodDataList.filterByPeriodStart(isStart: true)
        for period in periodStarts{
            period.print()
        }
        
        if periodStarts.count >= 2 {
            
            let lastFullCycleStartDate = periodStarts[periodStarts.count - 2].startdate
            let lastStartedCycleStartDate = periodStarts[periodStarts.count - 1].startdate
            let lastFullCycleEndDate = Calendar.current.date(byAdding: .day, value: -1, to:  lastStartedCycleStartDate)!
            
            var lastFullCycleList = [Date]()
            var currentDate = lastFullCycleStartDate
            
            while currentDate <= lastFullCycleEndDate {
                lastFullCycleList.append(currentDate)
                guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
                    break
                }
                currentDate = nextDate
            }
            
            return lastFullCycleList
            
        } else {
            print("You don't have a full cycle recorded")
            return []
        }
    }
    
    func getAppropriateStartDate (firstEntry: Date) -> Date {
        // Include Symptoms of the first cycle day from midnight
        
        let periodReportTime = Calendar.current.dateComponents([.hour, .minute], from: firstEntry)
        
        
        var startDate = Calendar.current.date(byAdding: .hour, value: -periodReportTime.hour!, to:firstEntry)!
        startDate = Calendar.current.date(byAdding: .minute, value: -periodReportTime.minute!, to:startDate)!
        
        return startDate
    }
    
    func getAppropriateEndDate (lastEntry: Date) -> Date {
        // Include Symptoms of the last cycle day up to midnight
        
        let periodReportTime = Calendar.current.dateComponents([.hour, .minute], from: lastEntry)
        
        var endDate = Calendar.current.date(byAdding: .hour, value: 23-periodReportTime.hour!, to:lastEntry)! // We fill the minutes below, so just 23 hours
        endDate = Calendar.current.date(byAdding: .minute, value: 60-periodReportTime.minute!, to:endDate)!
        
        return endDate
    }
    
    
    func buildSingleSymptomModel (title: String, symptomList : [DataProtocoll], dateRange : [Date], appetiteChange : Bool = false) -> SymptomModel {
        let cycleOverview : [Int?] =  buildSymptomGraphArray(symptomList: symptomList, dateRange: dateRange, appetiteChange: appetiteChange)
        let hints : [String] = buildSymptomHints(cycleOverview: cycleOverview, symptomList: symptomList, dateRange: dateRange, title: title, appetiteChange: appetiteChange)
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
    
    
    func buildSymptomModels (relevantDataList: [availableHealthMetrics], dateRange: [Date]) {
        
        if relevantDataList.contains(.headache){
            let symptomModel = buildSingleSymptomModel(title: "Headaches", symptomList: headacheDataList, dateRange: dateRange)
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.abdominalCramps){
            let symptomModel = buildSingleSymptomModel(title: "Abdominal Cramps", symptomList: abdominalCrampsDataList, dateRange: dateRange)
            self.symptoms.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.lowerBackPain){
            let symptomModel = buildSingleSymptomModel(title: "Lower Back Pain", symptomList: lowerBackPainDataList, dateRange: dateRange)
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.pelvicPain){
            let symptomModel = buildSingleSymptomModel(title: "Pelvic Pain", symptomList: pelvicPainDataList, dateRange: dateRange)
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.acne){
            let symptomModel = buildSingleSymptomModel(title: "Acne", symptomList: acneDataList, dateRange: dateRange)
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            let symptomModel = buildSingleSymptomModel(title: "Chest Tightness or Pain", symptomList: chestTightnessOrPainDataList, dateRange: dateRange)
            self.symptoms.append(symptomModel)
           
        }
        
        if relevantDataList.contains(.appetiteChange){
            let symptomModel = buildSingleSymptomModel(title: "Appetite Change", symptomList: appetiteChangeDataList, dateRange: dateRange, appetiteChange: true)
            self.symptoms.append(symptomModel)
        }
        
        
        if relevantDataList.contains(.sleepLength){
            let title = "Sleep Length"
            let symptomList = sleepLengthDataList
            
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
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.exerciseTime){
            let title = "Exercise Time"
            let symptomList = exerciseTimeDataList
            
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
            
            self.symptoms.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.stepCount){
            let title = "Step Count"
            let symptomList = stepCountDataList
            
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
            
            self.symptoms.append(symptomModel)
        }
    }
}

