//
//  CombinedDataModel.swift
//  CyMe
//
//  Created by Deborah on 04.07.2024.
//
// Holds all considered data of a given period time intervall

import Foundation


struct CombinedDataModel  { // Holds all Data of a selected Cycle (AppleHealth and CyMe Data in an aggregated way
    
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
    
    
    func getContentAmounts() -> String{
        return "Period: \(periodDataList.count), Headache: \(headacheDataList.count), AbdominalCramps: \(abdominalCrampsDataList.count), LowerBackPain: \(lowerBackPainDataList.count), PelvicPain: \(pelvicPainDataList.count), Acne: \(acneDataList.count), ChestTightnessAndPain: \(chestTightnessOrPainDataList.count), AppetiteChange: \(appetiteChangeDataList.count), SleepLength: \(sleepLengthDataList.count), ExerciseTime: \(exerciseTimeDataList.count), StepCount: \(stepCountDataList.count)"
    }
   
    func getDataList (healthMetric : availableHealthMetrics) -> [DataProtocoll]{
        if (healthMetric == .headache){
            return headacheDataList
        }
        
        if (healthMetric == .abdominalCramps){
            return abdominalCrampsDataList
        }
        
        if (healthMetric == .lowerBackPain){
            return lowerBackPainDataList
        }
        
        if (healthMetric == .pelvicPain){
            return pelvicPainDataList
        }
        
        if (healthMetric == .acne){
            return acneDataList
        }
        
        if (healthMetric == .chestTightnessOrPain){
            return chestTightnessOrPainDataList
        }
        
        if (healthMetric == .appetiteChange){
            return appetiteChangeDataList
        }
        
        if (healthMetric == .stress){
            return stressDataList
        }
        
        if (healthMetric == .sleepQuality){
            return sleepQualityDataList
        }
        
        if (healthMetric == .mood){
            return moodDataList
        }
        
        if (healthMetric == .menstrualBleeding){
            return periodDataList
        }
        
        return []
        
    }
    
    func getDataDict (healthMetric : availableHealthMetrics) -> [Date : Int]{
        if (healthMetric == .sleepLength){
            return sleepLengthDataList
        }
        
        if (healthMetric == .exerciseTime){
            return exerciseTimeDataList
        }
        
        if (healthMetric == .stepCount){
            return stepCountDataList
        }
        
        return [:]
    }
    
    func reportsAreTheSame(report1: DataProtocoll, report2: DataProtocoll) -> Bool{
        // Reports are considered the same if they have the same intensity and same timestamp (less than a second apart)
        if report1.intensity == report2.intensity {
            if abs(report1.startdate.timeIntervalSince(report2.startdate)) < 1 {
                return true
            }
        }
        return false
    }
    
    func reportIsUniquelyNewInList(report : DataProtocoll, list : [DataProtocoll]) -> Bool{
        var reportIsUniquelyNewInList = true
        
        for entry in list {
            if reportsAreTheSame(report1: entry, report2: report){
                reportIsUniquelyNewInList = false
            }
        }
        return reportIsUniquelyNewInList
    }
    

    
    mutating func append(otherModel: CombinedDataModel){
        // Append, clean for duplicates and sort by date
        
        let newEntriesPeriod = otherModel.periodDataList.filter {reportIsUniquelyNewInList(report: $0, list: periodDataList)}
        periodDataList += newEntriesPeriod
        periodDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesHeadaches = otherModel.headacheDataList.filter {reportIsUniquelyNewInList(report: $0, list: headacheDataList)}
        headacheDataList += newEntriesHeadaches
        headacheDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesAbdominal = otherModel.abdominalCrampsDataList.filter {reportIsUniquelyNewInList(report: $0, list: abdominalCrampsDataList)}
        abdominalCrampsDataList += newEntriesAbdominal
        abdominalCrampsDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesLowerBack = otherModel.lowerBackPainDataList.filter {reportIsUniquelyNewInList(report: $0, list: lowerBackPainDataList)}
        lowerBackPainDataList += newEntriesLowerBack
        lowerBackPainDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesPelvic = otherModel.pelvicPainDataList.filter {reportIsUniquelyNewInList(report: $0, list: pelvicPainDataList)}
        pelvicPainDataList += newEntriesPelvic
        pelvicPainDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesAcne = otherModel.acneDataList.filter {reportIsUniquelyNewInList(report: $0, list: acneDataList)}
        acneDataList += newEntriesAcne
        acneDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesChest = otherModel.chestTightnessOrPainDataList.filter {reportIsUniquelyNewInList(report: $0, list: chestTightnessOrPainDataList)}
        chestTightnessOrPainDataList += newEntriesChest
        chestTightnessOrPainDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesAppetite = otherModel.appetiteChangeDataList.filter {reportIsUniquelyNewInList(report: $0, list: appetiteChangeDataList)}
        appetiteChangeDataList += newEntriesAppetite
        appetiteChangeDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesSleepQuality = otherModel.sleepQualityDataList.filter {reportIsUniquelyNewInList(report: $0, list: sleepQualityDataList)}
        sleepQualityDataList += newEntriesSleepQuality
        sleepQualityDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesStress = otherModel.stressDataList.filter {reportIsUniquelyNewInList(report: $0, list: stressDataList)}
        stressDataList += newEntriesStress
        stressDataList.sort {$0.startdate < $1.startdate}
        
        let newEntriesMood = otherModel.moodDataList.filter {reportIsUniquelyNewInList(report: $0, list: moodDataList)}
        moodDataList += newEntriesMood
        moodDataList.sort {$0.startdate < $1.startdate}
        
        for key in otherModel.sleepLengthDataList.keys{
            if (sleepLengthDataList[key] != nil){
                // For multiple entries take the average
                sleepLengthDataList[key] = (sleepLengthDataList[key]! + otherModel.sleepLengthDataList[key]!)/2
            }
            else{
                sleepLengthDataList[key] = otherModel.sleepLengthDataList[key]
            }
        }
        
        for key in otherModel.exerciseTimeDataList.keys{
            if (exerciseTimeDataList[key] != nil){
                print("There are two input streams for Exercise but only Apple Health is supposed to exist")
                
            }
            else{
                exerciseTimeDataList[key] = otherModel.exerciseTimeDataList[key]
            }
        }
        
        for key in otherModel.stepCountDataList.keys{
            if (stepCountDataList[key] != nil){
                print("There are two input streams for StepCount but only Apple Health is supposed to exist")
                
            }
            else{
                stepCountDataList[key] = otherModel.stepCountDataList[key]
            }
        }
    }
}

