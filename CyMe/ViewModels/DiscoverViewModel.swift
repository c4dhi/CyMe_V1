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
    var sleepLengthDataList : [SleepDataModel] = []
    var exerciseTimeDataList : [Date : Int] = [:]
    var stepCountDataList : [Date : Int] = [:]
    
    
    
    
    init() {
        healthKitService = HealthKitService()
        Task {
            await self.getSymptomes(relevantDataList: [.headache, .abdominalCramps, .lowerBackPain, .pelvicPain, .acne, .chestTightnessOrPain, .appetiteChange, .exerciseTime, .stepCount, .sleepLength])
        }
        // TODO
        // Handle Input of what data to fetch (what is allowed to be gotten from apple health) -  make sure Apple Health is not required
        // Handle also CyMe internal Data
        // sleepLength TODO Sleep - Carefull with end in fetch relevant data
        // Build Symptom Graph Array
        // Handle multiple entries a day
        // Appetite change mapping
        // Covariance
        // Covariance Overview
        // Symptom Bleeding
        // Quarter Analyis if two quarters are equal
        // appetiteChange, sleep length, exerciseTime, stepcount
        // Missing values in list = nil
        // Many cycles
        // Speichern der Symptoms models -( HealthDataSettings in Report Tabelle)
        // Notes
        // Write data
        // Stepcount at correct day?
        
        
        // DISCUSS
        // Selfreported Period needs a rubric: "Is it the start of your period?" "Yes", "No" - Marinja will adapt
        // For this to work we need at least one full cycle (2 distinct starting dates) reported
        // Error Handeling -> Return empty-type
        // Mapping is the following: 0: no, 1: mild, 2: moderate, 3: severe (!)
        // Request Authorization at the correct place //await viewModel.healthKitService.requestAuthorization()
        // Average
        // Over many cycles
        
        // Broke visualization
        // Statistics are no longer aligned
        // Test in actual devices
        // Merge
        
        
    }
    
    // Helper function - nice display with a dictionary which has date as a key
    func displayDateDictionary(dict: [Date : Any]){
        for consideredDate in dict.keys.sorted(){
            print(DateFormatter.localizedString(from: consideredDate, dateStyle: .short, timeStyle: .none), terminator: "")
            if let value = dict[consideredDate]{
                print(": \(value) ")}
            else {print("There is a problem with displaying dict objects")}
        }
    }
    
    func oxfordComma(list: [Any]) -> String{
        if list.count == 0 {
            return ""
        }
        if list.count == 1 {
            return "\(list[0])"
        }
        if list.count == 2 {
            return "\(list[0]) and \(list[1])"
        }
        
        else {
            var output = ""
            for elem in list[0...list.count-3]{
                output += "\(elem), "
            }
            output += "\(list[list.count-2]) and \(list[list.count-1])"
            
            return output
        }
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
            do { sleepLengthDataList = try await healthKitService.fetchSleepData(startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
            for sleep in sleepLengthDataList{
                sleep.print()
            }
            print(healthKitService.simplifySleepDataToSleepLength(sleepDataModel: sleepLengthDataList))
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
            for sleep in sleepLengthDataList { sleep.print() }
            
            print("\n Exercise Time")
            displayDateDictionary(dict: exerciseTimeDataList)
            
            print("\n Step Count")
            displayDateDictionary(dict: stepCountDataList)
        }
    }
    
    
    func getSymptomes(relevantDataList : [availableHealthMetrics] ) async  {
        
        let dateRange = await getLastPeriodDates()
        
        let startDate = getAppropriateStartDate(firstEntry: dateRange[0])
        let endDate =  getAppropriateEndDate(lastEntry: dateRange[dateRange.count-1])
        
        await fetchRelevantData(relevantDataList: relevantDataList, startDate: startDate, endDate: endDate)
        
        buildSymptomModels(relevantDataList: relevantDataList, dateRange: dateRange)        
    }
    
    
    func getAppropriateEndDate (lastEntry: Date) -> Date {
        // Include Symptoms of the last cycle day up to midnight
        
        let periodReportTime = Calendar.current.dateComponents([.hour, .minute], from: lastEntry)
        
        var endDate = Calendar.current.date(byAdding: .hour, value: 23-periodReportTime.hour!, to:lastEntry)! // We fill the minutes below, so just 23 hours
        endDate = Calendar.current.date(byAdding: .minute, value: 60-periodReportTime.minute!, to:endDate)!
        
        return endDate
    }
    
    func getAppropriateStartDate (firstEntry: Date) -> Date {
        // Include Symptoms of the first cycle day from midnight
        
        let periodReportTime = Calendar.current.dateComponents([.hour, .minute], from: firstEntry)
        
        
        var startDate = Calendar.current.date(byAdding: .hour, value: -periodReportTime.hour!, to:firstEntry)!
        startDate = Calendar.current.date(byAdding: .minute, value: -periodReportTime.minute!, to:startDate)!
        
        return startDate
    }
    
    func getLastPeriodDates() async -> [Date]{
        
        // Menstrual data is fetched always
        do { periodDataList = try await healthKitService.fetchPeriodData() }
        catch { print("Error: \(error)") }
        
        let periodStarts = periodDataList.filterByPeriodStart(isStart: true)
        
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
    
    func buildcollectedDataGraphArray(symptomList: [Date: Int], dateRange: [Date]) -> [Int]{
        var dataGraphArray : [Int] = []
        for date in dateRange{
            // daterange entries are at 10:00 +0000 and symptom list entries are at 22:00 +0000
            let dateToCheck = Calendar.current.date(byAdding: .hour, value: 12, to: date)!
            dataGraphArray.append(symptomList[dateToCheck] ?? 0) // TODO change default in general
            }
            return dataGraphArray
    }
   
    func buildSymptomGraphArray(symptomList: [DataProtocoll], dateRange : [Date]) -> [Int]{
        
        
        let datesWithSymptom  = symptomList.map {Calendar.current.dateComponents([.day, .month, .year], from: $0.startdate)}
        
        var symptomGraphArray : [Int] = []
        let intensityMappingAppleHealthToCyMe : [Int : Int] = [1: 0, 0: 2, 2: 1, 3: 2, 4: 3]
        
        for date in dateRange{
            if datesWithSymptom.contains(Calendar.current.dateComponents([.day, .month, .year], from: date)){
                let dailySymptomList = symptomList.filterByStartDate(startDate: date)
                //TODO handle multiple entries per day, for the moment assume just one
                let appleHealthIntensity = dailySymptomList[0].intensity
                // TODO appetite change let selfreportIntensityLabels = [1:  "no Change", 0:  "unspecified", 2:  "decreased", 3:  "increased" ]
                symptomGraphArray.append(intensityMappingAppleHealthToCyMe[appleHealthIntensity]!)
            }
            else{
                symptomGraphArray.append(0) // Symptom not present  TODO
            }
        }
        return symptomGraphArray
    }
    
    func buildHints(cycleOverview : [Int], title: String) -> [String]{
        
        // Count Hint
        var count = 0
        for day in cycleOverview{
            if day != 0 { count += 1 }
        }
        let countHint = "You have reported \(title) on \(count) days of your last cycle."
        
        if count == 0 {
            return [countHint]
        }
        
        
        // Quarter Frequency Analysis
        
        let cycleLength = cycleOverview.count
        let increments : Int = cycleLength/4
        
        var frequency_1 = 0
        for day in cycleOverview[0...increments-1]{
            if day != 0 { frequency_1 += 1 }
        }
        
        var frequency_2 = 0
        for day in cycleOverview[increments...2*increments-1]{
            if day != 0 { frequency_2 += 1 }
        }
        
        var frequency_3 = 0
        for day in cycleOverview[2*increments...3*increments-1]{
            if day != 0 { frequency_3 += 1 }
        }
        
        var frequency_4 = 0
        let index : Int = 3*increments
        for day in cycleOverview[index...]{
            if day != 0 { frequency_4 += 1 }
        }
        
        let frequencyDict = ["first": frequency_1, "second": frequency_2, "third": frequency_3, "fourth": frequency_4,]
        let highestFrequencyQuarter = frequencyDict.max(by: { a, b in a.value < b.value })!
    
        
        let quarterAnalysisHint = "You reported \(title) most often in your \(highestFrequencyQuarter.key) quarter of this menstrual cycle with \(highestFrequencyQuarter.value) reports in total."
        
        return [countHint, quarterAnalysisHint]
        
        
    }
    
    func buildStatistics(cycleOverview : [Int], title: String) -> [String] { // returns [maxText, minText] in this order
        var maxText = ""
        var minText = ""
        
        let maxValue = cycleOverview.max()
        
        if maxValue == 0 { return ["You have not reported \(title) in this menstrual cycle.", minText] }
        
        var daysWithMaxValue : [Int] = []
        for index in 0..<cycleOverview.count{
            if cycleOverview[index] == maxValue{
                daysWithMaxValue.append(index + 1)
            }
        }
        
        let severityLabels = [1: "mild", 2: "moderate", 3: "severe"]
        maxText = "The maximal severity of \(title) you reported is \(severityLabels[maxValue!]!) which you reported on cycle days \(oxfordComma(list:daysWithMaxValue)). "

        
        var uniqueSeverities = Array(Set(cycleOverview))
        uniqueSeverities.removeAll { $0 == 0 }
        uniqueSeverities.removeAll { $0 == maxValue }
        
        if uniqueSeverities.isEmpty { return [maxText, minText] }
       
        let minValue = uniqueSeverities.min()
        
        
        var daysWithMinValue : [Int] = []
        for index in 0..<cycleOverview.count{
            if cycleOverview[index] == minValue{
                daysWithMinValue.append(index + 1)
            }
        }
        minText = "The minimal severity of \(title) you reported is \(severityLabels[minValue!]!) which you reported on cycle days \(oxfordComma(list:daysWithMinValue)). "
        
        return [maxText, minText]
    }
    
    
 
    func buildSymptomModels (relevantDataList: [availableHealthMetrics], dateRange: [Date]) {
        
        if relevantDataList.contains(.headache){
            let title = "Headaches"
            let cycleOverview : [Int] =  buildSymptomGraphArray(symptomList: headacheDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[1],
                max: statistics[0],
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.abdominalCramps){
            let title = "Abdominal Cramps"
            let cycleOverview : [Int] =  buildSymptomGraphArray(symptomList: abdominalCrampsDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[1],
                max: statistics[0],
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.lowerBackPain){
            let title = "Lower Back Pain"
            let cycleOverview : [Int] =  buildSymptomGraphArray(symptomList: lowerBackPainDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[1],
                max: statistics[0],
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.pelvicPain){
            let title = "Pelvic Pain"
            let cycleOverview : [Int] =  buildSymptomGraphArray(symptomList: pelvicPainDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[1],
                max: statistics[0],
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.acne){
            let title = "Acne"
            let cycleOverview : [Int] =  buildSymptomGraphArray(symptomList: acneDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[1],
                max: statistics[0],
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            let title = "Chest Tightness or Pain"
            let cycleOverview : [Int] =  buildSymptomGraphArray(symptomList: chestTightnessOrPainDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: statistics[1],
                max: statistics[0],
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        if relevantDataList.contains(.appetiteChange){
            print("Not Done Yet")
        }
        
        if relevantDataList.contains(.sleepLength){
            print("Not Done Yet")
        }
        
        if relevantDataList.contains(.exerciseTime){
            print("Not Done Yet")
            
        }
        
        if relevantDataList.contains(.stepCount){
            let title = "Step Count"
            let cycleOverview : [Int] =  buildcollectedDataGraphArray(symptomList: stepCountDataList, dateRange: dateRange)
            let hints : [String] = buildHints(cycleOverview: cycleOverview, title: title)
            //let statistics : [String] = buildStatistics(cycleOverview: cycleOverview, title: title)
                        
            let symptomModel = SymptomModel(
                title: title,
                dateRange: dateRange,
                cycleOverview: cycleOverview,
                hints: hints,
                min: "statistics[1]",
                max: "statistics[0]",
                average: "Not implemented",
                covariance: 0.0,
                covarianceOverview: [],
                questionType: .painEmoticonRating
            )
            
            self.symptoms.append(symptomModel)
        }
        
        /*
         SymptomModel(
             title: "Headache",
             cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
             hints: ["Most frequent in period phase"],
             min: 0,
             max: 3,
             average: 1,
             covariance: 2.5,
             covarianceOverview: [[2, 3, 4, 6, 5], [1, 2, 3, 4, 5]],
             questionType: .painEmoticonRating
         ),
         SymptomModel(
             title: "Fatigue",
             cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
             hints: ["Most frequent in luteal phase"],
             min: 1,
             max: 4,
             average: 2,
             covariance: 1.8,
             covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
             questionType: .intensity
         ),
         SymptomModel(
             title: "Menstruation",
             cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
             hints: ["Most frequent in luteal phase"],
             min: 1,
             max: 4,
             average: 2,
             covariance: 1.8,
             covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
             questionType: .menstruationEmoticonRating
         ),
         SymptomModel(
             title: "Mood",
             cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
             hints: ["Most frequent in luteal phase"],
             min: 1,
             max: 4,
             average: 2,
             covariance: 1.8,
             covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
             questionType: .emoticonRating
         ),
         SymptomModel(
             title: "Sleep",
             cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
             hints: ["Most frequent in luteal phase"],
             min: 1,
             max: 4,
             average: 2,
             covariance: 1.8,
             covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
             questionType: .amountOfhour
         )
         
         
         */
    
    }

    
    
}

