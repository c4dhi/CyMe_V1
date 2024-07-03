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
}


class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    @Published var cycleDay: Int = 0
    
    var healthKitService: HealthKitService
    var reportingDatabaseService: ReportingDatabaseService
    var settingsDatabaseService: SettingsDatabaseService
    let verbose = false

    
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
    var sleepQualityDataList : [CyMeSefReportModel] = []
    var stressDataList : [CyMeSefReportModel] = []
    var moodDataList : [CyMeSefReportModel] = []
    

    init() {
        healthKitService = HealthKitService()
        reportingDatabaseService =  ReportingDatabaseService()
        settingsDatabaseService = SettingsDatabaseService()
        
        Task {
            await self.getSymptomes()
        }
    }
    
    
    func getSymptomes(currentCycle : Bool = true) async  {
        
        let relevantDataLists = getRelevantDataLists()
        let relevantForDisplay = relevantDataLists[0]
        let relevantForAppleHealthFetch = relevantDataLists[2]
        
        let dateRangeList = await getLastPeriodDates()
        if dateRangeList.count == 0 {
            return // There is no period date to be detected
        }
    
        let dateRange : [Date]
        
        DispatchQueue.main.async {
            self.cycleDay = dateRangeList[1].count
        }
        
        if currentCycle{
            dateRange = dateRangeList[1]
        }
        else { // Display the last full cycle
            dateRange = dateRangeList[0]
        }
        
        let startDate = getAppropriateStartDate(firstEntry: dateRange[0])
        let endDate =  getAppropriateEndDate(lastEntry: dateRange[dateRange.count-1])
        
        
        await fetchRelevantAppleHealthData(relevantDataList : relevantForAppleHealthFetch, startDate: startDate, endDate: endDate)
        fetchRelevantCyMeData(startDate: startDate, endDate: endDate)
        
        DispatchQueue.main.async {
            self.symptoms = self.buildSymptomModels(relevantDataList : relevantForDisplay, dateRange: dateRange, startDate: startDate, endDate : endDate)
        }
    }
    
    func getRelevantDataLists() -> [[availableHealthMetrics]]{
        
        var relevantForDisplay : [availableHealthMetrics] = []
        var relevantForAppleHealthFetch : [availableHealthMetrics] = []
        var relevantForCyMeFetch : [availableHealthMetrics] = []
        
        let dBtoAvailableHealthMetrics : [String : availableHealthMetrics] =
                                        ["menstruationDate" : .menstrualBleeding,
                                          "sleepQuality" : .sleepQuality,
                                          "sleepLenght" : .sleepLength,
                                          "headache" : .headache,
                                          "stress" : .stress,
                                          "abdominalCramps" : .abdominalCramps,
                                          "lowerBackPain" : .lowerBackPain,
                                          "pelvicPain" : .pelvicPain,
                                          "acne" : .acne,
                                          "appetiteChanges" : .appetiteChange,
                                          "chestPain" : .chestTightnessOrPain,
                                          "stepData" : .stepCount,
                                          "mood" : .mood,
                                          "exerciseTime" : .exerciseTime]

        let healthDataSettings = settingsDatabaseService.getSettings()?.healthDataSettings
        for setting in healthDataSettings! {
            if(setting.enableDataSync){
                relevantForAppleHealthFetch.append(dBtoAvailableHealthMetrics[setting.name]!)
            }
            if(setting.enableSelfReportingCyMe){
                relevantForCyMeFetch.append(dBtoAvailableHealthMetrics[setting.name]!)
            }
            if(setting.enableSelfReportingCyMe) || (setting.enableDataSync){
                relevantForDisplay.append(dBtoAvailableHealthMetrics[setting.name]!)
            }
        }
        return [relevantForDisplay, relevantForCyMeFetch, relevantForAppleHealthFetch]
    }
    
    func fetchRelevantCyMeData(startDate: Date, endDate: Date)  { // Gets the desired data and stores them in class variables
        
        let periodLabelToValue = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 5 ]
        let selfreportedLabelToIntensity = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 1 ]
        let appetiteLabelToIntensity = ["No" : 1, "Less" : 2, "More" :3]
        
        let reports = reportingDatabaseService.getReports(from: startDate, to: endDate)
        
        for report in reports {
            let startDate : Date = report.startTime
            
            if let menstruationDate = report.menstruationDate{
                periodDataList.append(PeriodSampleModel(startdate: startDate, value: periodLabelToValue[menstruationDate]!, startofPeriod: -1))
            }

            if let headache = report.headache{
                headacheDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[headache]!))
            }
            
            if let abdominalCramps = report.abdominalCramps {
                abdominalCrampsDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[abdominalCramps]!))
            }
            
            if let lowerBackPain = report.lowerBackPain {
                lowerBackPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[lowerBackPain]!))
            }
            
            if let pelvicPain = report.pelvicPain   {
                pelvicPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[pelvicPain]!))
            }
            
            if let acne = report.acne   {
                acneDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[acne]!))
            }
            
            if let chestPain = report.chestPain   {
                chestTightnessOrPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[chestPain]!))
            }
            
            if let appetiteChanges = report.appetiteChanges   {
                appetiteChangeDataList.append(AppetiteChangeModel(startdate: startDate, intensity: appetiteLabelToIntensity[appetiteChanges]!))
            }
            
            if let sleepQuality = report.sleepQuality {
                sleepQualityDataList.append(CyMeSefReportModel(startdate: startDate, label: sleepQuality))
            }
            
            if let stress = report.stress {
                stressDataList.append(CyMeSefReportModel(startdate: startDate, label: stress))
            }
            
            if let mood = report.mood {
                moodDataList.append(CyMeSefReportModel(startdate: startDate, label: mood))
            }
            
            if let sleepLenght = report.sleepLenght {
                let sleepLengthInMinutes = getTimeRepresentationFromString(timeString : sleepLenght)
                if sleepLengthInMinutes != -1 {
                    let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
                    let noonOfSelfreportDate = Calendar.current.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: 12, minute: 00, second: 00))!
                    let nightDate = Calendar.current.date(byAdding: .hour, value: -24, to: noonOfSelfreportDate)!
                    sleepLengthDataList[nightDate] = sleepLengthInMinutes*60 // We consider seconds
                    // We give priority to internal data
                }
            }
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
                
                print("\n Sleep Quality")
                for data in sleepQualityDataList { data.print() }
                
                print("\n Mood")
                for data in moodDataList { data.print() }
                
                print("\n Stress")
                for data in stressDataList { data.print() }
            }
        }

    func fetchRelevantAppleHealthData(relevantDataList : [availableHealthMetrics], startDate: Date, endDate: Date) async { // Gets the desired data and stores them in class variables
        
        if relevantDataList.contains(.headache){
            do { headacheDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            headacheDataList = []
        }
        
        if relevantDataList.contains(.abdominalCramps){
            do { abdominalCrampsDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.abdominalCramps, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            abdominalCrampsDataList = []
        }
        
        if relevantDataList.contains(.lowerBackPain){
            do { lowerBackPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.lowerBackPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            lowerBackPainDataList = []
        }
        
        if relevantDataList.contains(.pelvicPain){
            do { pelvicPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.pelvicPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            pelvicPainDataList = []
        }
        
        if relevantDataList.contains(.acne){
            do { acneDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.acne, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            acneDataList = []
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            do { chestTightnessOrPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.chestTightnessOrPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            chestTightnessOrPainDataList = []
        }
        
        if relevantDataList.contains(.appetiteChange){
            do { appetiteChangeDataList = try await healthKitService.fetchAppetiteChanges(startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        } else{
            appetiteChangeDataList = []
        }
        
        if relevantDataList.contains(.sleepLength){
            var sleepDetailList : [SleepDataModel] = []
            do { sleepDetailList = try await healthKitService.fetchSleepData(startDate: startDate, endDate: endDate)}
            catch { print("Error: \(error)") }
            sleepLengthDataList = healthKitService.simplifySleepDataToSleepLength(sleepDataModel: sleepDetailList)
        } else{
            sleepLengthDataList = [:]
        }
        
        if relevantDataList.contains(.exerciseTime){
            do { exerciseTimeDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.appleExerciseTime) }
            catch { print("Error: \(error)") }
            
        } else{
            exerciseTimeDataList = [:]
        }
        
        if relevantDataList.contains(.stepCount){
            do { stepCountDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.stepCount) }
            catch { print("Error: \(error)") }
        } else{
            stepCountDataList = [:]
        }
    }
    
    func getLastPeriodDates() async -> [[Date]]{
        
        // Menstrual data is fetched always
        do { periodDataList = try await healthKitService.fetchPeriodData() }
        catch { print("Error: \(error)") }
        
        let periodStarts = periodDataList.filterByPeriodStart(isStart: true)
        
        if periodStarts.count >= 2 {
            
            let lastFullCycleStartDate = periodStarts[periodStarts.count - 2].startdate
            let lastStartedCycleStartDate = periodStarts[periodStarts.count - 1].startdate
            let lastFullCycleEndDate = Calendar.current.date(byAdding: .day, value: -1, to:  lastStartedCycleStartDate)!
            
            var lastFullCycleList = [Date]()
            var currentCycleList = [Date]()
            
            var currentDate = lastFullCycleStartDate
            let today = Date()
            
            while currentDate <= lastFullCycleEndDate {
                lastFullCycleList.append(currentDate)
                guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
                    break
                }
                currentDate = nextDate
            }
            
            while currentDate <= today {
                currentCycleList.append(currentDate)
                guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
                    break
                }
                currentDate = nextDate
            }
            
            return [lastFullCycleList, currentCycleList]
            
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
    
    func buildSymptomModels (relevantDataList : [availableHealthMetrics], dateRange: [Date], startDate : Date, endDate : Date) -> [SymptomModel]{
        var symptomListToReturn  : [SymptomModel] = []
        
        
        // We will always display bleeding
        let title = "Menstrual Bleeding"
        var symptomList : [DataProtocoll] = []
        
        for period in periodDataList{
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
            let symptomModel = buildSingleSymptomModel(title: "Headaches", symptomList: headacheDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.abdominalCramps){
            let symptomModel = buildSingleSymptomModel(title: "Abdominal Cramps", symptomList: abdominalCrampsDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
            
        }
        
        if relevantDataList.contains(.lowerBackPain){
            let symptomModel = buildSingleSymptomModel(title: "Lower Back Pain", symptomList: lowerBackPainDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.pelvicPain){
            let symptomModel = buildSingleSymptomModel(title: "Pelvic Pain", symptomList: pelvicPainDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.acne){
            let symptomModel = buildSingleSymptomModel(title: "Acne", symptomList: acneDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            let symptomModel = buildSingleSymptomModel(title: "Chest Tightness or Pain", symptomList: chestTightnessOrPainDataList, dateRange: dateRange)
            symptomListToReturn.append(symptomModel)
           
        }
        
        if relevantDataList.contains(.appetiteChange){
            let symptomModel = buildSingleSymptomModel(title: "Appetite Change", symptomList: appetiteChangeDataList, dateRange: dateRange, appetiteChange: true)
            symptomListToReturn.append(symptomModel)
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
            
            symptomListToReturn.append(symptomModel)
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
            
            symptomListToReturn.append(symptomModel)
            
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
            
            symptomListToReturn.append(symptomModel)
        }
        
        if relevantDataList.contains(.mood){
            let title = "Mood"
            let symptomList = moodDataList
            
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
            let symptomList = stressDataList
            
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
            let symptomList = sleepQualityDataList
            
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

