//
//  SharedConstants.swift
//  LockdowniOS
//
//  Created by Johnny Lin on 8/8/19.
//  Copyright © 2019 Confirmed Inc. All rights reserved.
//
// These are constants and functions shared by the main app and the extensions

import Foundation
import CocoaLumberjackSwift

var appInstallDate: Date? {
    if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        if let installDate = try! FileManager.default.attributesOfItem(atPath: documentsFolder.path)[.creationDate] as? Date {
            return installDate
        }
    }
    return nil
}

@discardableResult
func appHasJustBeenUpgradedOrIsNewInstall() -> Bool {
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let versionOfLastRun = UserDefaults.standard.object(forKey: kVersionOfLastRun) as? String
    DDLogInfo("APP UPGRADED CHECK: LAST RUN \(versionOfLastRun ?? "n/a") | CURRENT \(currentVersion ?? "n/a")")
    UserDefaults.standard.set(currentVersion, forKey: kVersionOfLastRun)
    if (versionOfLastRun == nil || versionOfLastRun != currentVersion) {
        // either first time this check has occurred, or app was updated since last run
        DDLogInfo("APP UPGRADED CHECK: TRUE - LAST RUN \(versionOfLastRun ?? "n/a") | CURRENT \(currentVersion ?? "n/a")")
        return true
    } else {
        // nothing changed
        DDLogInfo("APP UPGRADED CHECK: FALSE")
        return false
    }
}

let reachability = Availability()

struct MessageError: LocalizedError, CustomStringConvertible {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? { message }
    var description: String { message }
}

// MARK: - Extensions

extension String {
    
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
}

extension UIColor {
    static let confirmedBlue = UIColor(named: "Confirmed Blue") ?? UIColor.tunnelsBlue
    
    static let tunnelsBlue = UIColor(red: 0/255.0, green: 173/255.0, blue: 231/255.0, alpha: 1.0)
    static let tunnelsWarning = UIColor(red: 231/255.0, green: 76/255.0, blue: 68/255.0, alpha: 1.0)
    static let tunnelsDarkBlue = UIColor(red: 0/255.0, green: 117/255.0, blue: 157/255.0, alpha: 1.0)
    static let tunnelsLightBlue = UIColor(red: 223/255.0, green: 243/255.0, blue: 251/255.0, alpha: 1.0)
    static let borderGray = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    static let borderBlue = UIColor(red: 0, green: 0.678, blue: 0.906, alpha: 1)
    static let smallGrey = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    static var extraLightGray = UIColor(red: 242/255.0, green: 244/255.0, blue: 245/255.0, alpha: 1)
    static let tunnelsBlueTest = UIColor(red: 0/255.0, green: 173/255.0, blue: 231/255.0, alpha: 0.0)
    static let lockdownRed = UIColor(red: 214.0/255.0, green: 87.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    static let panelSecondaryBackground = UIColor(named: "Panel Secondary Background")
    static let tableCellBackground = UIColor(named: "tableCellBackground")
    static let tableCellSelectedBackground = UIColor(named: "tableCellSelectedBackground")
    static let disabledGray = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
}

extension UnicodeScalar {
    var hexNibble:UInt8 {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        }
        else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        }
        else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        fatalError("\(self) not a legal hex nibble")
    }
}

extension Data {
    init(hex: String) {
        let scalars = hex.unicodeScalars
        var bytes = Array<UInt8>(repeating: 0, count: (scalars.count + 1) >> 1)
        for (index, scalar) in scalars.enumerated() {
            var nibble = scalar.hexNibble
            if index & 1 == 0 {
                nibble <<= 4
            }
            bytes[index >> 1] |= nibble
        }
        self = Data(bytes: bytes)
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

// MARK: - Fonts
let fontRegular12 = UIFont(name: "Montserrat-Regular", size: 12)!
let fontRegular14 = UIFont(name: "Montserrat-Regular", size: 14)!
let fontRegular15 = UIFont(name: "Montserrat-Regular", size: 15)!
let fontRegular17 = UIFont(name: "Montserrat-Regular", size: 17)!
let fontMedium14 = UIFont(name: "Montserrat-Medium", size: 14)!
let fontMedium11 = UIFont(name: "Montserrat-Medium", size: 11)!
let fontMedium13 = UIFont(name: "Montserrat-Medium", size: 13)!
let fontMedium15 = UIFont(name: "Montserrat-Medium", size: 15)!
let fontMedium16 = UIFont(name: "Montserrat-Medium", size: 16)!
let fontMedium17 = UIFont(name: "Montserrat-Medium", size: 17)!
let fontMedium18 = UIFont(name: "Montserrat-Medium", size: 18)!
let fontSemiBold13 = UIFont(name: "Montserrat-SemiBold", size: 13)!
let fontSemiBold15 = UIFont(name: "Montserrat-SemiBold", size: 15)!
let fontSemiBold15_5 = UIFont(name: "Montserrat-SemiBold", size: 15.5)!
let fontSemiBold17 = UIFont(name: "Montserrat-SemiBold", size: 17)!
let fontSemiBold22 = UIFont(name: "Montserrat-SemiBold", size: 22)!
let fontBold11 = UIFont(name: "Montserrat-Bold", size: 11)!
let fontBold13 = UIFont(name: "Montserrat-Bold", size: 13)!
let fontBold15 = UIFont(name: "Montserrat-Bold", size: 15)!
let fontBold17 = UIFont(name: "Montserrat-Bold", size: 17)!
let fontBold18 = UIFont(name: "Montserrat-Bold", size: 18)!
let fontBold22 = UIFont(name: "Montserrat-Bold", size: 22)!
let fontBold24 = UIFont(name: "Montserrat-Bold", size: 24)!
let fontBold26 = UIFont(name: "Montserrat-Bold", size: 26)!
let fontBold28 = UIFont(name: "Montserrat-Bold", size: 28)!
let fontBold34 = UIFont(name: "Montserrat-Bold", size: 34)!
