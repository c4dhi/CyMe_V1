//
//  fillCombinedDataModel.swift
//  CyMe
//
//  Created by Deborah on 01.08.2024.
//

import Foundation
import HealthKit

class fillCombinedDataModel {
    // Whenever a new object is initialized it is filled with the most current data
    
    var menstruationRanges : MenstruationRanges
    var relevantData : RelevantData
    
    var healthKitService = HealthKitService()
    var reportingDatabaseService = ReportingDatabaseService()
    
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel] = [:]
    var availableCycles = 0
    var selfReports : [ReviewReportModel] = []
    
    var verbose = true

    
    
    
    init(menstruationRanges : MenstruationRanges, relevantData : RelevantData ) async {
        
        self.menstruationRanges = menstruationRanges
        self.relevantData = relevantData
        
        await menstruationRanges.getLastPeriodDates()
        await relevantData.getRelevantDataLists()
        
        if(menstruationRanges.currentDateRange.count > 0){
            await fillSingleCombinedDataModel(dateRange: menstruationRanges.currentDateRange, label: .current)
            availableCycles = 1
        }
        
        if(menstruationRanges.lastFullCycleDateRange.count > 0){
            await fillSingleCombinedDataModel(dateRange: menstruationRanges.lastFullCycleDateRange, label: .last)
            availableCycles = 2
        }
        
        if(menstruationRanges.secondToLastFullCycleDateRange.count > 0){
            await fillSingleCombinedDataModel(dateRange: menstruationRanges.secondToLastFullCycleDateRange, label: .secondToLast)
            availableCycles = 3
        }
        
    }
    
    
    func fillSingleCombinedDataModel(dateRange : [Date], label: cycleTimeOptions) async  {
        var combinedDataModelToReturn = CombinedDataModel()
        
        let startDate = dateRange[0]
        var endDate = dateRange[dateRange.count-1]
        
        if endDate > Date(){
            endDate = Date()
        }
        
        let appleHealthData = await fetchRelevantAppleHealthData(startDate: startDate, endDate: endDate)
        let cyMeHealthData = await fetchRelevantCyMeData(startDate: startDate, endDate: endDate)
        
        combinedDataModelToReturn.append(otherModel: appleHealthData)
        combinedDataModelToReturn.append(otherModel: cyMeHealthData)
        
        displayModel(combinedDataModel: combinedDataModelToReturn, label : "Combined")
        
        combinedDataDict[label] = combinedDataModelToReturn
    
    }
    
    func displayModel(combinedDataModel : CombinedDataModel, label : String){
        if self.verbose{

            print(label)
            
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
    
    
    func fetchRelevantAppleHealthData(startDate: Date, endDate: Date) async -> CombinedDataModel{
        
        var combinedDataModelToReturn = CombinedDataModel()
        let relevantDataList = relevantData.relevantForAppleHealth
        
        if relevantDataList.contains(.menstrualBleeding){
            do { combinedDataModelToReturn.periodDataList  = try await healthKitService.fetchPeriodData(startDate : startDate, endDate : endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.headache){
            do { combinedDataModelToReturn.headacheDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache, startDate: startDate, endDate: endDate)}
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.abdominalCramps){
            do { combinedDataModelToReturn.abdominalCrampsDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.abdominalCramps, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.lowerBackPain){
            do { combinedDataModelToReturn.lowerBackPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.lowerBackPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        if relevantDataList.contains(.pelvicPain){
            do { combinedDataModelToReturn.pelvicPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.pelvicPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.acne){
            do { combinedDataModelToReturn.acneDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.acne, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.chestTightnessOrPain){
            do { combinedDataModelToReturn.chestTightnessOrPainDataList = try await healthKitService.fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.chestTightnessOrPain, startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.appetiteChange){
            do { combinedDataModelToReturn.appetiteChangeDataList = try await healthKitService.fetchAppetiteChanges(startDate: startDate, endDate: endDate) }
            catch { print("Error: \(error)") }
        }
        
        if relevantDataList.contains(.sleepLength){
            var sleepDetailList : [SleepDataModel] = []
            do { sleepDetailList = try await healthKitService.fetchSleepData(startDate: startDate, endDate: endDate)}
            catch { print("Error: \(error)") }
            combinedDataModelToReturn.sleepLengthDataList = healthKitService.simplifySleepDataToSleepLength(sleepDataModel: sleepDetailList)
        }
        
        if relevantDataList.contains(.exerciseTime){
            do { combinedDataModelToReturn.exerciseTimeDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.appleExerciseTime) }
            catch { print("Error: \(error)") }
            
        }
        
        if relevantDataList.contains(.stepCount){
            do { combinedDataModelToReturn.stepCountDataList = try await healthKitService.fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.stepCount) }
            catch { print("Error: \(error)") }
        }
        
        Logger.shared.log("Data from Apple Health: \(combinedDataModelToReturn.getContentAmounts())")
        return combinedDataModelToReturn
    }
    
    func fetchCyMeData(startDate : Date, endDate : Date) async -> [ReviewReportModel] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let reports = self.reportingDatabaseService.getReports(from: startDate, to: endDate)
                print("Internal", reports)
                continuation.resume(returning: reports)
            }
        }
    }
    
    
    func fetchRelevantCyMeData(startDate: Date, endDate: Date) async -> CombinedDataModel  {
        
        let periodLabelToValue = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 5 ]
        let selfreportedLabelToIntensity = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 1 ]
        let appetiteLabelToIntensity = ["No" : 1, "Less" : 2, "More" :3]
        
        var combinedDataModelToReturn = CombinedDataModel()
        
        let relevantDataList = self.relevantData.relevantForCyMeSelfReport
        let reports = await fetchCyMeData(startDate : startDate, endDate : endDate)
        
        for report in reports {
            self.selfReports.append(report)
            
            let startDate : Date = report.startTime
            
            if relevantDataList.contains(.menstrualStart){
                if let menstruationDate = report.menstruationDate{
                    combinedDataModelToReturn.periodDataList.append(PeriodSampleModel(startdate: startDate, value: periodLabelToValue[menstruationDate]!, startofPeriod: -1)) // Here the startOfPeriod label is not considered or important
                }
            }
            
            if relevantDataList.contains(.headache){
                if let headache = report.headache{
                    combinedDataModelToReturn.headacheDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[headache]!))
                }
            }
            
            if relevantDataList.contains(.abdominalCramps){
                if let abdominalCramps = report.abdominalCramps {
                    combinedDataModelToReturn.abdominalCrampsDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[abdominalCramps]!))
                }
            }
            
            if relevantDataList.contains(.lowerBackPain){
                if let lowerBackPain = report.lowerBackPain {
                    combinedDataModelToReturn.lowerBackPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[lowerBackPain]!))
                }
            }
            
            if relevantDataList.contains(.pelvicPain){
                if let pelvicPain = report.pelvicPain   {
                    combinedDataModelToReturn.pelvicPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[pelvicPain]!))
                }
            }
            
            if relevantDataList.contains(.acne){
                if let acne = report.acne   {
                    combinedDataModelToReturn.acneDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[acne]!))
                }
            }
            
            if relevantDataList.contains(.chestTightnessOrPain){
                if let chestPain = report.chestPain   {
                    combinedDataModelToReturn.chestTightnessOrPainDataList.append(AppleHealthSefReportModel(startdate: startDate, intensity: selfreportedLabelToIntensity[chestPain]!))
                }
            }
            
            if relevantDataList.contains(.appetiteChange){
                if let appetiteChanges = report.appetiteChanges   {
                    combinedDataModelToReturn.appetiteChangeDataList.append(AppetiteChangeModel(startdate: startDate, intensity: appetiteLabelToIntensity[appetiteChanges]!))
                }
            }
            
            if relevantDataList.contains(.sleepQuality){
                if let sleepQuality = report.sleepQuality {
                    combinedDataModelToReturn.sleepQualityDataList.append(CyMeSefReportModel(startdate: startDate, label: sleepQuality))
                }
            }
            
            if relevantDataList.contains(.stress){
                if let stress = report.stress {
                    combinedDataModelToReturn.stressDataList.append(CyMeSefReportModel(startdate: startDate, label: stress))
                }
            }
            
            if relevantDataList.contains(.mood){
                if let mood = report.mood {
                    combinedDataModelToReturn.moodDataList.append(CyMeSefReportModel(startdate: startDate, label: mood))
                }
            }
            
            if relevantDataList.contains(.sleepLength){
                if let sleepLenght = report.sleepLenght {
                    let sleepLengthInMinutes = getTimeRepresentationFromString(timeString : sleepLenght)
                    if sleepLengthInMinutes != -1 {
                        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
                        let noonOfSelfreportDate = Calendar.current.date(from: DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: 12, minute: 00, second: 00))!
                        let nightDate = Calendar.current.date(byAdding: .hour, value: -24, to: noonOfSelfreportDate)!
                        combinedDataModelToReturn.sleepLengthDataList[nightDate] = sleepLengthInMinutes*60 // We consider seconds
                        // We give priority to internal data
                    }
                }
            }
        }
        return combinedDataModelToReturn
    }
}
