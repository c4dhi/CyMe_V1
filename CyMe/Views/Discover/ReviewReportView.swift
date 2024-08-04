import SwiftUI

struct ReviewReportView: View {
    var report: ReviewReportModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start time:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(report.startTime, formatter: DateFormatter.shortTime)")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("End time:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(report.endTime, formatter: DateFormatter.shortTime)")
                        .font(.headline)
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                ReportDetailRow(label: "CyMe self report:", value: report.isCyMeSelfReport ? "Yes" : "No")
                ReportDetailRow(label: "Self report medium:", value: report.selfReportMedium.rawValue)
                if let menstruationDate = report.menstruationDate {
                    ReportDetailRow(label: "Menstruation date:", value: menstruationDate)
                }
                if let menstruationStart = report.menstruationStart {
                    ReportDetailRow(label: "Menstruation start:", value: menstruationStart)
                }
                if let sleepQuality = report.sleepQuality {
                    ReportDetailRow(label: "Sleep quality:", value: sleepQuality)
                }
                if let sleepLength = report.sleepLenght {
                    ReportDetailRow(label: "Sleep length:", value: sleepLength)
                }
                if let headache = report.headache {
                    ReportDetailRow(label: "Headache:", value: headache)
                }
                if let stress = report.stress {
                    ReportDetailRow(label: "Stress:", value: stress)
                }
                if let abdominalCramps = report.abdominalCramps {
                    ReportDetailRow(label: "Abdominal cramps:", value: abdominalCramps)
                }
                if let lowerBackPain = report.lowerBackPain {
                    ReportDetailRow(label: "Lower back pain:", value: lowerBackPain)
                }
                if let pelvicPain = report.pelvicPain {
                    ReportDetailRow(label: "Pelvic pain:", value: pelvicPain)
                }
                if let acne = report.acne {
                    ReportDetailRow(label: "Acne:", value: acne)
                }
                if let appetiteChanges = report.appetiteChanges {
                    ReportDetailRow(label: "Appetite changes:", value: appetiteChanges)
                }
                if let chestPain = report.chestPain {
                    ReportDetailRow(label: "Chest pain:", value: chestPain)
                }
                if let stepData = report.stepData {
                    ReportDetailRow(label: "Step data:", value: stepData)
                }
                if let mood = report.mood {
                    ReportDetailRow(label: "Mood:", value: mood)
                }
                if let notes = report.notes {
                    ReportDetailRow(label: "Notes:", value: notes)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ReportDetailRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

extension DateFormatter {
    static var shortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    ReviewReportView(report: ReviewReportModel(
        startTime: Date(),
        endTime: Date(),
        isCyMeSelfReport: true,
        selfReportMedium: .iOSApp,
        menstruationDate: "01/01/2023",
        menstruationStart: "01/01/2023",
        sleepQuality: "Good",
        sleepLenght: "8 hours",
        headache: "None",
        stress: "Low",
        abdominalCramps: "Mild",
        lowerBackPain: "None",
        pelvicPain: "None",
        acne: "Mild",
        appetiteChanges: "Increased",
        chestPain: "None",
        stepData: "10,000 steps",
        mood: "Happy",
        notes: "Feeling good today"
    ))
}
