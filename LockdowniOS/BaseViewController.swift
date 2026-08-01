import CocoaLumberjackSwift
import PopupDialog
import UIKit

open class BaseViewController: UIViewController {
    let interactionBlockViewTag = 84814

    override open func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }

    func getRectForView(_ view: UIView) -> CGRect {
        view.superview?.convert(view.frame, to: self.view) ?? .zero
    }

    func showPrivacyPolicyModal() {
        showModalWebView(
            title: NSLocalizedString("Privacy Policy", comment: ""),
            urlString: "https://lockdownprivacy.com/privacy"
        )
    }

    func showAuditModal() {
        showModalWebView(
            title: NSLocalizedString("Audit Reports", comment: ""),
            urlString: "https://openaudit.com/lockdownprivacy"
        )
    }

    func showModalWebView(title: String, urlString: String) {
        guard let url = URL(string: urlString) else {
            DDLogError("Invalid URL \(urlString)")
            return
        }

        let source = storyboard ?? UIStoryboard(name: "Main", bundle: nil)
        guard let controller = source.instantiateViewController(withIdentifier: "webview")
                as? WebViewViewController else {
            DDLogError("Unable to instantiate web view controller")
            return
        }
        controller.titleLabelText = title
        controller.url = url
        present(controller, animated: true)
    }

    func unblockUserInteraction() {
        view.viewWithTag(interactionBlockViewTag)?.removeFromSuperview()
    }

    func blockUserInteraction() {
        let blocker = UIView(frame: view.bounds)
        blocker.tag = interactionBlockViewTag
        blocker.backgroundColor = .clear
        view.addSubview(blocker)
    }

    func showPopupDialog(
        title: String,
        message: String,
        acceptButton: String,
        completionHandler: @escaping () -> Void = {}
    ) {
        let popup = PopupDialog(
            title: title.uppercased(),
            message: message,
            image: nil,
            transitionStyle: .bounceDown,
            hideStatusBar: false
        )
        popup.addButton(DefaultButton(title: acceptButton, dismissOnTap: true, action: completionHandler))
        (presentedViewController ?? self).present(popup, animated: true)
    }

    enum PopupButton {
        case custom(PopupDialogButton)
        case defaultAccept(completion: () -> Void)

        static func custom(
            title: String,
            titleColor: UIColor? = nil,
            completion: @escaping () -> Void
        ) -> PopupButton {
            let button = DefaultButton(title: title, dismissOnTap: true, action: completion)
            button.titleColor = titleColor
            return .custom(button)
        }

        static func destructive(title: String, completion: @escaping () -> Void) -> PopupButton {
            .custom(title: title, titleColor: .systemRed, completion: completion)
        }

        static func cancel(completion: @escaping () -> Void = {}) -> PopupButton {
            .custom(CancelButton(
                title: NSLocalizedString("Cancel", comment: ""),
                dismissOnTap: true,
                action: completion
            ))
        }

        static func preferredCancel(completion: @escaping () -> Void = {}) -> PopupButton {
            .custom(
                title: NSLocalizedString("Cancel", comment: ""),
                titleColor: nil,
                completion: completion
            )
        }

        fileprivate func makeButton() -> PopupDialogButton {
            switch self {
            case .custom(let button):
                return button
            case .defaultAccept(let completion):
                return DefaultButton(
                    title: NSLocalizedString("OK", comment: ""),
                    dismissOnTap: true,
                    action: completion
                )
            }
        }
    }

    func showPopupDialog(title: String?, message: String?, buttons: [PopupButton]) {
        let popup = PopupDialog(
            title: title,
            message: message,
            image: nil,
            transitionStyle: .bounceDown,
            hideStatusBar: false
        )
        popup.addButtons(buttons.map { $0.makeButton() })
        (presentedViewController ?? self).present(popup, animated: true)
    }

    func showFixFirewallConnectionDialog(completion: @escaping () -> Void) {
        FirewallController.shared.existingManagerCount { [weak self] count in
            DispatchQueue.main.async {
                guard let self else { return }
                let message: String
                if (count ?? 0) > 1 {
                    message = NSLocalizedString(
                        "Multiple Firewall configurations were found. Rebuilding them should restore the connection.",
                        comment: ""
                    )
                } else {
                    message = NSLocalizedString(
                        "Rebuild the local Firewall configuration? iOS may ask for permission again.",
                        comment: ""
                    )
                }
                self.showPopupDialog(
                    title: NSLocalizedString("Repair Firewall", comment: ""),
                    message: message,
                    buttons: [
                        .cancel(),
                        .custom(title: NSLocalizedString("Repair", comment: ""), completion: completion)
                    ]
                )
            }
        }
    }
}

extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
}
