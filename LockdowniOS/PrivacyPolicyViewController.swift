//
//  PrivacyPolicyViewController.swift
//  Lockdown
//
//  Created by Johnny Lin on 8/9/19.
//  Copyright © 2019 Confirmed Inc. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

let kHasAgreedToFirewallPrivacyPolicy = "kHasAgreedToFirewallPrivacyPolicy"

class PrivacyPolicyViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var privacyPolicyWrap: UIView!
    
    var parentVC: HomeViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getStartedButton.backgroundColor = .tunnelsBlue
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        defaults.set(true, forKey: kHasAgreedToFirewallPrivacyPolicy)
        dismiss(animated: true) { self.parentVC?.toggleFirewall(self) }
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        showPrivacyPolicyModal()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
