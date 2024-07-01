import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var cycleLength = 30
    @Published var cycleDay = 13
    @Published var totalReports = 6
    @Published var circleRadius: CGFloat = 90.0
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
        
    init() {
        reportingDatabaseService = ReportingDatabaseService()
        userDatabaseService = UserDatabaseService()
        fetchReports()
    }
    
    func fetchReports() {
        let startTime = Calendar.current.startOfDay(for: Date())
        let endTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        let userSettings = userDatabaseService.loadUser()
        cycleLength = userSettings.cycleLength ?? 30
        reports = reportingDatabaseService.getReports(from: startTime, to: endTime)
        print(reports)
        totalReports = reports.count
    }
    
}
