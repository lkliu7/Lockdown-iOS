//
//  LockdownGradient.swift
//  Lockdown
//
//  Created by Alexander Parshakov on 11/28/22
//  Copyright © 2022 Confirmed Inc. All rights reserved.
// 

import UIKit

enum LockdownGradient {
    case lightBlue
    case custom([CGColor], NSLayoutConstraint.Axis = .vertical)

    var colors: [CGColor] {
        switch self {
        case .lightBlue:
            return [
                UIColor.fromHex("#00B6F3").cgColor,
                UIColor.fromHex("#0092CC").cgColor,
                UIColor.fromHex("#0083B7").cgColor
            ]
        case .custom(let colors, _):
            return colors
        }
    }

    var points: (start: CGPoint, end: CGPoint) {
        switch self {
        case .custom(_, .horizontal):
            return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0))
        default:
            return (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1))

        }
    }
}
