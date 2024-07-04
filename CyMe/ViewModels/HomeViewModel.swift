import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var cycleLength = 30
    @Published var cycleDay : Int = 16
    @Published var totalReports = 6
    @Published var circleRadius: CGFloat = 90.0
    @Published var userName : String = ""
    @Published var reports: [ReviewReportModel] = []
    @Published var reportNotes = [
        "Headache in the morning, mild.",
        "Feeling very energetic and positive.",
        "Bellyache after lunch, moderate.",
        "Mood swings in the afternoon.",
        "No symptoms today, feeling good."
    ]
    @Published var reportDates = [
        "2024-06-01",
        "2024-06-02",
        "2024-06-03",
        "2024-06-04",
        "2024-06-05"
    ]
    private var reportingDatabaseService: ReportingDatabaseService
    private var userDatabaseService: UserDatabaseService
    private var menstruationRanges : MenstruationRanges
    
    init() {
        reportingDatabaseService = ReportingDatabaseService()
        userDatabaseService = UserDatabaseService()
        menstruationRanges = MenstruationRanges()

        fetchReports()
        DispatchQueue.main.async {
            Task{
                await self.menstruationRanges.getLastPeriodDates()
                self.cycleDay = self.menstruationRanges.cycleDay
            }
        }
    }
    
    func fetchReports() {
        let startTime = Calendar.current.startOfDay(for: Date())
        let endTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        let userSettings = userDatabaseService.loadUser()
        userName = userSettings.name
        cycleLength = userSettings.cycleLength ?? 30
        DispatchQueue.main.async {
            self.reports = self.reportingDatabaseService.getReports(from: startTime, to: endTime)
        }
        totalReports = reports.count
    }
    
}
