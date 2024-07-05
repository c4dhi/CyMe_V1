//
//  MenstruationRanges.swift
//  CyMe
//
//  Created by Deborah on 04.07.2024.
//

import Foundation

class MenstruationRanges : ObservableObject {
    @Published var cycleDay: Int
    
    var currentDateRange : [Date] = []
    var lastFullCycleDateRange : [Date] = []
    var secondToLastFullCycleDateRange : [Date] = []
    
    var periodDataListFull : [PeriodSampleModel] = []
    
    let healthKitService =  HealthKitService()
    let reportingDatabaseService :  ReportingDatabaseService = ReportingDatabaseService()
    
    init(){
        self.cycleDay = self.currentDateRange.count
        Task{
            await getLastPeriodDates()
        }
    }
    
    let periodLabelToValue = ["Mild" : 2, "Moderate" : 3, "Severe" : 4, "No" : 5 ]
    
    func updateData() async {
        periodDataListFull  = []
        
        let aYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())! // This is a choice
        
        do { periodDataListFull = try await healthKitService.fetchPeriodData(startDate: aYearAgo, endDate: Date()) }
        catch { print("Error: \(error)") }
        
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())! //At first we go a year back, just an arbitrary choice
        DispatchQueue.main.async {
            let reports = self.reportingDatabaseService.getReports(from: startDate, to: Date())
        
            for report in reports {
                let startDate : Date = report.startTime
                
                
                if let menstruationDate = report.menstruationDate{
                    
                    let menstruationStart = report.menstruationStart
                    
                    var startOfPeriod : Int
                    
                    if menstruationStart == "true" {
                        startOfPeriod = 1
                    }
                    else {
                        startOfPeriod = 0
                    }
                    
                    self.periodDataListFull.append(PeriodSampleModel(startdate: startDate, value: self.periodLabelToValue[menstruationDate]!, startofPeriod: startOfPeriod))
                }
            }
        }
    }
    
    func cleanDuplicates(dates: [Date]) -> [Date] {
        var uniqueDays = Set<DateComponents>()
        var cleanedDates = [Date]()
        
        for date in dates {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if !uniqueDays.contains(components) {
                uniqueDays.insert(components)
                cleanedDates.append(date)
            }
        }
        return cleanedDates.sorted()
    }
    
    func extractDateRange(startDate: Date , endDate: Date) -> [Date]{
        var dateRangeToReturn : [Date] = []
       
        var iterator = startDate
        while iterator <= getAppropriateEndDate(lastEntry: endDate) {
            dateRangeToReturn.append(iterator)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: iterator) else {
                break
            }
            iterator = nextDate
        }
        return dateRangeToReturn
    }
    
    func getLastPeriodDates() async {
        currentDateRange  = []
        lastFullCycleDateRange  = []
        secondToLastFullCycleDateRange  = []
        
        await updateData()
        
        let periodStartObjects = periodDataListFull.filterByPeriodStart(isStart: true)
        let periodStartDates = periodStartObjects.map { $0.startdate }
        let periodStarts = cleanDuplicates(dates: periodStartDates)
      
        if periodStarts.count == 0 {
            print("You don't have any Menstruation Reported")
            return
        }
        
        if periodStarts.count >= 1 {
            let lastStartedCycleStartDate = periodStarts[periodStarts.count - 1]
            
            currentDateRange = extractDateRange(startDate: lastStartedCycleStartDate , endDate: Date())
        }
        
        if periodStarts.count >= 2 {
            let lastFullCycleStartDate = periodStarts[periodStarts.count - 2]
            let lastStartedCycleStartDate = periodStarts[periodStarts.count - 1]
            let lastFullCycleEndDate = Calendar.current.date(byAdding: .day, value: -1, to:  lastStartedCycleStartDate)!
            
            lastFullCycleDateRange = extractDateRange(startDate: lastFullCycleStartDate , endDate: lastFullCycleEndDate)
            
        }
        
        if periodStarts.count >= 3 {
            let secondToLastFullCycleStartDate = periodStarts[periodStarts.count - 3]
            let secondToLastStartedCycleStartDate = periodStarts[periodStarts.count - 2]
            let secondToLastFullCycleEndDate = Calendar.current.date(byAdding: .day, value: -1, to:  secondToLastStartedCycleStartDate)!
            
            secondToLastFullCycleDateRange = extractDateRange(startDate: secondToLastFullCycleStartDate , endDate: secondToLastFullCycleEndDate)
        }
        
    
        DispatchQueue.main.async {
            self.cycleDay = self.currentDateRange.count
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
    
}

