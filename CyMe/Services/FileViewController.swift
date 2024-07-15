import UIKit
import WebKit

class FilePreviewController: UIViewController, WKUIDelegate {
    static let controllerIdentifier = String(describing: FilePreviewController.self)

    var url: URL!

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        loadFile()
    }

    private func loadFile() {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func onCloseButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func onMoreOptionsPressed(_ sender: UIBarButtonItem) {
        let documentController = UIDocumentInteractionController(url: url)
        documentController.delegate = self
        documentController.presentOptionsMenu(from: sender, animated: true)
    }
}

extension FilePreviewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
