//
//  UserDefaults.swift
//  Lockdown
//
//  Created by Oleg Dreyman on 28.09.2020.
//  Copyright © 2020 Confirmed Inc. All rights reserved.
//

import Foundation

let defaults = UserDefaults(suiteName: "group.com.confirmed")!

enum LatestKnowledge {
    
    static var isFirewallEnabled: Bool {
        get {
            return defaults.bool(forKey: kLatestKnowledgeIsFirewallEnabled)
        }
        set {
            defaults.setValue(newValue, forKey: kLatestKnowledgeIsFirewallEnabled)
        }
    }
    
}

func setUserWantsFirewallEnabled(_ enabled: Bool) {
    defaults.set(enabled, forKey: kUserWantsFirewallEnabled)
}

func getUserWantsFirewallEnabled() -> Bool {
    return defaults.bool(forKey: kUserWantsFirewallEnabled)
}
