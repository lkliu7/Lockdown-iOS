//
//  Defaults.swift
//  Lockdown
//
//  Created by Radu Lazar on 08.08.2024.
//  Copyright © 2024 Confirmed Inc. All rights reserved.
//

import Foundation

//MARK: Metrics
let kDayMetrics = "LockdownDayMetrics"
let kWeekMetrics = "LockdownWeekMetrics"
let kTotalMetrics = "LockdownTotalMetrics"
let kTotalEnabledMetrics = "LockdownTotalEnabledMetrics"
let kTotalDisabledMetrics = "LockdownTotalDisabledMetrics"

let kActiveDay = "LockdownActiveDay"
let kActiveWeek = "LockdownActiveWeek"

//MARK: Firewall utils

let kLockdownBlockedDomains = "lockdown_domains"
let kUserBlockedDomains = "lockdown_domains_user"
let kUserBlockedLists = "lockdown_lists_user"

//MARK: Whitelist 

let kLockdownWhitelistedDomains = "whitelisted_domains"
let kUserWhitelistedDomains = "whitelisted_domains_user"

//MARK: Latest Knowledge

let kLatestKnowledgeIsFirewallEnabled = "kLatestKnowledgeIsFirewallEnabled"
//MARK: Others

let kUserWantsFirewallEnabled = "user_wants_firewall_enabled"

let kAllowNotificationsAfterDate = "LockdownAllowNotificationsAfter"

let kLockdownNotificationsEnergySavingCounter = "LockdownNotificationsEnergySavingCounter"

let kVersionOfLastRun = "VersionOfLastRun"
