import CocoaLumberjackSwift
import UIKit

final class SettingsViewController: BaseViewController, Loadable {
    private let tableView = StaticTableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.anchors.edges.pin()
        tableView.separatorStyle = .singleLine
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.deselectsCellsAutomatically = true
        tableView.tableFooterView = UIView()
        createTable()
    }

    private func createTable() {
        tableView.clear()

        let notificationCell = DefaultCell(title: "", action: {})
        updateNotificationTitle(notificationCell)
        notificationCell.onSelect { [weak self, weak notificationCell] in
            guard let self, let notificationCell else { return }
            if PushNotifications.Authorization.getUserWantsNotificationsEnabled(forCategory: .weeklyUpdate) {
                PushNotifications.Authorization.setUserWantsNotificationsEnabled(
                    false,
                    forCategory: .weeklyUpdate
                )
                self.updateNotificationTitle(notificationCell)
            } else {
                PushNotifications.Authorization.requestWeeklyUpdateAuthorization(
                    presentingDialogOn: self
                ) { result in
                    if case .failure(let error) = result {
                        DDLogError("Notification authorization failed: \(error)")
                    }
                    self.updateNotificationTitle(notificationCell)
                }
            }
        }
        tableView.addCell(notificationCell)

        tableView.addCell(DefaultCell(title: NSLocalizedString("Domain Allowlist", comment: "")) {
            let controller = UIStoryboard.main.instantiateViewController(
                withIdentifier: "WhitelistViewController"
            )
            self.present(controller, animated: true)
        })

        tableView.addCell(DefaultCell(title: NSLocalizedString("Repair Firewall Configuration", comment: "")) {
            self.showFixFirewallConnectionDialog {
                FirewallController.shared.deleteConfigurationAndAddAgain()
            }
        })

        tableView.addCell(DefaultCell(title: NSLocalizedString("Privacy Policy", comment: "")) {
            self.showPrivacyPolicyModal()
        })

        tableView.addCell(DefaultCell(title: NSLocalizedString("Audit Report", comment: "")) {
            self.showAuditModal()
        })

        tableView.addRowCell { cell in
            cell.textLabel?.text = Bundle.main.versionString
            cell.textLabel?.font = fontSemiBold17
            cell.textLabel?.textColor = .systemGray
            cell.textLabel?.textAlignment = .right
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
            cell.directionalLayoutMargins = .zero
        }
    }

    private func updateNotificationTitle(_ cell: _DefaultCell) {
        let enabled = PushNotifications.Authorization
            .getUserWantsNotificationsEnabled(forCategory: .weeklyUpdate)
        cell.label.text = enabled
            ? NSLocalizedString("Notifications: On", comment: "")
            : NSLocalizedString("Notifications: Off", comment: "")
    }
}

final class _DefaultCell: SelectableTableViewCell {
    let label = UILabel()
}

func DefaultCell(title: String, action: @escaping () -> Void) -> _DefaultCell {
    let cell = _DefaultCell()
    cell.label.text = title
    cell.label.font = fontSemiBold17
    cell.label.textColor = .tunnelsBlue
    cell.label.textAlignment = .center
    cell.contentView.addSubview(cell.label)
    cell.label.anchors.edges.marginsPin(insets: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    return cell.onSelect(callback: action)
}
