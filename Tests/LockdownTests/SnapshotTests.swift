//
//  SnapshotTests.swift
//  LockdownTests
//
//  Created by Oleg Dreyman on 27.05.2020.
//  Copyright © 2020 Confirmed Inc. All rights reserved.
//

import XCTest
@testable import SnapshotTesting
@testable import Lockdown

final class SnapshotTests: XCTestCase {
    
    func testHomeVC() {
        let homeVC = make(HomeViewController.self, storyboardIdentifier: "homeViewController")
        lockdownSnapshotTest(homeVC)
    }

    func testSettingsVC() {
        let settingsVC = make(SettingsViewController.self, storyboardIdentifier: "settingsViewController")
        lockdownSnapshotTest(settingsVC)
    }
    
    func testFirewallPrivacyPolicyVC() {
        let privacyPolicyVC = make(PrivacyPolicyViewController.self, storyboardIdentifier: "firewallPrivacyPolicyViewController")
        privacyPolicyVC.parentVC = nil
        lockdownSnapshotTest(privacyPolicyVC)
    }
    
    func testLogVC() {
        BlockDayLog.shared.clear()
        
        let date = Calendar.current.date(bySettingHour: 9, minute: 41, second: 10, of: Date())!
        
        BlockDayLog.shared.append(host: "snapshot-test.com", date: date)
        BlockDayLog.shared.append(host: "lockdown-test.com", date: date)
        let logVC = make(BlockLogViewController.self, storyboardIdentifier: "blockLogViewController")
        lockdownSnapshotTest(logVC)
        BlockDayLog.shared.clear()
    }
}

extension SnapshotTests {
    private func make<ViewController: UIViewController>(_ vc: ViewController.Type, storyboardIdentifier: String) -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! ViewController
        return viewController
    }
    
    private func lockdownSnapshotTest(
        _ viewController: UIViewController,
        record: Bool = false,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8, userInterfaceStyle: .light), record: record, file: file, testName: testName, line: line)
        assertSnapshot(matching: viewController, as: .image(on: .iPhone8, userInterfaceStyle: .dark), record: record, file: file, testName: testName, line: line)
    }
}

extension Snapshotting where Value == UIViewController, Format == UIImage {
    static func image(on device: ViewImageConfig, userInterfaceStyle: UIUserInterfaceStyle) -> Snapshotting {
        return image(on: device, traits: .init(userInterfaceStyle: userInterfaceStyle))
    }
    
}
