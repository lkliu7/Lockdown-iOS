//
//  AppDelegate.swift
//  Lockdown
//

import BackgroundTasks
import CocoaLumberjackSwift
import SafariServices
import UIKit
import UserNotifications
import WidgetKit

let fileLogger = DDFileLogger()

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let connectivityService = ConnectivityService()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupLocalLogger()
        ProtectedFileAccess.createProtectionAccessCheckFile()
        UNUserNotificationCenter.current().delegate = self

        setupFirewallDefaultBlockLists()
        setupLockdownWhitelistedDomains()
        connectivityService.startObservingConnectivity()
        LockdownAppearance.configure()

        SFContentBlockerManager.reloadContentBlocker(
            withIdentifier: LockdownStorageIdentifier.contentBlockerId
        ) { error in
            if let error {
                DDLogError("Error loading Safari content blocker: \(error)")
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: FirewallRepair.identifier,
            using: nil
        ) { task in
            FirewallRepair.handleAppRefresh(task)
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let root = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        FirewallRepair.reschedule()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        PacketTunnelProviderLogs.flush()
        flushBlockLog(log: { _ in })
        updateMetrics(.resetIfNeeded, rescheduleNotifications: .always)
        FirewallRepair.run(context: .homeScreenDidLoad)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        WidgetCenter.shared.reloadAllTimelines()
    }

    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        FirewallRepair.run(context: .backgroundRefresh) { result in
            switch result {
            case .failed:
                completionHandler(.failed)
            case .repairAttempted:
                completionHandler(.newData)
            case .noAction:
                completionHandler(.noData)
            }
        }
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard let host = URLComponents(url: url, resolvingAgainstBaseURL: true)?.host,
              let tabs = window?.rootViewController as? MainTabBarController,
              let firewall = tabs.firewallViewController else {
            return false
        }

        tabs.selectedIndex = 0
        switch host.lowercased() {
        case "togglefirewall":
            firewall.toggleFirewall(self)
        case "showmetrics":
            firewall.refreshFirewallData()
        default:
            return false
        }
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = PushNotifications.Identifier(rawValue: response.notification.request.identifier)
        if let tabs = window?.rootViewController as? MainTabBarController,
           let firewall = tabs.firewallViewController {
            tabs.selectedIndex = 0
            if identifier.isWeeklyUpdate {
                firewall.refreshFirewallData()
            } else if identifier == .blockMilestone {
                firewall.showBlockLog(self)
            }
        }
        completionHandler()
    }
}

extension PacketTunnelProviderLogs {
    static func flush() {
        guard !allEntries.isEmpty else { return }
        for entry in allEntries {
            DDLogInfo("Packet Tunnel: \(entry)")
        }
        clear()
    }
}
