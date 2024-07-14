import UIKit
import MessageUI

class MailComposeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var databaseURL: URL?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let databaseURL = databaseURL {
            sendEmail(with: databaseURL)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func sendEmail(with databaseURL: URL) {
        guard MFMailComposeViewController.canSendMail() else {
            dismiss(animated: true, completion: nil)
            return
        }

        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["marinja.principe@uzh.ch"]) // Pre-fill the recipient
        mailComposeVC.setSubject("CyMe Database")
        mailComposeVC.setMessageBody("Please find the attached CyMe database.", isHTML: false)
        
        if let data = try? Data(contentsOf: databaseURL) {
            mailComposeVC.addAttachmentData(data, mimeType: "application/x-sqlite3", fileName: "CyMe.sqlite")
        }

        present(mailComposeVC, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
