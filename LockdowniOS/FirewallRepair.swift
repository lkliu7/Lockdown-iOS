//
//  FirewallRepair.swift
//  Lockdown
//
//  Created by Oleg Dreyman on 21.10.2020.
//  Copyright © 2020 Confirmed Inc. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
import BackgroundTasks

enum FirewallRepair {
    
    static let identifier = "com.confirmed.lockdown.firewallscheduler"
    
    enum Result {
        case repairAttempted
        case failed(Swift.Error?)
        case noAction
    }
    
    enum Context: CustomDebugStringConvertible {
        case backgroundRefresh
        case homeScreenDidLoad
        
        var debugDescription: String {
            switch self {
            case .backgroundRefresh:
                return "Background Check"
            case .homeScreenDidLoad:
                return "Home"
            }
        }
    }
    
    @available(iOS 13.0, *)
    static func handleAppRefresh(_ task: BGTask) {
        DDLogInfo("BGTask: Handle App Refresh called")
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            DDLogInfo("BGTask: Operation started")
            FirewallRepair.run(context: .backgroundRefresh) { (result) in
                DDLogInfo("BGTask: Result: \(result)")
            }
        }
        operation.completionBlock = {
            DDLogInfo("BGTask: Operation completion block")
            let success = !operation.isCancelled
            DDLogInfo("BGTask: Operation completion success: \(success)")
            task.setTaskCompleted(success: success)
        }
        
        queue.addOperation(operation)
        
        task.expirationHandler = {
            DDLogError("BGTask: Expiration Handler called")
            queue.cancelAllOperations()
        }
        
        FirewallRepair.reschedule()
    }
    
    static func reschedule() {
        if #available(iOS 13.0, *) {
            DDLogInfo("BGTask: Cancelling all task requests")
            BGTaskScheduler.shared.cancelAllTaskRequests()
            
            let timeIntervalSeconds: Double = 3600
            
            let request = BGAppRefreshTaskRequest(identifier: FirewallRepair.identifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: timeIntervalSeconds)
            DDLogInfo("BGTask: Scheduling app refresh id: \(FirewallRepair.identifier), earliest date \(Date(timeIntervalSinceNow: TimeInterval(timeIntervalSeconds)))")
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                DDLogError("Could not schedule app refresh: \(error)")
            }
        }
        else {
            DDLogInfo("BGTask: Not iOS 13, not calling reschedule")
        }
    }
    
    static func run(context: Context, completion: @escaping (FirewallRepair.Result) -> Void = { _ in }) {
        DDLogInfo("Repair \(context): Starting")
        
        // Check 2 conditions for firewall restart, but reload manager first to get non-stale one
        FirewallController.shared.refreshManager(completion: { error in
            if let e = error {
                DDLogError("Repair \(context): Error refreshing Manager in \(context): \(e)")
                completion(.failed(e))
                return
            }
            DDLogInfo("Repair \(context): refreshed manager")
            DDLogInfo("Repair \(context): userWantsFirewallEnabled \(getUserWantsFirewallEnabled())")
            DDLogInfo("Repair \(context): firewallStatus \(FirewallController.shared.status())")
            if getUserWantsFirewallEnabled() && (FirewallController.shared.status() == .connected || FirewallController.shared.status() == .invalid || FirewallController.shared.status() == .disconnected) {
                DDLogInfo("Repair \(context): user wants enabled")
                if (appHasJustBeenUpgradedOrIsNewInstall()) {
                    DDLogInfo("Repair \(context): APP UPGRADED, REFRESHING DEFAULT BLOCK LISTS, WHITELISTS, RESTARTING FIREWALL")
                    setupFirewallDefaultBlockLists()
                    setupLockdownWhitelistedDomains()
                    FirewallController.shared.restart(completion: {
                        error in
                        if error != nil {
                            DDLogError("Error restarting firewall on \(context): \(error!)")
                        }
                        completion(.repairAttempted)
                    })
                }
                else {
                    testBlockedDomain { domainWasReachable in
                        guard domainWasReachable else {
                            DDLogInfo("Repair \(context): \(testFirewallDomain) was blocked as expected")
                            completion(.noAction)
                            return
                        }

                        DDLogError("Repair \(context): connected to \(testFirewallDomain); restarting Firewall")
                        FirewallController.shared.restart { error in
                            if let error {
                                DDLogError("Repair \(context): restart failed: \(error)")
                                completion(.failed(error))
                            } else {
                                completion(.repairAttempted)
                            }
                        }
                    }
                }
            }
            else {
                completion(.noAction)
            }
        })
    }

    private static func testBlockedDomain(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://\(testFirewallDomain)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10
        URLSession.shared.dataTask(with: request) { _, response, error in
            let reachable = error == nil && (response as? HTTPURLResponse)?.statusCode != nil
            completion(reachable)
        }.resume()
    }
}
