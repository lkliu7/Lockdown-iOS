//
//  MainTabBarViewController.swift
//  Lockdown
//

import UIKit

final class MainTabBarController: UITabBarController {
    var firewallViewController: HomeViewController? {
        viewControllers?.first as? HomeViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controllers = viewControllers, controllers.count >= 2 else { return }
        viewControllers = Array(controllers.prefix(2))

        viewControllers?[0].tabBarItem.title = NSLocalizedString("Firewall", comment: "")
        viewControllers?[0].tabBarItem.image = UIImage(systemName: "lock.shield.fill")
        viewControllers?[1].tabBarItem.title = NSLocalizedString("Settings", comment: "")
        viewControllers?[1].tabBarItem.image = UIImage(systemName: "gearshape.fill")
    }
}
