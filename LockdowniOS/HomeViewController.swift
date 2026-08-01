//
//  HomeViewController.swift
//  Lockdown
//

import CocoaLumberjackSwift
import NetworkExtension
import UIKit

final class CircularView: UIView {
    @IBInspectable var shadowUIColor: UIColor? {
        didSet { layer.shadowColor = shadowUIColor?.cgColor }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        layer.shadowColor = shadowUIColor?.cgColor
    }
}

final class HomeViewController: BaseViewController, Loadable {
    @IBOutlet private weak var mainStack: UIStackView!
    @IBOutlet private weak var firewallTitleLabel: UILabel!
    @IBOutlet private weak var firewallActive: UILabel!
    @IBOutlet private weak var firewallToggleCircle: UIButton!
    @IBOutlet private weak var firewallToggleAnimatedCircle: NVActivityIndicatorView!
    @IBOutlet private weak var firewallButton: UIButton!
    @IBOutlet private weak var tapToActivateFirewallLabel: UILabel!
    @IBOutlet private weak var metricsStack: UIStackView!
    @IBOutlet private weak var dailyMetrics: UILabel?
    @IBOutlet private weak var weeklyMetrics: UILabel?
    @IBOutlet private weak var allTimeMetrics: UILabel?
    @IBOutlet private weak var firewallSettingsButton: UIButton!
    @IBOutlet private weak var firewallViewLogButton: UIButton!

    private var metricsTimer: Timer?
    private var lastFirewallStatus: NEVPNStatus?

    override func viewDidLoad() {
        super.viewDidLoad()

        firewallTitleLabel.text = NSLocalizedString("Firewall", comment: "")

        firewallViewLogButton.layer.cornerRadius = 8
        firewallSettingsButton.layer.cornerRadius = 8
        refreshFirewallData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tunnelStatusDidChange(_:)),
            name: .NEVPNStatusDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        startMetricsTimer()
    }

    deinit {
        metricsTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let inset = firewallButton.frame.width * 0.175
        firewallButton.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func refreshFirewallData() {
        updateMetricsLabels()
        updateFirewallButton(with: FirewallController.shared.status())
    }

    @objc private func appDidBecomeActive() {
        startMetricsTimer()
        refreshFirewallData()
    }

    @objc private func appWillResignActive() {
        metricsTimer?.invalidate()
        metricsTimer = nil
    }

    private func startMetricsTimer() {
        metricsTimer?.invalidate()
        metricsTimer = Timer.scheduledTimer(
            timeInterval: 2,
            target: self,
            selector: #selector(updateMetricsLabels),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func updateMetricsLabels() {
        dailyMetrics?.text = getDayMetricsString()
        weeklyMetrics?.text = getWeekMetricsString()
        allTimeMetrics?.text = getTotalMetricsString()
    }

    @IBAction func toggleFirewall(_ sender: Any) {
        if !defaults.bool(forKey: kHasAgreedToFirewallPrivacyPolicy) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(
                withIdentifier: "firewallPrivacyPolicyViewController"
            ) as! PrivacyPolicyViewController
            controller.parentVC = self
            present(controller, animated: true)
            return
        }

        if getIsCombinedBlockListEmpty() {
            FirewallController.shared.setEnabled(false, isUserExplicitToggle: true)
            showPopupDialog(
                title: NSLocalizedString("No Block Lists Enabled", comment: ""),
                message: NSLocalizedString("Enable at least one block list before activating Firewall.", comment: ""),
                acceptButton: NSLocalizedString("Okay", comment: "")
            )
            return
        }

        switch FirewallController.shared.status() {
        case .invalid, .disconnected:
            updateFirewallButton(with: .connecting)
            FirewallController.shared.setEnabled(true, isUserExplicitToggle: true) { [weak self] error in
                if let error {
                    DDLogError("Unable to enable firewall: \(error)")
                }
                DispatchQueue.main.async { self?.refreshFirewallData() }
            }
        case .connected:
            updateFirewallButton(with: .disconnecting)
            FirewallController.shared.setEnabled(false, isUserExplicitToggle: true) { [weak self] _ in
                DispatchQueue.main.async { self?.refreshFirewallData() }
            }
        case .connecting, .disconnecting, .reasserting:
            break
        @unknown default:
            break
        }
    }

    @objc private func tunnelStatusDidChange(_ notification: Notification) {
        guard let session = notification.object as? NETunnelProviderSession else { return }
        updateFirewallButton(with: session.status)
    }

    private func updateFirewallButton(with status: NEVPNStatus) {
        guard status != lastFirewallStatus else { return }
        lastFirewallStatus = status

        DispatchQueue.main.async {
            switch status {
            case .connected:
                LatestKnowledge.isFirewallEnabled = true
                self.firewallActive.text = NSLocalizedString("ACTIVE", comment: "")
                self.firewallActive.textColor = .confirmedBlue
                self.tapToActivateFirewallLabel.isHidden = true
                self.firewallToggleAnimatedCircle.stopAnimating()
                self.firewallButton.isEnabled = true
            case .connecting, .reasserting:
                self.firewallActive.text = NSLocalizedString("CONNECTING", comment: "")
                self.firewallToggleAnimatedCircle.startAnimating()
                self.firewallButton.isEnabled = false
            case .disconnecting:
                self.firewallActive.text = NSLocalizedString("DISCONNECTING", comment: "")
                self.firewallToggleAnimatedCircle.startAnimating()
                self.firewallButton.isEnabled = false
            case .disconnected, .invalid:
                LatestKnowledge.isFirewallEnabled = false
                self.firewallActive.text = NSLocalizedString("INACTIVE", comment: "")
                self.firewallActive.textColor = .secondaryLabel
                self.tapToActivateFirewallLabel.isHidden = false
                self.firewallToggleAnimatedCircle.stopAnimating()
                self.firewallButton.isEnabled = true
            @unknown default:
                break
            }
        }
    }

    func showBlockLog(_ sender: Any) {
        performSegue(withIdentifier: "showBlockLog", sender: nil)
    }

    @IBAction private func viewAuditReportTapped(_ sender: Any) { showAuditModal() }
}
